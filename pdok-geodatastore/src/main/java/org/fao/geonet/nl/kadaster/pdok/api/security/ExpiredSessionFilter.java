package org.fao.geonet.nl.kadaster.pdok.api.security;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.GenericFilterBean;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Created by juanluisrp on 16/12/2015.
 */
public class ExpiredSessionFilter extends GenericFilterBean {
    static final String FILTER_APPLIED = "__spring_security_expired_session_filter_applied";


    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        if (request.getAttribute(FILTER_APPLIED) != null) {
            chain.doFilter(request, response);
            return;
        }

        request.setAttribute(FILTER_APPLIED, Boolean.TRUE);
        if ((request.getRequestedSessionId() != null && !request.isRequestedSessionIdValid()) && SecurityContextHolder.getContext().getAuthentication() == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED/*, "SESSION_TIMED_OUT"*/);
            return;
        }
        try {
            chain.doFilter(request, response);
        } catch (Exception e) {
            System.out.println("Access denied");
        }
    }
}
