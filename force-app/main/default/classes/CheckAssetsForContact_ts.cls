//   * File Name   : CheckAssetsForContact_ts.cls
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
private class CheckAssetsForContact_ts {
    @TestSetup
    static void setup(){
        Account acc = new Account(Name='test account');
        insert acc;
        Id accId = OpportunityManager_ts_Util.getAccountId();
        Contact con = new Contact(LastName='test contact',Phone='010-1234-1234',AccountId=accId);
        insert con;
        Id conId = OpportunityManager_ts_Util.getContactId();
        Asset asst = new Asset(Name ='test asset',ContactId=conId,Refund_availability__c = false);
        insert asst;
    }

    @IsTest
    static void checkAssets1() {
        Id conId = OpportunityManager_ts_Util.getContactId();
        CheckAssetsForContact.Request req = new CheckAssetsForContact.Request();
        req.contactId=conId;

        List<CheckAssetsForContact.Request> reqList = new List<CheckAssetsForContact.Request>();
        reqList.add(req);

        List<CheckAssetsForContact.Response> resList = CheckAssetsForContact.checkAssets(reqList);
        Boolean bol;
        for(CheckAssetsForContact.Response res:resList){
            bol = res.hasNoAssets;
        }
        system.assertEquals(false,bol);
    }

    @IsTest
    static void checkAssets2() {
        CheckAssetsForContact.Request req = new CheckAssetsForContact.Request();
        req.contactId='000000000000000000';

        List<CheckAssetsForContact.Request> reqList = new List<CheckAssetsForContact.Request>();
        reqList.add(req);

        List<CheckAssetsForContact.Response> resList = CheckAssetsForContact.checkAssets(reqList);
        Boolean bol;
        for(CheckAssetsForContact.Response res:resList){
            bol = res.hasNoAssets;
        }
        system.assertEquals(true,bol);
    }
}