package org.fao.geonet.nl.kadaster.pdok.api;

import jeeves.server.context.ServiceContext;
import jeeves.server.dispatchers.ServiceManager;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.constants.Params;
import org.fao.geonet.domain.ISODate;
import org.fao.geonet.domain.MetadataFileDownload;
import org.fao.geonet.domain.MetadataFileUpload;
import org.fao.geonet.domain.User;
import org.fao.geonet.exceptions.MetadataNotFoundEx;
import org.fao.geonet.exceptions.ResourceNotFoundEx;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.repository.MetadataFileDownloadRepository;
import org.fao.geonet.repository.MetadataFileUploadRepository;
import org.fao.geonet.util.MimeTypeFinder;
import org.fao.geonet.utils.Log;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.*;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Downloads of datasets and thumbnails.
 * Created by juanluisrp on 05/11/2015.
 */
@Controller
public class DownloadApi {
    private static final String GDS_LOG = "pdok.geodatastore.download";

    @Autowired
    private DataManager metadataManager;
    @Autowired
    private ServiceManager serviceManager;

    @Autowired
    private MetadataFileUploadRepository uploadRepository;

    @Autowired
    private MetadataFileDownloadRepository downloadRepository;

    /**
     * Download the recentest thumbnail found in the public folder of the metadata.
     *
     * @param uuid     Metadata UUID identifier
     * @param request  ServletRequest
     * @param response ServletResponse
     * @throws Exception
     */
    @RequestMapping(value = "/id/dataset/{uuid}", method = RequestMethod.GET)
    public void downloadDataset(@PathVariable("uuid") String uuid, HttpServletRequest request,
                                HttpServletResponse response) throws Exception {
        downloadFile(uuid, Params.Access.PRIVATE, request, response);
    }

    /**
     * Download the recentest thumbnail found in the public folder of the metadata.
     *
     * @param uuid     Metadata UUID identifier
     * @param request  ServletRequest
     * @param response ServletResponse
     * @throws Exception
     */
    @RequestMapping(value = "/id/thumbnail/{uuid}", method = RequestMethod.GET)
    public void downloadThumbnail(@PathVariable("uuid") String uuid, HttpServletRequest request,
                                  HttpServletResponse response) throws Exception {
        downloadFile(uuid, Params.Access.PUBLIC, request, response);
    }


    /**
     * Send to the client the most recent file in the metadata private or public folder, depending on the access parameter.
     *
     * @param uuid     the metadata UUID
     * @param access   Must be one of the Params.Access
     * @param request  ServletRequest
     * @param response ServletResponse
     * @throws Exception thrown if the metadata or the file is not found or if there is any IOException while sending the file.
     * @see org.fao.geonet.constants.Params.Access
     */
    public void downloadFile(String uuid, String access, HttpServletRequest request, HttpServletResponse response) throws Exception {
        String metadataId;
        try {
            metadataId = metadataManager.getMetadataId(uuid);
            if (StringUtils.isBlank(metadataId)) {
                Log.info(GDS_LOG, "Metadata with UUID " + uuid + " not found");
                throw new MetadataNotFoundEx(uuid);
            }

            final ServiceContext context = serviceManager.createServiceContext("geodatastore.api.download", "dut", request);
            // Build the file path
            Path dir = Lib.resource.getDir(context, access, metadataId);
            // We don't know the resource file name, so we take the newest one.
            List<Path> files = new ArrayList<>();
            try (DirectoryStream<Path> stream = Files.newDirectoryStream(dir)) {
                for (Path p : stream) {
                    files.add(p);
                }
            }
            Collections.sort(files, new Comparator<Path>() {
                public int compare(Path o1, Path o2) {
                    try {
                        return Files.getLastModifiedTime(o1).compareTo(Files.getLastModifiedTime(o2));
                    } catch (IOException e) {
                        Log.warning(GDS_LOG, "Cannot compare dataset lastModifiedDate", e);
                    }
                    return 0;
                }
            });
            if (files.size() == 0) {
                throw new ResourceNotFoundEx(uuid);
            }
            Path resource = files.get(files.size() - 1);
            transferFile(resource, request, response);

            // Updates the download statistics for metadata files (except thumbnails)
            if (access.equalsIgnoreCase(Params.Access.PRIVATE)) {
                updateDownloadStatistics(Integer.parseInt(metadataId), resource.getFileName().toString());
            }

        } catch (ResourceNotFoundEx e) {
            Log.warning(GDS_LOG, "Metadata " + uuid + " has not dataset", e);
            throw e;
        } catch (MetadataNotFoundEx e) {
            e.printStackTrace();
            Log.error(GDS_LOG, "Metadata " + uuid + " not found", e);
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            Log.error(GDS_LOG, e);
            throw e;
        }
    }

