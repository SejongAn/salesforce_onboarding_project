/*******************************************************************************
* File Name   : ContactSearch_ts
        * Description : ContactSearch_ts
* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
* Author      : i2max
* Modification Log
* ===============================================================
* Ver  Date        Author            Modification
* ===============================================================
* 1.0  2024.04.29  Yeongeun Kim     create
* 1.1  2024.05.02  Sejong An        Add searchPhoneWithOffsetTest1 method for searchPhoneWithOffset method test
********************************************************************************/


@IsTest
public with sharing class ContactSearch_ts {
    @TestSetup
    static void setup(){
        Account acc = new Account(Name='TEST ACCOUNT',CurrencyIsoCode='KRW');
        insert acc;
        Contact contact = new Contact(LastName = 'name',Email = 'test@email.com',Phone = '010-7777-7777',AccountId=acc.Id,CurrencyIsoCode='KRW');
        insert contact;
    }

    @IsTest
    static void positiveTest(){
        List<Contact> contacts = ContactSearch.searchPhone('7777');
        for(Contact contact:contacts){
            system.assertEquals('name',contact.Name);
        }
    }

    @IsTest
    static void searchPhoneWithOffsetTest1(){
        List<ContactSearch.ContactWrapper> contacts = ContactSearch.searchPhoneWithOffset('7777',1,5);
        for(ContactSearch.ContactWrapper c : contacts){
            system.assertEquals('name',c.Name);
        }
    }


}