/*
*******************************************************************************
  * File Name   : OrderQueryBatch_ba_ts.cls
  * Description : OrderQueryBatch_ba_ts in cls
  * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
  * Author      : i2max
  * Modification Log
  * ===============================================================
  * Ver  Date        Author            Modification
  * ===============================================================
  * 1.0  2024.04.29  JaeHwan Lee        Create
********************************************************************************
*/
@isTest
public class OrderQueryBatch_ba_ts {

    @TestSetup
    static void createTestContact() {
        // 테스트용 Account 생성
        Account testAccount = new Account(Name = 'Test Account ');
        insert testAccount;

        Contact a = new Contact(
                LastName = 'Test Contact ', // Contact 필드는 LastName이 필요
                Phone = '010-5154-2354',
                Email = 'wejnwe@aownoi.com',
                CurrencyIsoCode = 'KRW',
                AccountId = testAccount.Id // 생성된 테스트 Account의 ID를 할당

        );
        insert a;

        Order o = new Order(
                AccountId = testAccount.Id,
                EffectiveDate = System.today(),
                Contact__c = a.Id,
                Status = 'Order',
                Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;
        // 테스트용 Product2 생성 (가정)
        Product2 testProduct = new Product2(
                Name = 'Test Product',
                Family = 'Laptop'
        );
        insert testProduct;

        // 테스트용 PricebookEntry 생성
        PricebookEntry testPricebookEntry = new PricebookEntry(
                Product2Id = testProduct.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 100.00,
                IsActive = true
        );
        insert testPricebookEntry;

        // 테스트용 OrderItem 생성
        OrderItem testOrderItem = new OrderItem(
                OrderId = o.Id,
                PricebookEntryId = testPricebookEntry.Id,
                Quantity = 1,
                UnitPrice = testPricebookEntry.UnitPrice
        );
        insert testOrderItem;
    }

    @IsTest
    static void testProcessing() {
        // 테스트 실행 코드
        OrderQueryBatch_ba batch = new OrderQueryBatch_ba();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        // 업데이트된 데이터 검증
        List<Contact> updatedContacts = [SELECT Id, LastName, Laptop_Purchase_Amount__c FROM Contact];
        System.assertEquals(100, updatedContacts.get(0).Laptop_Purchase_Amount__c, 'There should be 100 Laptop_Purchase_Amount__c.');
        System.debug(updatedContacts.get(0).Laptop_Purchase_Amount__c);
        // 추가적인 assert문을 포함하여 변경된 데이터가 기대한대로 업데이트 되었는지 확인
    }
}