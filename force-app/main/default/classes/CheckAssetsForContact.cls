public class CheckAssetsForContact {
    
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
            // SOQL 쿼리를 사용하여 특정 Contact ID에 연결된 환불상태가 아닌 Asset의 수를 확인합니다.
            Integer count = [SELECT COUNT() FROM Asset WHERE ContactId = :request.contactId AND Refund_availability__c = false];
            
            Response res = new Response();
            //환불이 안된 Asset 수가 0이라면 true반환
            res.hasNoAssets = (count == 0);
            responses.add(res);
        }
        return responses;
    }
}