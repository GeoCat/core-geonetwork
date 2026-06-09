/*
 * Copyright (C) 2001-2026 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme de Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

package org.fao.geonet.api.processing.report;

import org.fao.geonet.events.history.RecordUpdatedEvent;
import org.springframework.context.ApplicationContext;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Result of processing a single metadata edit, to be applied to the report later.
 */
public class BatchEditMetadataItemResult extends SimpleMetadataProcessingReport {
    private List<RecordUpdatedEvent> events = new ArrayList<>();

    public void addEvent(RecordUpdatedEvent event) {
        events.add(event);
    }

    public void applyTo(SimpleMetadataProcessingReport mainReport, ApplicationContext appContext) {
        for (int i = 0; i < this.processedRecords; i++) {
            mainReport.incrementProcessedRecords();
        }
        for (int i = 0; i < this.nullRecords; i++) {
            mainReport.incrementNullRecords();
        }
        for (int i = 0; i < this.unchangedRecords; i++) {
            mainReport.incrementUnchangedRecords();
        }
        for (Integer id : this.metadata) {
            mainReport.addMetadataId(id);
        }
        for (Integer id : this.notFound) {
            mainReport.addNotFoundMetadataId(id);
        }
        for (Integer id : this.notEditable) {
            mainReport.addNotEditableMetadataId(id);
        }

        for (Map.Entry<Integer, List<Report>> entry : this.metadataErrors.entrySet()) {
            for (Report report : entry.getValue()) {
                mainReport.addMetadataError(entry.getKey(), report.getUuid(), report.isDraft(), report.isApproved(), report.getMessage());
            }
        }
        for (Map.Entry<Integer, List<InfoReport>> entry : this.metadataInfos.entrySet()) {
            for (InfoReport report : entry.getValue()) {
                mainReport.addMetadataInfos(entry.getKey(), report.getUuid(), report.isDraft(), report.isApproved(), report.getMessage());
            }
        }

        for (RecordUpdatedEvent event : events) {
            event.publish(appContext);
        }
    }
}
