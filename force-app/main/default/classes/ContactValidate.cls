public with sharing class ContactValidate {
    //contact phone 필드에 대한 validation 체크
    public static void contactValidate(List<Contact> contacts) {
        Set<String> phone = new Set<String>();
        List<Contact> cons = [SELECT Phone FROM Contact];
        for(Contact con:cons){
            phone.add(con.Phone);
        }

        for(Contact contact:contacts){
            if(phone.contains(contact.Phone)){
                contact.adderror('Phone','Phone number already has been');
            }
        }
    }
}