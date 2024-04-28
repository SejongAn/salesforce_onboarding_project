public with sharing class CaseController {
    //해당 asset에 related 된 case가 있는지 확인
    @AuraEnabled(Cacheable=true)
    public static List<Case> searchCase(String assetId) {
        List<Case> cases = [SELECT ID,CaseNumber,Subject,Type,Reason,Status,CreatedDate FROM CASE WHERE Asset__c = :assetId];
        if(cases.size()>0){
            return cases;
        } else {
            return null;
        }
    }

    //해당 asset에 대해 case를 생성(Cacheable=true이면 레코드 생성 안됨)
    @AuraEnabled
    public static String insertCase(String Subject,String Description,String Type,String Reason,Id AssetId, Id ContactId) {
        try{
            Case newCase = new Case(Subject = Subject, Description = Description, Type = Type, Reason = Reason, Asset__c = AssetId, ContactId = ContactId);
            insert newCase;
            return newCase.Id;
        } catch(Exception e){
            throw new AuraHandledException('저장 실패: ' + e.getMessage());
        }
    }
}