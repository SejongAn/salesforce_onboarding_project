// <!--*******************************************************************************
//   * File Name   : OpportunityManager.cls
//   * Description : Classes for SOQL usage of oppBaseLwc.
//   * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
//   * Author      : i2max
//   * Modification Log
//   * ===============================================================
//   * Ver  Date        Author            Modification
//   * ===============================================================
//   * 1.0  2024.04.24  Sejong An        Create
// ********************************************************************************-->
public with sharing class OpportunityManager {

    //Account List 가져오기
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String userId) {

        List<Account> accounts = [SELECT Id, Name FROM Account WHERE OwnerId = :userId ORDER BY Name]; //입력된 사용자가 소유한 Account목록 가져오기
        if(accounts.isEmpty()){ //입력된 사용자가 소유한 Account가 없다면
            accounts = [SELECT Id, Name FROM Account ORDER BY Name]; //모든 Account목록 가져오기
        }
        return accounts; //가져온 Account목록 반환
    }   

    //Contact List 가져오기
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        // Contact 객체에서 필요한 필드만 선택하여 가져옵니다.
        return [SELECT Id, Name FROM Contact ORDER BY Name];
    }

    //단순상담 레코드 타입 Oppty 생성
    @AuraEnabled
    public static Id createSimpleConsult(String opportunityName, Id accountId, Date closeDate) {
        try {
            Opportunity newOpportunity = new Opportunity();
            newOpportunity.RecordTypeId = I2ComUtil.getRecordTypeId('Opportunity','SimpleOppty');
            newOpportunity.Name = opportunityName;
            newOpportunity.AccountId = accountId;
            newOpportunity.CloseDate = closeDate;
            newOpportunity.StageName = '단순 상담'; //한글로 되어있음

            insert newOpportunity;
            
            return newOpportunity.Id;
        } catch(Exception e) {
            throw new AuraHandledException('Error creating Opportunity: ' + e.getMessage());
        }
    }

    //첫방문 레코드 타입 Oppty 생성
    @AuraEnabled
    public static Id createRevisitConsult(String opportunityName, Id accountId, Date closeDate, Id contactId) {
        try { 
            Opportunity newOpportunity = new Opportunity();
            newOpportunity.RecordTypeId = I2ComUtil.getRecordTypeId('Opportunity','RePurchaseOppty');
            newOpportunity.Name = opportunityName;
            newOpportunity.AccountId = accountId;
            newOpportunity.CloseDate = closeDate;
            newOpportunity.StageName = '상담';
            newOpportunity.ContactId=contactId;
            newOpportunity.Contact__c=contactId;
            
            System.debug(newOpportunity.Id);
            
            insert newOpportunity;

            return newOpportunity.Id;
        } catch(Exception e) {
            throw new AuraHandledException('Error creating Opportunity: ' + e.getMessage());
        }
    }

    //재방문 레코드 타입 Oppty 생성
    @AuraEnabled
    public static Id createFirstConsult(String opportunityName, Id accountId, Date closeDate, String firstName, String lastName, String phone, String email) {
        try {
            Opportunity newOpportunity = new Opportunity();
            newOpportunity.RecordTypeId = I2ComUtil.getRecordTypeId('Opportunity','FirstPurchaseOppty');
            newOpportunity.Name = opportunityName;
            newOpportunity.AccountId = accountId;
            newOpportunity.CloseDate = closeDate;
            newOpportunity.StageName = '상담';
            newOpportunity.FirstName__c = firstName;
            newOpportunity.LastName__c = lastName;
            newOpportunity.Phone__c = phone;
            newOpportunity.Email__c = email;
            
            insert newOpportunity;
            
            return newOpportunity.Id;

        } catch(Exception e) {
            throw new AuraHandledException('Error creating Opportunity: ' + e.getMessage());
        }
    }
    
}