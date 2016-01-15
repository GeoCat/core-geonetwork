package org.fao.geonet.nl.kadaster.pdok.api;

import nl.kadaster.pdok.bussiness.LoginResponse;
import org.fao.geonet.utils.Log;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.context.SaveContextOnUpdateOrErrorResponseWrapper;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;

/**
 * Created by juanluisrp on 01/12/2015.
 */
@Controller
@RequestMapping("/{lang}/ajaxLogin")
public class AjaxLoginController {
    private static final String LOG_MODULE="geodatastore.register";
    @Autowired
    @Qualifier("authenticationManager")
    AuthenticationManager authenticationManager;

    @Autowired
    SecurityContextRepository repository;

    @RequestMapping(method = RequestMethod.GET)
    public void login() {

    }

    @RequestMapping(method=RequestMethod.POST)
    @ResponseBody
    public LoginResponse performLogin(
            @RequestParam("j_username") String username,
            @RequestParam("j_password") String password,
            HttpServletRequest request, HttpServletResponse response) {
        Log.debug(LOG_MODULE, "Login request from user " + username);
        try {
            UsernamePasswordAuthenticationToken token =
                new UsernamePasswordAuthenticationToken(username, password);
            Log.info(LOG_MODULE, String.format("Trying to authenticate user \"%s\"", username));
            Authentication auth = authenticationManager.authenticate(token);
            Log.info(LOG_MODULE, String.format("User \"%s\" authenticated successfully", username));
            SecurityContextHolder.getContext().setAuthentication(auth);

            ServletResponse wrappedResponse = response;
            while (wrappedResponse instanceof HttpServletResponseWrapper) {
                if (wrappedResponse instanceof SaveContextOnUpdateOrErrorResponseWrapper) {
                    break;
                }
                wrappedResponse = ((HttpServletResponseWrapper) wrappedResponse).getResponse();
            }
            if (!(wrappedResponse instanceof SaveContextOnUpdateOrErrorResponseWrapper)) {
                Log.error(LOG_MODULE, "Cannot find a response of type SaveContextOnUpdateOrErrorResponseWrapper");
            }

            repository.saveContext(SecurityContextHolder.getContext(), request, (HttpServletResponse) wrappedResponse);
            return new LoginResponse(true, null);
        } catch (BadCredentialsException ex) {
            Log.info(LOG_MODULE, "Cannot authenticate user " + username, ex);
            return new LoginResponse(false, "Bad Credentials");
        } catch (AuthenticationServiceException ex) {
            Log.info(LOG_MODULE, "Cannot authenticate user " + username + ". Cause: " + ex.getMessage());
            return new LoginResponse(false, "Bad Credentials");
        }
        catch (Exception ex) {
            Log.error(LOG_MODULE, "Exception authenticating user " + username, ex);
            throw ex;
        }
    }

}
