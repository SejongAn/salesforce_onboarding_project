/*******************************************************************************
* File Name   : CheckAssetsForContact.cls
* Description :
* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
* Author      : i2max
* Modification Log
* ===============================================================
* Ver  Date        Author            Modification
* ===============================================================
* 1.0  2024.04.25  Sejong An         Create
********************************************************************************/
public class CheckAssetsForContact {
    //피드백으로 인한 수정으로 지금은 사용하고 있지 않음
    //
    //ApexAction을 해당 Contact의 환불상태 아닌 Asset 갯수가 0이면 true를 반환, Decision에서 확인
    //하는 방식으로 했었으나,
    //GetRecord로 해당 Contact의 환불상태 아닌 Asset을 가져와서 Decision에서 Null인지 확인함
    
    public class Request {
        @InvocableVariable(label='Contact ID' required=true)
        public Id contactId;
    }

    public class Response {
        @InvocableVariable(label='Has No Assets')
        public Boolean hasNoAssets;
    }

    @InvocableMethod(label='Check Assets for Contact')
    public static List<Response> checkAssets(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            // SOQL 쿼리를 사용하여 특정 Contact ID에 연결된 환불상태가 아닌 Asset의 수를 확인
            Integer count = [SELECT COUNT() FROM Asset WHERE ContactId = :request.contactId AND Refund_availability__c = false];
            
            Response res = new Response();
            //환불이 안된 Asset 수가 0이라면 true반환
            res.hasNoAssets = (count == 0);
            responses.add(res);
        }
        return responses;
    }
}