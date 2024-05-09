/*******************************************************************************
 File Name   : OppTopProductController_ts
* Description : Test Class for OppTopProductController.cls
* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
* Author      : i2max
* Modification Log
* ===============================================================
* Ver  Date        Author            Modification
* ===============================================================
* 1.0  2024.05.02  Byeonghak Lim     create
********************************************************************************/
@IsTest
public with sharing class OppTopProductController_ts {

    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'TEST ACCOUNT', Type = 'US');
        insert acc;

        Contact con = new Contact(LastName = 'test', Email = 'test@user.com', Phone = '010-1111-1111', CurrencyIsoCode = 'USD', AccountId = acc.Id);
        insert con;

        Opportunity opp = new Opportunity(Name = 'TEST', AccountId = acc.Id, CloseDate = System.today(),
                ContactId = con.Id, StageName = '상담', CurrencyIsoCode = 'USD');
        insert opp;

        Order odr = new Order(AccountId = acc.Id, EffectiveDate = System.today(), Contact__c = con.Id, Status = 'Order');
        insert odr;


        List<Product2> lapToInsert = new List<Product2>();
        List<Product2> accToInsert = new List<Product2>();

        for (Integer i = 1; i <= 6; i++) {
            Product2 product = new Product2(Name = 'lap' + i, Family = 'laptop', IsActive = true);
            lapToInsert.add(product);
        }

        for (Integer i = 1; i <= 6; i++) {
            Product2 product = new Product2(Name = 'acc' + i, Family = 'accessory', IsActive = true);
            accToInsert.add(product);
        }
        insert lapToInsert;
        insert accToInsert;

////////////////////////////////////////////        /   ////////////////

        List<Asset> lapAsset = new List<Asset>();
        List<Asset> accAsset = new List<Asset>();

        List<Product2> asset1 = [SELECT Id, Name FROM Product2 WHERE Family = 'laptop' ORDER BY Name ASC];
        List<Product2> asset2 = [SELECT Id, Name FROM Product2 WHERE Family = 'accessory' ORDER BY Name ASC];



// Product와 관련된 Asset 생성
        for (Product2 pdt : asset1) {
            String numPart;
            numPart = pdt.Name.substring(3); // 'lap'를 제거
            Integer pdtNum = Integer.valueOf(numPart);
            for (Integer i = 1; i <= pdtNum; i++) {
                Asset asset = new Asset(Name = 'Test Asset ' + i,
                        Product2Id = pdt.Id,
                        AccountId = acc.Id, // 이 acc.Id는 당신이 미리 설정해둔 Account의 Id를 가정합니다.
                        Refund_availability__c = false);
                lapAsset.add(asset);
            }
        }
        for (Product2 pdt : asset2) {
            String numPart;
            numPart = pdt.Name.substring(3); // 'acc'를 제거
            Integer pdtNum = Integer.valueOf(numPart);
            for (Integer i = 1; i <= pdtNum; i++) {
                Asset asset = new Asset(Name = 'Test Asset ' + i,
                        Product2Id = pdt.Id,
                        AccountId = acc.Id, // 이 acc.Id는 당신이 미리 설정해둔 Account의 Id를 가정합니다.
                        Refund_availability__c = false);
                accAsset.add(asset);
            }
        }

        insert lapAsset;
        insert accAsset;

        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;


        Id standardPriceBookId = Test.getStandardPricebookId();

        List<PriceBookEntry> lapEntry = new List<PriceBookEntry>();
        List<PriceBookEntry> accEntry = new List<PriceBookEntry>();


        for (Product2 pdId : asset1) {
            String numPart;
            numPart = pdId.Name.substring(3);// 'lap'를 제거
            Integer pdtNum = Integer.valueOf(numPart);
            PriceBookEntry pbe1 = new PriceBookEntry(Product2Id = pdId.Id, PriceBook2Id = standardPriceBookId,
                    CurrencyIsoCode = 'USD', UnitPrice = 100 + pdtNum, IsActive = true);
            lapEntry.add(pbe1);
        }

        for (Product2 pdId : asset2) {
            String numPart;
            numPart = pdId.Name.substring(3); // 'acc'를 제거
            Integer pdtNum = Integer.valueOf(numPart);
            PriceBookEntry pbe1 = new PriceBookEntry(Product2Id = pdId.Id, PriceBook2Id = standardPriceBookId,
                    CurrencyIsoCode = 'USD', UnitPrice = 100 + pdtNum, IsActive = true);
            accEntry.add(pbe1);
        }
        insert lapEntry;
        insert accEntry;

    }

    @IsTest
    static void positiveTest() {

        Account accTest = [SELECT Type FROM Account WHERE Name = 'TEST ACCOUNT'];
        Opportunity oppTest = [SELECT Id FROM Opportunity WHERE Name = 'TEST'];
        System.assertEquals(accTest.Type, OppTopProductController.getAccountType(oppTest.Id));

        List<Product2> allProduct = new List<Product2>();
        for (Product2 lapAdd : [SELECT Name, Family FROM Product2 WHERE Family = 'laptop' ORDER BY Name DESC LIMIT 5]){
            allProduct.add(lapAdd);
        }
        for (Product2 accAdd : [SELECT Name, Family FROM Product2 WHERE Family = 'accessory' ORDER BY Name DESC LIMIT 5]){
            allProduct.add(accAdd);
        }

        List<PriceBookEntry> entrytest = new List<PriceBookEntry>();
        List<OppTopProductController.ProductInfo> actual = new List<OppTopProductController.ProductInfo>();

        for (Product2 pdt : allProduct){
            PriceBookEntry matchingEntry = [SELECT Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id =: pdt.Id];
            entrytest.add(matchingEntry);
        }

        for (Integer i=0; i<10; i++){
            OppTopProductController.ProductInfo test1 = new OppTopProductController.ProductInfo(allProduct[i].Id, allProduct[i].Name, entrytest[i].UnitPrice, allProduct[i].Family);
            actual.add(test1);
        }

        List<OppTopProductController.ProductInfo> fromClass = OppTopProductController.getTopProducts(oppTest.Id);

        for (Integer i=0; i<10; i++){
            System.assertEquals(actual[i].Id, fromClass[i].Id);

        }


    }
}