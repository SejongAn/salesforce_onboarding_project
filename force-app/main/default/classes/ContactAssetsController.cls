public with sharing class ContactAssetsController {
    @AuraEnabled(cacheable=true)
    public static List<Asset> getAssets(Id contactId) {
    return [SELECT Id, Name, Refund_availability__c,PurchaseDate,SerialNumber,Product2.Name,Warranty_status__c FROM Asset WHERE ContactId = :contactId AND Refund_availability__c = FALSE ORDER BY PurchaseDate DESC];
    }
    }