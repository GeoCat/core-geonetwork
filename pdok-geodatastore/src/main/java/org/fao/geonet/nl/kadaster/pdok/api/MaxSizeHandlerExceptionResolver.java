package org.fao.geonet.nl.kadaster.pdok.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import nl.kadaster.pdok.bussiness.MetadataParametersBean;
import org.fao.geonet.utils.Log;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.HandlerExceptionResolver;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Handle max size file upload exceptions. It returns a JSON objec <code>{"error": true, messages:["uploadMaxSizeError"]}</code>
 * and sets the response status code to 413 Request Entity Too Large.
 * If the exception is not an MaxUploadSizeExceededException continues the default exception processing.
 * Created by juanluisrp on 17/11/2015.
 */
@Component
public class MaxSizeHandlerExceptionResolver implements HandlerExceptionResolver {
    private static final String LOG_MODULE = "MaxSizeHandlerExceptionResolver";

    @Override
    public ModelAndView resolveException(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        if (ex instanceof MaxUploadSizeExceededException) {
            Long maxSizeInBytes = ((MaxUploadSizeExceededException) ex).getMaxUploadSize();
            Log.warning(LOG_MODULE, "Maximum upload size of " + maxSizeInBytes / 1024L + " MiB per attachment exceeded", ex);
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            response.setStatus(HttpStatus.REQUEST_ENTITY_TOO_LARGE.value());
            try (PrintWriter out = response.getWriter()) {
                MetadataParametersBean mpb = new MetadataParametersBean();
                mpb.setError(true);
                mpb.addMessage("uploadMaxSizeError");
                ObjectMapper mapper = new ObjectMapper();
                mapper.writeValue(out, mpb);
                return new ModelAndView();
            } catch (IOException e) {
                Log.error(LOG_MODULE, "Error writing to output stream", e);
            }
        }

        //for default behaviour
        return null;
    }
}
