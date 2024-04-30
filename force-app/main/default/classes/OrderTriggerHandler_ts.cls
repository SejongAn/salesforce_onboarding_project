/**
 * Created by ijaehwan on 24. 4. 29..
 */
@IsTest
private class OrderTriggerHandler_ts {

    @TestSetup
    static void createTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact a = new Contact(
                LastName = 'Test Contact',
                Phone = '010-5154-2354',
                Email = 'wejnwe@aownoi.com',
                CurrencyIsoCode = 'KRW',
                AccountId = testAccount.Id,
                Purchasing_Account__c = testAccount.Id
        );
        insert a;

        Opportunity opp = new Opportunity(
                Name = 'Test Opp',
                StageName = 'Purchase',
                Contact__c = a.Id,
                CloseDate = Date.today().addDays(30),
                AccountId = testAccount.Id
        );
        insert opp;

        Product2 testProduct = new Product2(
                Name = 'Test Product',
                Family = 'Laptop'
        );
        insert testProduct;

        PricebookEntry testPricebookEntry = new PricebookEntry(
                Product2Id = testProduct.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 100.00,
                IsActive = true
        );
        insert testPricebookEntry;

        Order o = new Order(
                AccountId = testAccount.Id,
                EffectiveDate = System.today(),
                Contact__c = a.Id,
                Status = 'Order',
                Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;

        OrderItem testOrderItem = new OrderItem(
                OrderId = o.Id,
                PricebookEntryId = testPricebookEntry.Id,
                Quantity = 1,
                UnitPrice = testPricebookEntry.UnitPrice
        );
        insert testOrderItem;

        Asset assetTest = new Asset(
                Name = '그램1',
                CurrencyIsoCode = 'KRW',
                SerialNumber = '695364_1714018328508',
                Product2Id = testProduct.Id,
                Order__c = o.Id,
                ContactId = a.Id,
                Price = 10000,
                PurchaseDate = System.today()
        );
        insert assetTest;
    }

    @IsTest
    static void testOrderInsertion() {
        Test.startTest();
        // Query the test data created by @TestSetup
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact a = [SELECT Id FROM Contact WHERE Email = 'wejnwe@aownoi.com' LIMIT 1];
        
/*
        Order oldOrder = new Order(
                AccountId = testAccount.Id,
                EffectiveDate = System.today(),
                Contact__c = a.Id,
                Status = 'Order',
                DiscountRate__c = 2, // Assuming DiscountRate__c is a custom field
                Pricebook2Id = Test.getStandardPricebookId()
        );
        update oldOrder;

        Test.stopTest();
*/
        // Asserts or further validations can be performed here
    }
}