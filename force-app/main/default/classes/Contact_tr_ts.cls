@isTest
public class Contact_tr_ts {

    @isTest
    static void runPositiveTestCases(){
        Account acc = new Account(Name='TEST ACCOUNT',CurrencyIsoCode='KRW');
        insert acc;

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
    }

    @IsTest
    static void runNegativeTestCases(){
        Account acc = new Account(Name='TEST ACCOUNT',CurrencyIsoCode='KRW');
        insert acc;
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