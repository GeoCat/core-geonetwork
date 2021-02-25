package org.fao.geonet.kernel.security.service;

import com.google.common.cache.CacheBuilder;
import com.google.common.cache.CacheLoader;
import com.google.common.cache.LoadingCache;
import org.springframework.context.ApplicationListener;
import org.springframework.security.authentication.event.AbstractAuthenticationEvent;
import org.springframework.security.authentication.event.AuthenticationFailureBadCredentialsEvent;
import org.springframework.security.authentication.event.AuthenticationSuccessEvent;
import org.springframework.security.web.authentication.WebAuthenticationDetails;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

/**
 * Class to track login attempts and lock login requests after a number of invalid login trials.
 *
 */
public class LoginAttemptService implements ApplicationListener<AbstractAuthenticationEvent> {
    /**
     * Lock strategy:
     *
     *  - IP: Uses the remote IP address to lock the login attempts.
     *  - USERNAME: Uses only the username to lock the login attempts.
     *  - USERNAME_AND_IP: Uses the username and the the remote IP address to lock the login attempts.
     */
    public enum LOCK_STRATEGY {IP, USERNAME, USERNAME_AND_IP};

    private static final int DEFAULT_MAX_ATTEMPTS = 5;
    private static final long DEFAULT_LOCK_DURATION = 10;
    private static final TimeUnit DEFAULT_LOCK_TIMEUNIT = TimeUnit.MINUTES;


    /**
     *
     */
    private int maxInvalidAttempts;
    private LOCK_STRATEGY lockStrategy;

    private LoadingCache<String, Integer> attemptsCache;

    public LoginAttemptService() {
        this(DEFAULT_MAX_ATTEMPTS, DEFAULT_LOCK_DURATION, DEFAULT_LOCK_TIMEUNIT, LOCK_STRATEGY.IP);
    }

    public LoginAttemptService(int maxInvalidAttempts) {
        this(maxInvalidAttempts, DEFAULT_LOCK_DURATION, DEFAULT_LOCK_TIMEUNIT, LOCK_STRATEGY.IP);
    }

    public LoginAttemptService(long lockDuration, TimeUnit lockTimeUnit) {
        this(DEFAULT_MAX_ATTEMPTS, lockDuration, lockTimeUnit, LOCK_STRATEGY.IP);
    }

    public LoginAttemptService(int maxInvalidAttempts, long lockDuration, TimeUnit lockTimeUnit, LOCK_STRATEGY lockStrategy) {
        super();
        this.maxInvalidAttempts = maxInvalidAttempts;
        this.lockStrategy = lockStrategy;
        attemptsCache = CacheBuilder.newBuilder().
            expireAfterWrite(lockDuration, lockTimeUnit).build(new CacheLoader<String, Integer>() {
            public Integer load(String key) {
                return 0;
            }
        });
    }

    public void registerSuccessfulLogin(String username, String ipAddress) {
        attemptsCache.invalidate(calculateKey(username, ipAddress));
    }

    public void registerFailedLogin(String username, String ipAddress) {
        int attempts = 0;
        String key = calculateKey(username, ipAddress);
        try {
            attempts = attemptsCache.get(key);
        } catch (ExecutionException e) {
            attempts = 0;
        }
        attempts++;
        attemptsCache.put(key, attempts);
    }

    public boolean isBlocked(String username, String ipAddress) {
        try {
            String key = calculateKey(username, ipAddress);
            return attemptsCache.get(key) >= maxInvalidAttempts;
        } catch (ExecutionException e) {
            return false;
        }
    }


    private String calculateKey(String username, String ipAddress) {
        if (lockStrategy == LOCK_STRATEGY.IP) {
            return ipAddress;
        } else if (lockStrategy == LOCK_STRATEGY.USERNAME) {
            return username;
        } else {
            return username + "::" + ipAddress;
        }
    }

    @Override
    public void onApplicationEvent(AbstractAuthenticationEvent event) {
        String username = event.getAuthentication().getName();

        WebAuthenticationDetails auth = (WebAuthenticationDetails)
            event.getAuthentication().getDetails();

        if (event instanceof AuthenticationFailureBadCredentialsEvent) {
            registerFailedLogin(username,  auth.getRemoteAddress());

        } else if (event instanceof AuthenticationSuccessEvent) {
            registerSuccessfulLogin(username,  auth.getRemoteAddress());
        }
    }

}