    /**
     * Copy the file contents into the response output stream and tries to set the right headers (contentType, size,
     * fileDisposition) for the response.
     *
     * @param file     the file to transfer.
     * @param request  the ServletRequest.
     * @param response the ServletResponse.
     * @throws IOException if there is any problem accessing the file or copying the content.
     */
    private void transferFile(Path file, HttpServletRequest request, HttpServletResponse response) throws IOException {
        ServletContext context = request.getServletContext();
        try (InputStream fileInputStream = Files.newInputStream(file, StandardOpenOption.READ)) {
            // get MIME type of the file
            String mimeType = context.getMimeType(file.toString());
            if (mimeType == null) {
                //mimeType = MimeTypeFinder.detectMimeTypeFile(file.getParent().toString(), file.getFileName().toString());
                String contentType = null;
                if (contentType == null) {
                    String ext = com.google.common.io.Files.getFileExtension(file.getFileName().toString()).toLowerCase();
                    switch (ext) {
                        case "png":
                        case "gif":
                        case "bmp":
                        case "tif":
                        case "tiff":
                        case "jpg":
                        case "jpeg":
                        case "svg":
                            contentType = "image/" + ext;
                            break;
                        case "txt":
                        case "html":
                            contentType = "text/" + ext;
                            break;
                        default:
                            contentType = "application/" + ext;
                    }
                }
            }
            Log.debug(GDS_LOG, "MIME type: " + mimeType);
            response.setContentType(mimeType);
            response.setContentLength((int) Files.size(file));

            // Set headers for the response
            String headerKey = "Content-Disposition";
            String headerValue = String.format("attachment; filename=\"%s\"",
                    file.getFileName());
            response.setHeader(headerKey, headerValue);
            // get output stream of the response
            try (OutputStream outStream = response.getOutputStream()) {
                StreamUtils.copy(fileInputStream, outStream);
            }
        }
    }

    @ResponseStatus(value = HttpStatus.NOT_FOUND, reason = "metadata-not-found")
    @ExceptionHandler(MetadataNotFoundEx.class)
    public void handleMetadataNotFound() {

    }

    @ResponseStatus(value = HttpStatus.NOT_FOUND, reason = "dataset-not-found")
    @ExceptionHandler(ResourceNotFoundEx.class)
    public void handleResourceNotFound() {

    }

    @ResponseStatus(value = HttpStatus.INTERNAL_SERVER_ERROR)
    @ExceptionHandler(Exception.class)
    public void handleInternalServerError() {

    }

    /**
     * Updates the download statistics for metadata files (except thumbnails).
     *
     * @param metadataId
     * @param fname
     */
    private void updateDownloadStatistics(Integer metadataId, String fname) {
        User activeUser = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        final String userName = activeUser.getUsername();

        MetadataFileUpload metadataFileUpload;

        // Each download is related to a file upload record
        try {
            metadataFileUpload = uploadRepository.findByMetadataIdAndFileNameNotDeleted(metadataId, fname);

            if (metadataFileUpload != null) {
                MetadataFileDownload metadataFileDownload = new MetadataFileDownload();

                metadataFileDownload.setMetadataId(metadataId);
                metadataFileDownload.setFileName(fname);
                metadataFileDownload.setRequesterName(activeUser.getName());
                metadataFileDownload.setRequesterMail(activeUser.getEmail());

                metadataFileDownload.setRequesterOrg(activeUser.getOrganisation());
                metadataFileDownload.setRequesterComments("");
                metadataFileDownload.setDownloadDate(new ISODate().toString());
                metadataFileDownload.setUserName(userName);
                metadataFileDownload.setFileUploadId(metadataFileUpload.getId());

                downloadRepository.save(metadataFileDownload);
            }

        } catch (org.springframework.dao.EmptyResultDataAccessException ex) {
            Log.warning(GDS_LOG, "Store file download request: No upload request for (metadataid, file): (" + metadataId + "," + fname + ")");
        }
    }


}
