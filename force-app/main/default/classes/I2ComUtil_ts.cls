//   * File Name   : I2ComUtil_ts.cls
//   * Description :
//   * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
//   * Author      : i2max
//   * Modification Log
//   * ===============================================================
//   * Ver  Date        Author            Modification
//   * ===============================================================
//   * 1.0  2024.04.24  Sejong An        Create
// ********************************************************************************-->
@IsTest
private class I2ComUtil_ts {

    @TestSetup
    static void setup(){
        Contact con = new Contact(LastName='kim',Phone='010-2345-2312');
        insert con;
    }

    @IsTest
    static void getRecordTypeId() {
        String recordTypeId = I2ComUtil.getRecordTypeId('Opportunity','SimpleOppty');
        System.assertEquals(true,recordTypeId.length()>0);
    }

    @IsTest
    static void getAllFields1(){
        set<String> fieldSet1 = I2ComUtil.getAllFields('Account');

        System.assertEquals(true,fieldSet1.contains('id'));

    }


    @IsTest
    static void checkRequiredField1(){
        set<String> fieldSet1 = I2ComUtil.checkRequiredField('Account');

        System.assertEquals(true,fieldSet1.contains('name'));
    }

    //public static Integer getNumberOfObject(String objectName, String fieldName, String searchWord)
    @IsTest
    static void  getNumberOfObjectTest(){
        Integer num = I2ComUtil.getNumberOfObject('Contact','Phone','010');
        System.assertEquals(1,num);

    }
}