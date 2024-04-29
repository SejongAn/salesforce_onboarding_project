/*
*******************************************************************************
  * File Name   : OrderQueryBatchScheduler_sc.cls
  * Description : OrderQueryBatchScheduler_sc in cls 
  * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
  * Author      : i2max
  * Modification Log
  * ===============================================================
  * Ver  Date        Author            Modification
  * ===============================================================
  * 1.0  2024.04.26  JaeHwan Lee        Create
********************************************************************************
*/
global class OrderQueryBatchScheduler_sc implements Schedulable {
    global void execute(SchedulableContext SC) {
        OrderQueryBatch batchJob = new OrderQueryBatch();
        Database.executeBatch(batchJob, 200);
    }
}