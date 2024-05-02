//   * File Name   : OpportunityManager_ts.cls
//   * Description :
//   * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
//   * Author      : i2max
//   * Modification Log
//   * ===============================================================
//   * Ver  Date        Author            Modification
//   * ===============================================================
//   * 1.0  2024.04.30  Sejong An        Create
// ********************************************************************************-->
@IsTest
private class OpportunityManager_ts {

    @TestSetup
    static void setup(){
        List<SObject> objects = new List<SObject>();

        String profileName ='HQ Team';
        String userId = OpportunityManager_ts_Util.getUserIdFromProfile(profileName);
        Account acct = new Account(Name='testAccount1',OwnerId=userId);
        Contact cont = new Contact(LastName='testContact');
        objects.add(acct);
        objects.add(cont);
        insert objects;
    }

    //createRevisitConsult(String opportunityName, Id accountId, Date closeDate, Id contactId)
    //createFirstConsult(String opportunityName, Id accountId, Date closeDate, String firstName, String lastName, String phone, String email)

    @IsTest
    static void getAccounts1() {
        String profileName ='System Administrator';
        String userId = OpportunityManager_ts_Util.getUserIdFromProfile(profileName);
        List<Account> accList =OpportunityManager.getAccounts(userId);
        System.assertEquals(true,!accList.isEmpty());
    }

    @IsTest
    static void getContacts1(){
        List<Contact> conList =OpportunityManager.getContacts();
        System.assertEquals(true,!conList.isEmpty());
    }

    @IsTest
    static void createSimpleConsultTest(){
        Id accId = OpportunityManager_ts_Util.getAccountId();
        Id oppId = OpportunityManager.createSimpleConsult('SimpleOppty', accId, date.today());
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        System.assertEquals(true,!oppList.isEmpty());
    }

    @IsTest
    static void createSimpleConsultExpTest(){
        Id wrongId = OpportunityManager_ts_Util.getContactId();
        try{
            Id oppId = OpportunityManager.createSimpleConsult('SimpleOppty', wrongId, date.today());
        }catch (Exception e){
            System.debug('Expected Error');
        }
    }

    @IsTest
    static void createRevisitConsultTest(){
        Id accId = OpportunityManager_ts_Util.getAccountId();
        Id conId = OpportunityManager_ts_Util.getContactId();
        Id oppId = OpportunityManager.createRevisitConsult('RevisitOppty',accId, date.today(), conId);
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        System.assertEquals(true,!oppList.isEmpty());
    }

    @IsTest
    static void createRevisitConsultExpTest(){
        Id wrongId = OpportunityManager_ts_Util.getContactId();
        Id conId = OpportunityManager_ts_Util.getContactId();
        try {
            Id oppId = OpportunityManager.createRevisitConsult('RevisitOppty',wrongId, date.today(), conId);
        }catch (Exception e){
        System.debug('Expected Error');
        }
    }


    @IsTest
    static void createFirstConsultTest(){
        Id accId = OpportunityManager_ts_Util.getAccountId();
        Id oppId = OpportunityManager.createFirstConsult('FirstOppty', accId, date.today(), 'firstname', 'lastname', '010-1111-1111', 'i2css@i2max.co.kr');
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        System.assertEquals(true,!oppList.isEmpty());
    }

    @IsTest
    static void createFirstConsultExpTest() {
        Id wrongId = OpportunityManager_ts_Util.getContactId();
        try {
            Id oppId = OpportunityManager.createFirstConsult('FirstOppty', wrongId, date.today(), 'firstname', 'lastname', '010-1111-1111', 'i2css@i2max.co.kr');
        }catch (Exception e){
            System.debug('Expected Error');
        }
    }
}