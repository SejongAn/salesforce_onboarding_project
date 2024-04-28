trigger Contact_tr on Contact (before insert,before update) {
    //contact을 생성, 업데이트 시 Phone 필드의 중복 여부 체크
    if(Trigger.isInsert){
        ContactValidate.contactValidate(Trigger.new);
    } else if(Trigger.isUpdate){
        List<Contact> con = new List<Contact>();
        for(Contact contact:Trigger.new){
            if(contact.Phone != Trigger.oldMap.get(contact.Id).Phone){
                 con.add(contact);
        }
            }
            ContactValidate.contactValidate(con);
        }
}