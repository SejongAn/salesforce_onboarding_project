@isTest
public class Contact_tr_ts {

    @isTest
    public static void test(){
       List<Contact> contacts = new List<Contact>();
    	for(Integer i=0; i<500; i++){
        	Contact con = new Contact(LastName = 'name',Email = 'email@email.com'+i,Phone = '010-0000-0000'+i,AccountId='001IT00002pqCHcYAM',CurrencyIsoCode='KRW');
            contacts.add(con);
   	 }
        insert contacts;
    }
    
}