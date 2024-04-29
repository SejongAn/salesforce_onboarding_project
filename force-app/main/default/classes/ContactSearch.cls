/*******************************************************************************
* File Name   : ContactSearch
        * Description : ContactSearch
* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
* Author      : i2max
* Modification Log
* ===============================================================
* Ver  Date        Author            Modification
* ===============================================================
* 1.0  2024.04.20  Yeongeun Kim     create
********************************************************************************/
public with sharing class ContactSearch {
    //입력되는 번호를 기반으로 contact 레코드 검색
    @AuraEnabled(Cacheable=true)
    public static List<Contact> searchPhone(String searchNum) {
        String searchPattern = '%' + searchNum + '%';
        List<Contact> contact = [SELECT Id,Name,Type__c,Phone FROM Contact WHERE PHONE LIKE :searchPattern];
        if(contact.size() > 0){
            return contact;
        } else {
            return null;
        }
    }
}