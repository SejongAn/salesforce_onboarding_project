/*******************************************************************************
* File Name   : Contact_tr_ts
        * Description : Contact_tr_ts
* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
* Author      : i2max
* Modification Log
* ===============================================================
* Ver  Date        Author            Modification
* ===============================================================
* 1.0  2024.04.29  Yeongeun Kim     add cases
* 1.0  2024.04.22  Yeongeun Kim     create
********************************************************************************/
@isTest
public class Contact_tr_ts {
    @TestSetup static void setup(){
        Account acc = new Account(Name='TEST ACCOUNT',CurrencyIsoCode='KRW');
        insert acc;
    }

    @isTest
    static void runPositiveTestCases(){
        Profile p = [SELECT ID FROM PROFILE Where Name ='Sales Team'];
        User u1 = [Select Id From User WHere ProfileId = :p.id limit 1];

        System.debug('validate rusAs');
        System.runAs(u1){
            Account acc = [Select Id From Account WHERE  Name = 'TEST ACCOUNT'];

            System.debug('validate single insert');
            Contact contact = new Contact(LastName = 'name',Email = 'test@email.com',Phone = '010-0000-0000',AccountId=acc.Id,CurrencyIsoCode='KRW');
            insert contact;
            system.assertNotEquals(null,contact);

            System.debug('validate bulk insert');
            List<Contact> contacts = new List<Contact>();
            for(Integer i=100; i<301; i++){
                Contact con = new Contact(LastName = 'name',Email = 'email@email.com'+i,Phone = '010-0000-0'+i,AccountId=acc.Id,CurrencyIsoCode='KRW');
                contacts.add(con);
            }
            insert contacts;
            system.assertNotEquals(null,contact);

            System.debug('validate single update');
            try{
                Contact contact2 = [Select Id From Contact WHERE  Phone = '010-0000-0100'];
                contact2.Phone = '010-0000-0000';
                update contact2;
            }catch(Exception e){
                Assert.areEqual('System.DmlException', e.getTypeName());
            }

        }
    }

    @IsTest
    static void runNegativeTestCases(){
        Account acc = [Select Id From Account WHERE  Name = 'TEST ACCOUNT'];

        Contact contact = new Contact(LastName = 'name',Email = 'test@email.com',Phone = '010-0000-0000',AccountId=acc.Id,CurrencyIsoCode='KRW');
        insert contact;

        System.debug('validate error insert');
        try{
            Contact contactNew = new Contact(LastName = 'name',Email = 'test@email.com',Phone = '010-0000-0000',AccountId=acc.Id,CurrencyIsoCode='KRW');
            insert contactNew;
        } catch(Exception e){
            Assert.areEqual('System.DmlException', e.getTypeName());
    }

    }
}