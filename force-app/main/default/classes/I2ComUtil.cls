//<!--*******************************************************************************
//* File Name   : I2ComUtil.cls
//* Description : Util 메소드를 저장해 재사용성 향상
//* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
//* Author      : i2max
//* Modification Log
//* ===============================================================
//* Ver  Date        Author            Modification
//* ===============================================================
//* 1.0  2024.04.30  Sejong An         Create
//********************************************************************************-->
public inherited sharing class I2ComUtil {

    //SObject와 원하는 Record Type명칭을 입력해주면 해당 RcordType의 Id를 String형태로 되돌려줌
    public static String getRecordTypeId(String objname, String typename){
        String result='';
        for(RecordType rt:[SELECT Id FROM RecordType WHERE SObjectType=:objname AND DeveloperName=:typename]){
            result =  rt.Id;
        }
        return result;
    }

    public static set<String> getAllFields(String objName){
        //Schema.getGlobalDescribe(): 모든 스탠다드 커스텀 오브젝트를 포함한 Map을 반환 합니다.
        Map<String, Schema.SObjectType> completeSchema = Schema.getGlobalDescribe();
        //Map에서 해당 SobjectType형식의 Object을 가져옴
        Schema.SobjectType requiredObject = completeSchema.get(objName);
        //해당 Object의        //정보중       //필드선택//Map형식으로 모든 필드 가져오기
        return requiredObject.getDescribe().fields.getMap().keySet();
    }

    public static set<String> checkRequiredField(String objName ) {

        SObjectType objType = Schema.getGlobalDescribe().get( objName );
        Map < String, Schema.SObjectField > mapFields = objType.getDescribe().fields.getMap();
        //set<String> mapFields = Schema.getGlobalDescribe().get('account').getDescribe().fields.getMap();
        //위 주석처럼 한줄로 작성도 가능

        set<String> results = new set<String>();
        for( String strField : mapFields.keySet() ) {

            SObjectField field = mapFields.get( strField );
            //field.getDescribe(): Returns the describe sObject result for this field.
            //Return Value Type: Schema.DescribeSObjectResult
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            //Nillable이란 값없이 속성만 존재할 수 있는지
            //앞에 fieldResult.isCreateable() && 을 붙여줘도 됨
            //값이 존재해야 하는 필드고, 기본적으로 생성되는 필드가 아니라면
            if ( !fieldResult.isNillable() && !fieldResult.isDefaultedOnCreate() ) {
                results.add(strField);
            }
        }
        return results;

    }
}