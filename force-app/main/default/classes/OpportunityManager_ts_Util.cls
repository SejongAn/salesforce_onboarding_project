//   * File Name   : OpportunityManager_ts_Util.cls
//   * Description :
//   * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
//   * Author      : i2max
//   * Modification Log
//   * ===============================================================
//   * Ver  Date        Author            Modification
//   * ===============================================================
//   * 1.0  2024.05.02  Sejong An        Create
// ********************************************************************************-->
@IsTest
public class OpportunityManager_ts_Util {

    public static String getUserIdFromProfile(String profileName) {
        String result ='';
        for (Schema.Profile p:[SELECT Id FROM Profile WHERE Name=:profileName LIMIT 1]){
            for (User u:[SELECT Id FROM User WHERE ProfileId = :p.Id LIMIT 1]){
                result =u.Id;
            }
        }
        return result;
    }

    public static String getAccountId(){
        String result ='';
        for (Account acc:[SELECT Id FROM Account LIMIT 1]){
            result=acc.Id;
        }
        return result;
    }

    public static String getContactId(){
        String result ='';
        for (Contact con:[SELECT Id FROM Contact LIMIT 1]){
            result=con.Id;
        }
        return result;
    }
}