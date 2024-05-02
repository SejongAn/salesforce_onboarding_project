/*******************************************************************************
* File Name   : CaseController
        * Description : CaseController
* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
* Author      : i2max
* Modification Log
* ===============================================================
* Ver  Date        Author            Modification
* ===============================================================
* 1.0  2024.04.24  Yeongeun Kim     create
********************************************************************************/
public with sharing class CaseController {
    //해당 asset에 related 된 case가 있는지 확인
    @AuraEnabled(Cacheable=true)
    public static List<Case> searchCase(String assetId) {
        List<Case> cases = [SELECT ID,CaseNumber,Subject,Type,Reason,Status,CreatedDate FROM CASE WHERE Asset__c = :assetId]?? null;
        return cases;

    }

    //해당 asset에 대해 case를 생성(Cacheable=true이면 레코드 생성 안됨)
    @AuraEnabled
    public static String insertCase(String Subject,String Description,String Type,String Reason,Id AssetId, Id ContactId) {
            Case newCase = new Case(Subject = Subject, Description = Description, Type = Type, Reason = Reason, Asset__c = AssetId, ContactId = ContactId);
            insert newCase;
            return newCase.Id;
    }
}