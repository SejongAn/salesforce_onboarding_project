/*******************************************************************************
 File Name   : OppGetOrderAsset_ts
* Description : Test Class for OppGetOrderAsset.cls
* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
* Author      : i2max
* Modification Log
* ===============================================================
* Ver  Date        Author            Modification
* ===============================================================
* 1.0  2024.05.02  Byeonghak Lim     create
********************************************************************************/
@IsTest
public with sharing class OppGetOrderAsset_ts {


    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'TEST ACCOUNT', Type = 'KOR');
        insert acc;

        Contact con = new Contact(LastName = 'test', Email = 'test@user.com', Phone = '010-1111-1111', CurrencyIsoCode = 'KRW', AccountId = acc.Id);
        insert con;

//        RecordTypeId = 'RePurchaseOppty',
        Opportunity opp = new Opportunity(Name = 'TEST', CloseDate = System.today(), ContactId = con.Id,
                                             StageName = '상담');
        insert opp;



        Order odr = new Order(
                AccountId = acc.Id,
                EffectiveDate = System.today(),
                Contact__c = con.Id,
                Status = 'Order');
        insert odr;

        Asset asst = new Asset(
                Name = '그램1',
                AccountId = acc.Id,
                SerialNumber = '695364_1714018328508',
                Order__c = odr.Id,
                ContactId = con.Id,
                Price = 1000000,
                PurchaseDate = System.today()
        );
        insert asst;


    }

    @IsTest
    static void positiveTest(){
        System.debug('teststst');
        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE Name = 'TEST' LIMIT 1];
        List<Order> Orddder = OppGetOrderAsset.getOrders(opp1.Id);
        System.assertNotEquals(null, Orddder);

        Order testorder = [SELECT Id FROM Order WHERE Status = 'Order' LIMIT 1];

        List<Asset> testasset = [SELECT Id FROM Asset WHERE Name = '그램1'];

        System.assertNotEquals(testasset, OppGetOrderAsset.getAssets(testorder.id));
    }


}