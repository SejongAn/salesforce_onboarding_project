global class OrderQueryBatchScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        OrderQueryBatch batchJob = new OrderQueryBatch();
        Database.executeBatch(batchJob, 200);
    }
}