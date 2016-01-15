package org.fao.geonet.nl.kadaster.pdok.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import nl.kadaster.pdok.bussiness.GeodatastoreMailUtils;
import nl.kadaster.pdok.bussiness.RegisterBean;
import nl.kadaster.pdok.bussiness.ValidationResponse;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.utils.Log;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.validation.Valid;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by juanluisrp on 04/11/2015.
 */
@Controller
public class NewAccountController {
    private static final String GDS_LOG = "geodatastore.register";
    private static final String REGISTRATION_EMAIL_XSLT = "/templates/registration-email-transform.xsl";
    private static final String CONFIRM_REGISTRATION_EMAIL_XSLT = "/templates/confirm-registration-email.xsl";
    @Autowired
    private GeodatastoreMailUtils geodatastoreMailUtils;
    @Value("#{geodatastoreProperties[registrationEmailAddress]}")
    private String registrationEmailAddress;
    @Value("#{geodatastoreProperties['registrationEmailAddress.bcc']}")
    private String registrationEmailAddressBccString;

    @RequestMapping(value = "/{lang}/gdsRegister", method = RequestMethod.POST)
    public
    @ResponseBody
    ValidationResponse register(@PathVariable("lang") String lang,
                                @Valid @RequestPart("registerBean") RegisterBean registerBean, BindingResult bindingResult,
                                @RequestPart("logo") MultipartFile logo) {


        ValidationResponse response = new ValidationResponse();
        response.setStatus("SUCCESS");
        try {
            List<String> fieldsWithErrors = new ArrayList<>();
            if (logo.isEmpty()) {
                fieldsWithErrors.add("logo");
            }
            for (FieldError error : bindingResult.getFieldErrors()) {
                fieldsWithErrors.add(error.getField());
            }
            if (!fieldsWithErrors.isEmpty()) {
                response.setStatus("ERROR");
                response.setErrorMessageList(fieldsWithErrors);
            } else {
                if (!sendEmail(registerBean, logo)) {
                    response.setStatus("ERROR");
                    response.setGlobalError("emailNotSent");
                }
            }
        } catch (Exception e) {
            response.setStatus("ERROR");
            response.setGlobalError(e.getClass().getCanonicalName());
        }


        return response;
    }

    private boolean sendEmail(RegisterBean registerBean, MultipartFile logo) throws IOException {
        Map<String, String> mailTemplateParameters = new HashMap<>();
        ObjectMapper objectMapper = new ObjectMapper();

        @SuppressWarnings("unchecked")
        Map<String, Object> objectAsMap = objectMapper.convertValue(registerBean, Map.class);
        for (Map.Entry<String, Object> entry : objectAsMap.entrySet()) {
            String key = entry.getKey();
            Object value = entry.getValue();
            if (value instanceof String) {
                mailTemplateParameters.put(key, (String) value);
            }
        }

        List<Path> attachmentList = new ArrayList<>();
        boolean sent = false;
        Path logoDir = Files.createTempDirectory("logo");
        String uploadedFileName = logo.getOriginalFilename();
        String extension = "";
        if (uploadedFileName.lastIndexOf('.') > -1) {
            extension = StringUtils.substring(uploadedFileName, uploadedFileName.lastIndexOf('.'));
        }
        Path logoPath = Files.createFile(logoDir.resolve("logo" + extension));
        File logoFile = logoPath.toFile();
        try {
            logo.transferTo(logoFile);
            attachmentList.add(logoPath);
            List<String> bccList = new ArrayList<>();
            if (StringUtils.isNotEmpty(registrationEmailAddressBccString)) {
                String[] addresses = StringUtils.split(registrationEmailAddressBccString, ',');
                if (addresses != null) {
                    for (String address : addresses) {
                        bccList.add(StringUtils.trim(address));
                    }
                }
            }

            List<String> toList = Lists.newArrayList(registrationEmailAddress);
            // Send new account request to PDOK
            sent = geodatastoreMailUtils.sendHtmlEmailWithAttachments(toList, bccList, mailTemplateParameters, attachmentList, REGISTRATION_EMAIL_XSLT);
            // Send confirmation email to user and organization
            List<String> confirmToList = Lists.newArrayList(registerBean.getEmail(), registerBean.getOrgEmail());
            geodatastoreMailUtils.sendHtmlEmail(confirmToList, Lists.<String>newArrayList(), Maps.<String, String>newHashMap(), CONFIRM_REGISTRATION_EMAIL_XSLT);

        } catch (Exception e) {
            Log.error(GDS_LOG, "Error sending registration email", e);
            sent = false;
        } finally {
            FileUtils.deleteQuietly(logoDir.toFile());
        }
        if (!sent) {
            Log.error(GDS_LOG, "The registration email cannot be sent. Please review the mail server settings in the database");
        }
        return sent;
    }
}
