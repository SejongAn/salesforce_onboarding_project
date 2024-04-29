global class OrderQueryBatch_ba implements Database.Batchable<sObject>{
/*
*******************************************************************************
  * File Name   : OrderQueryBatch_ba.cls
  * Description : OrderQueryBatch_ba in cls 
  * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
  * Author      : i2max
  * Modification Log
  * ===============================================================
  * Ver  Date        Author            Modification
  * ===============================================================
  * 1.0  2024.04.26  JaeHwan Lee        Create
********************************************************************************
*/
    // Stateful로 선언하여 배치 실행 동안 상태 정보(예: 총합)를 유지합니다.

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // 모든 Contact를 처리하도록 쿼리
        return Database.getQueryLocator([
            SELECT Id
            FROM Contact
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        // 각 Contact에 대해 주문을 확인하고 합계를 계산
        Map<Id, Decimal> sumLaptopsByContact = new Map<Id, Decimal>();
        Map<Id, Decimal> sumAccessoriesByContact = new Map<Id, Decimal>();

        // Contact ID 목록 준비
        List<Id> contactIds = new List<Id>();
        for (Contact c : scope) {
            contactIds.add(c.Id);
            sumLaptopsByContact.put(c.Id, 0);
            sumAccessoriesByContact.put(c.Id, 0);
        }

        // 랩탑 주문 쿼리
        for (Order o : [
            SELECT Id, Contact__c, 
                   (SELECT Product2Id, Quantity, TotalPrice 
                    FROM OrderItems 
                    WHERE Product2.Family = 'Laptop'
                    AND Order.Status = 'Order'
                    AND Order.EffectiveDate >= LAST_N_DAYS:90)
            FROM Order
            WHERE Contact__c IN :contactIds
            AND EffectiveDate >= LAST_N_DAYS:90
        ]) {
            for (OrderItem oi : o.OrderItems) {
                sumLaptopsByContact.put(o.Contact__c, sumLaptopsByContact.get(o.Contact__c) + oi.TotalPrice);
            }
        }

        // 액세서리 주문 쿼리
        for (Order o : [
            SELECT Id, Contact__c, 
                   (SELECT Product2Id, Quantity, TotalPrice 
                    FROM OrderItems 
                    WHERE Product2.Family = 'Accessory'
                    AND Order.Status = 'Order'
                    AND Order.EffectiveDate >= LAST_N_DAYS:90)
            FROM Order
            WHERE Contact__c IN :contactIds
            AND EffectiveDate >= LAST_N_DAYS:90
        ]) {
            for (OrderItem oi : o.OrderItems) {
                sumAccessoriesByContact.put(o.Contact__c, sumAccessoriesByContact.get(o.Contact__c) + oi.TotalPrice);
            }
        }

        // Contact 레코드 업데이트
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Id contactId : contactIds) {
            Contact contact = new Contact(
                Id = contactId,
                Laptop_Purchase_Amount__c = sumLaptopsByContact.get(contactId),
                Accessory_Purchase_Amount__c = sumAccessoriesByContact.get(contactId),
                Purchase_Amount__c = sumLaptopsByContact.get(contactId) + sumAccessoriesByContact.get(contactId)
            );
            contactsToUpdate.add(contact);
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}