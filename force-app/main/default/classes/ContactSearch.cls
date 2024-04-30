/*******************************************************************************
* File Name   : ContactSearch
        * Description : ContactSearch
* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
* Author      : i2max
* Modification Log
* ===============================================================
* Ver  Date        Author            Modification
* ===============================================================
* 1.0  2024.04.20  Yeongeun Kim      Create
* 2.0  2024.04.30  Sejong An         Add searchPhoneWithOffset Method
********************************************************************************/
public with sharing class ContactSearch {

    //입력되는 번호를 기반으로 contact 레코드 검색
    @AuraEnabled(Cacheable=true)
    public static List<Contact> searchPhone(String searchNum) {
        String searchPattern = '%' + searchNum + '%';
        List<Contact> contact = [SELECT Id,Name,Type__c,Phone FROM Contact WHERE PHONE LIKE :searchPattern ORDER BY Name];
        if(contact.size() > 0){
            return contact;
        } else {
            return null;
        }
    }

    public class ContactWrapper {
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Type;
        @AuraEnabled
        public String Phone;
        @AuraEnabled
        public Integer RowNum;
    }

    @AuraEnabled(Cacheable=true)
    public static List<ContactWrapper> searchPhoneWithOffset(String searchNum, Integer pageNum, Integer recordPerPage) {

        String searchPattern = '%' + searchNum + '%';
        Integer firstPageNum = pageNum*recordPerPage-recordPerPage;

        List<AggregateResult> results = [SELECT COUNT(Id) numContacts FROM Contact];
        Integer contactCount = (Integer)results[0].get('numContacts');
 
        if(contactCount < firstPageNum + recordPerPage-1){
            recordPerPage = contactCount - firstPageNum;
        }
        
        List<ContactWrapper> contacts = new List<ContactWrapper>();

        for(Contact con: [SELECT Id,Name,Type__c,Phone FROM Contact WHERE PHONE LIKE :searchPattern ORDER BY Name Limit :recordPerPage offset :firstPageNum]){
            firstPageNum+=1;
            
            ContactWrapper conwrap = new ContactWrapper();
            conwrap.Id = con.Id;
            conwrap.Name = con.Name;
            conwrap.Type = con.Type__c;
            conwrap.Phone = con.Phone;
            conwrap.RowNum = firstPageNum;
            contacts.add(conwrap);
        }
        return contacts;
    }

}

