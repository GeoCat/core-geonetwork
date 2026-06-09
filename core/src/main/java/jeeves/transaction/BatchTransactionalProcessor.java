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
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

package jeeves.transaction;

import com.google.common.collect.Iterables;
import org.springframework.context.ApplicationContext;

import java.util.ArrayList;
import java.util.List;

/**
 * Generic processor for processing items in batches within transactions.
 *
 * @param <T> The type of the items to process.
 */
public class BatchTransactionalProcessor<T> {

    private final String transactionName;
    private final ApplicationContext applicationContext;
    private int batchSize = 100;

    /**
     * Constructor.
     *
     * @param transactionName    The name of the transaction.
     * @param applicationContext The application context.
     */
    public BatchTransactionalProcessor(String transactionName, ApplicationContext applicationContext) {
        this.transactionName = transactionName;
        this.applicationContext = applicationContext;
    }

    /**
     * Sets the batch size.
     *
     * @param batchSize The batch size.
     * @return This processor.
     */
    public BatchTransactionalProcessor<T> setBatchSize(int batchSize) {
        this.batchSize = batchSize;
        return this;
    }

    /**
     * Process items in batches.
     *
     * @param items         The items to process.
     * @param itemProcessor The processor for each item.
     * @throws Exception If an error occurs during processing.
     */
    public void process(Iterable<T> items, BatchItemProcessor<T> itemProcessor) throws Exception {
        process(items, itemProcessor, null);
    }

    /**
     * Process items in batches.
     *
     * @param items         The items to process.
     * @param itemProcessor The processor for each item.
     * @param errorHandler  The error handler for each item.
     * @throws Exception If an error occurs during processing.
     */
    public void process(Iterable<T> items, BatchItemProcessor<T> itemProcessor, BatchItemErrorHandler<T> errorHandler) throws Exception {
        process(items, item -> {
            itemProcessor.process(item);
            return null;
        }, errorHandler, results -> {
            // Nothing to do
        });
    }

    /**
     * Process items in batches and apply results post-commit.
     *
     * @param items            The items to process.
     * @param itemProcessor    The processor for each item that returns a result.
     * @param errorHandler     The error handler for each item.
     * @param postCommitAction The action to perform after the batch has committed.
     * @param <R>              The type of the result.
     * @throws Exception If an error occurs during processing.
     */
    public <R> void process(Iterable<T> items,
                            BatchItemResultProcessor<T, R> itemProcessor,
                            BatchItemErrorHandler<T> errorHandler,
                            BatchPostCommitAction<R> postCommitAction) throws Exception {
        Iterable<List<T>> batches = Iterables.partition(items, batchSize);

        for (final List<T> batch : batches) {
            List<R> results = new ArrayList<>();
            TransactionManager.runInTransaction(transactionName, applicationContext,
                TransactionManager.TransactionRequirement.CREATE_NEW,
                TransactionManager.CommitBehavior.ALWAYS_COMMIT, false, transactionStatus -> {
                    results.clear();
                    for (T item : batch) {
                        try {
                            R result = itemProcessor.process(item);
                            results.add(result);
                        } catch (Exception e) {
                            if (errorHandler != null) {
                                errorHandler.handleError(item, e);
                            } else {
                                throw e;
                            }
                        }
                    }
                    return null;
                });
            postCommitAction.apply(results);
        }
    }
}
