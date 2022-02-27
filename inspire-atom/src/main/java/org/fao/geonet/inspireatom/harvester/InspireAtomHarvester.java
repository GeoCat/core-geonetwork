//=============================================================================
//===	Copyright (C) 2001-2010 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================
package org.fao.geonet.inspireatom.harvester;


import jeeves.server.context.ServiceContext;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.EnhancedPatternLayout;
import org.apache.log4j.FileAppender;
import org.fao.geonet.Logger;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.AbstractMetadata;
import org.fao.geonet.inspireatom.harvester.report.InspireAtomHarvesterReport;
import org.fao.geonet.inspireatom.harvester.report.InspireAtomHarvesterReportFeedEntry;
import org.fao.geonet.inspireatom.model.DatasetFeedInfo;
import org.fao.geonet.inspireatom.util.InspireAtomUtil;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.GeonetworkDataDirectory;
import org.fao.geonet.kernel.datamanager.IMetadataUtils;
import org.fao.geonet.kernel.search.EsSearchManager;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.repository.InspireAtomFeedRepository;
import org.fao.geonet.repository.specification.MetadataSpecs;
import org.fao.geonet.utils.Log;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.*;


/**
 * Class to harvest the Atom documents referenced in the iso19139 in the catalog.
 *
 * @author Jose García
 */

@Component
public class InspireAtomHarvester {
    private final static String EXTRACT_DATASETS_FROM_SERVICE_XSLT = "extract-datasetinfo-from-service-feed.xsl";
    private final static String EXTRACT_DATASET_ID_XSLT = "extract-datasetid.xsl";
    private Logger logger = Log.createLogger(Geonet.ATOM);

    @Autowired
    EsSearchManager searchManager;

    @Autowired
    SettingManager sm;

    @Autowired
    DataManager dataMan;

    @Autowired
    InspireAtomFeedRepository repository;

    @Autowired
    IMetadataUtils metadataUtils;

    @Autowired
    InspireAtomHarvesterService inspireAtomHarvesterService;

    @Autowired
    GeonetworkDataDirectory geonetworkDataDirectory;

    /**
     * Process the metadata to check if have an atom document referenced. In this case, the atom
     * document is retrieved and stored in the metadata table.
     */
    public final InspireAtomHarvesterReport harvest() throws Exception {
        initializeLog();

        // Value used in metadata editor for online resources to identify an INSPIRE atom resource
        String atomProtocol = sm.getValue(Settings.SYSTEM_INSPIRE_ATOM_PROTOCOL);

        // Using index information, as type is only available in index and not in database.
        // If retrieved from database retrieves all iso19139 metadata and should apply for each result an xslt process
        // to identify if a service or dataset (slow process)

        List<String> iso19139MetadataUuids = inspireAtomHarvesterService.searchMetadataByTypeAndProtocol(
            "service", atomProtocol, ServiceContext.get());


        final List<? extends AbstractMetadata> iso19139Metadata =
            metadataUtils.findAll(MetadataSpecs.hasMetadataUuidIn(iso19139MetadataUuids));

        InspireAtomHarvesterReport report = new InspireAtomHarvesterReport();

        try {
            logger.info("ATOM feed harvest started");

            // Removes all atom information from existing metadata. Harvester will reload with updated information
            logger.info("ATOM feed harvest: remove existing metadata feeds");
            repository.deleteAll();

            logger.info("ATOM feed harvest: retrieving service metadata feeds");

            // Retrieve the SERVICE metadata referencing atom feed documents
            Map<String, String> serviceMetadataWithAtomFeeds =
                InspireAtomUtil.retrieveServiceMetadataWithAtomFeeds(dataMan, iso19139Metadata, atomProtocol);

            logger.info("ATOM feed harvest: processing service metadata feeds (" + serviceMetadataWithAtomFeeds.size() + ")");

            // Process SERVICE metadata feeds
            //    datasetsInformation stores the dataset information for identifier, namespace and feed url
            //    described in the services feed. This information is not available in the datasets feeds.
            List<DatasetFeedInfo> datasetsInformation =
                inspireAtomHarvesterService.processServiceMetadataFeeds(dataMan, serviceMetadataWithAtomFeeds, report);

            // Process DATASET metadata feeds related to the service metadata
            logger.info("ATOM feed harvest : processing dataset metadata feeds (" + datasetsInformation.size() + ")");
            inspireAtomHarvesterService.processDatasetsMetadataFeeds(dataMan, datasetsInformation, report);

            logger.info("ATOM feed harvest finished");


        } catch (Exception x) {
            logger.error("ATOM feed harvest error: " + x.getMessage());
            logger.error(x);
            report.setError(x.getMessage());
        }

        return report;
    }

    /**
     * Harvest an individual metadata. Used in OpenSearchDescription service to retrieve the atom
     * information for a metadata. Useful if metadata has been created in the catalog since the last
     * periodical harvesting.
     *
     * @param metadataId Metadata identifier
     */
    public final void harvestServiceMetadata(final ServiceContext context, final String metadataId) {
        inspireAtomHarvesterService.harvestServiceMetadata(context, metadataId);
    }

    private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmm");

    private String initializeLog() {

        // configure personalized logger
        String packagename = getClass().getPackage().getName();
        String[] packages = packagename.split("\\.");
        String packageType = packages[packages.length - 1];
        final String harvesterName = "inspireatom";
        logger = Log.createLogger("inspireatom", "geonetwork.atom");

        String directory = logger.getFileAppender();
        if (directory == null || directory.isEmpty()) {
            directory = geonetworkDataDirectory.getSystemDataDir() + "/harvester_logs/";
        }
        File d = new File(directory);
        if (!d.isDirectory()) {
            directory = d.getParent() + File.separator;
        }

        FileAppender fa = new FileAppender();
        fa.setName(harvesterName);
        String logfile = directory + "atomharvester_" + packageType + "_"
            + dateFormat.format(new Date(System.currentTimeMillis()))
            + ".log";
        fa.setFile(logfile);

        String timeZoneSetting = sm.getValue(Settings.SYSTEM_SERVER_TIMEZONE);
        if (StringUtils.isBlank(timeZoneSetting)) {
            timeZoneSetting = TimeZone.getDefault().getID();
        }
        fa.setLayout(new EnhancedPatternLayout("%d{yyyy-MM-dd'T'HH:mm:ss,SSSZ}{" + timeZoneSetting +"} %-5p [%c] - %m%n"));

        fa.setThreshold(logger.getThreshold());
        fa.setAppend(true);
        fa.activateOptions();

        logger.setAppender(fa);

        return logfile;
    }
}
