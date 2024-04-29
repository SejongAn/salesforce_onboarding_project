/*******************************************************************************
* File Name   : Contact_tr
        * Description : Contact_tr
* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
* Author      : i2max
* Modification Log
* ===============================================================
* Ver  Date        Author            Modification
* ===============================================================
* 1.0  2024.04.29  Yeongeun Kim     apply triggerFramework
* 1.0  2024.04.23  Yeongeun Kim     create
********************************************************************************/
public with sharing class Contact_tr extends TriggerHandler{

    public override void beforeInsert(){
        validationCheck(Trigger.new);
    }

    public override void beforeUpdate(){
        //이전 value와 같지 않을 때만 check
        List<Contact> con = new List<Contact>();
        Map<Id,Contact> oldCon = (Map<Id,Contact>)Trigger.oldMap;
        for(Contact contact:(List<Contact>)Trigger.new){
            if(contact.Phone != oldCon.get(contact.Id).Phone){
                con.add(contact);
            }
        if(!con.isEmpty()){
            validationCheck(con);
            }
        }
    }

    //contact phone 필드에 대한 validation check
    private void validationCheck(List<Contact> contacts) {
        Set<String> phone = new Set<String>();
        List<Contact> cons = [SELECT Phone FROM Contact];
        for(Contact con:cons){
            phone.add(con.Phone);
        }

        for(Contact contact:contacts){
            if(phone.contains(contact.Phone)){
                contact.adderror('Phone',System.Label.COM_PHONE_VALIDATION);
            }
        }
    }
}