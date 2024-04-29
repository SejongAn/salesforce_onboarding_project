// <!--*******************************************************************************
//   * File Name   : OpportunityManager.cls
//   * Description : Classes for SOQL usage of oppBaseLwc.
//   * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
//   * Author      : SejongAn
//   * Modification Log
//   * ===============================================================
//   * Ver  Date        Author            Modification
//   * ===============================================================
//   * 1.0  2024.04.24  Sejong An        Create
// ********************************************************************************-->
public with sharing class OpportunityManager {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String userId) {

        List<Account> accounts = [SELECT Id, Name FROM Account WHERE OwnerId = :userId ORDER BY Name];
        if(accounts.isEmpty()){
            accounts = [SELECT Id, Name FROM Account ORDER BY Name];
        }
        return accounts;
    }   

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        // Contact 객체에서 필요한 필드만 선택하여 가져옵니다.
        return [SELECT Id, Name FROM Contact ORDER BY Name];
    }

    @AuraEnabled
    public static Id createSimpleConsult(String opportunityName, Id accountId, Date closeDate) {
        try {
            // Opportunity 객체 생성
            Opportunity newOpportunity = new Opportunity();
            newOpportunity.RecordTypeId = '012IT000000Ot0zYAC';
            newOpportunity.Name = opportunityName;
            newOpportunity.AccountId = accountId;
            newOpportunity.CloseDate = closeDate;
            newOpportunity.StageName = '단순 상담';

            insert newOpportunity;
            
            return newOpportunity.Id;
        } catch(Exception e) {
            throw new AuraHandledException('Error creating Opportunity: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Id createRevisitConsult(String opportunityName, Id accountId, Date closeDate, Id contactId) {
        try { 
            Opportunity newOpportunity = new Opportunity();
            newOpportunity.RecordTypeId = '012IT000000Ot1EYAS';
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

    @AuraEnabled
    public static Id createFirstConsult(String opportunityName, Id accountId, Date closeDate, String firstName, String lastName, String phone, String email) {
        try {
            Opportunity newOpportunity = new Opportunity();
            newOpportunity.RecordTypeId = '012IT000000Ot14YAC';
            newOpportunity.Name = opportunityName;
            newOpportunity.AccountId = accountId;
            newOpportunity.CloseDate = closeDate;
            newOpportunity.StageName = '상담';
            // newOpportunity.ContactId = newContact.Id;
            // newOpportunity.Contact__c = newContact.Id;
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