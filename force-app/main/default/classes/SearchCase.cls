public with sharing class SearchCase {
    @AuraEnabled(Cacheable=true)
    public static List<Case> searchCase(String assetId) {
        List<Case> cases = [SELECT ID,CaseNumber,Subject,Type,Reason,Status,CreatedDate FROM CASE WHERE Asset__c = :assetId];
        if(cases.size()>0){
            return cases;
        } else {
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Case> getReasons(String caseType) {
        if(String.isNotBlank(caseType)) {
            return [SELECT Id, Reason FROM Case WHERE Type = :caseType Order by Reason];
        } else {
            return [SELECT Id FROM Case];
        }
    }
}