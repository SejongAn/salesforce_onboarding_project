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
* 2.0  2024.04.30  Sejong An         Add searchPhoneWithOffset method
* 2.1  2024.05.03  Sejong An         searchPhoneWithOffset method Modification
********************************************************************************/
public with sharing class ContactSearch {

    //입력되는 번호를 기반으로 contact 레코드 검색
    @AuraEnabled(Cacheable=true)
    public static List<Contact> searchPhone(String searchNum) {
        String searchPattern = '%' + searchNum + '%';
        List<Contact> contact = [SELECT Id,Name,Type__c,Phone FROM Contact WHERE PHONE LIKE :searchPattern ORDER BY Name]?? null;
        return contact;
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
        @AuraEnabled
        public Integer pageNum;
    }

    @AuraEnabled(Cacheable=true)
    public static List<ContactWrapper> searchPhoneWithOffset(String searchNum, Integer pageNum, Integer recordPerPage) {

        //총 Contact수 계산
        Integer contactCount = I2ComUtil.getNumberOfObject('Contact','Phone',searchNum);
        System.debug('pageNum: ' + pageNum);
        //pageNum이 0이면 1page로 재이동 할 수 있게
        if(pageNum<1){
            pageNum=1;
        }
        //pageNum이 총 레코드 수를 벗어난 범위로 이동 안되게
        System.debug('cal: ' + recordPerPage*(pageNum-1) + '>=' + contactCount);
        if(recordPerPage*(pageNum-1)>=contactCount){
            pageNum-=1;
            System.debug('pageNum Down: ' + pageNum);
        }

        String searchPattern = '%' + searchNum + '%';
        Integer firstPageNum = pageNum*recordPerPage-recordPerPage;

        if(contactCount < firstPageNum + recordPerPage-1){
            recordPerPage = contactCount - firstPageNum;
        }
        
        List<ContactWrapper> contacts = new List<ContactWrapper>();
        Integer i=1;
        for(Contact con: [SELECT Id,Name,Type__c,Phone FROM Contact WHERE PHONE LIKE :searchPattern ORDER BY Name Limit :recordPerPage offset :firstPageNum]){
            firstPageNum+=1;
            
            ContactWrapper conwrap = new ContactWrapper();
            conwrap.Id = con.Id;
            conwrap.Name = con.Name;
            conwrap.Type = con.Type__c;
            conwrap.Phone = con.Phone;
            conwrap.RowNum = firstPageNum;
            if(i==1){
                conwrap.pageNum=pageNum;
                i++;
            }
            contacts.add(conwrap);
        }
        return contacts;
    }
}