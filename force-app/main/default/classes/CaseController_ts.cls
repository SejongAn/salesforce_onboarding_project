/*******************************************************************************
* File Name   : CaseController_ts
        * Description : CaseController_ts
* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
* Author      : i2max
* Modification Log
* ===============================================================
* Ver  Date        Author            Modification
* ===============================================================
* 1.0  2024.04.30  Yeongeun Kim     create
********************************************************************************/
@IsTest
public with sharing class CaseController_ts {

    @TestSetup
    static void setup(){
        Account acc = new Account(Name='TEST ACCOUNT',CurrencyIsoCode='KRW');
        insert acc;
        Contact contact = new Contact(LastName='test',Email='test@user.com',Phone='010-1111-1111',CurrencyIsoCode='KRW', AccountId=acc.Id);
        insert contact;
        Asset asset = new Asset(Name='testAsset',ContactId=contact.id);
        insert asset;
    }

    @IsTest
    static void positiveTest(){
        System.debug('validation single case');
        Asset ass = [SELECT Id, ContactId FROM Asset WHERE Contact.LastName='test'];
        String caseId = CaseController.insertCase('Subject','Description','AS','교체',ass.Id,ass.ContactId);
        Case testCase = [SELECT ID FROM CASE WHERE Asset__c = :ass.Id];
        System.assertEquals(testCase.Id,caseId);

        List<Case> liCase = CaseController.searchCase(ass.Id);
        System.assertNotEquals(liCase,null);

    }

}