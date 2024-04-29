/*
*******************************************************************************
  * File Name   : ContactAssetsController.cls
  * Description : ContactAssetsController in cls 
  * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
  * Author      : i2max
  * Modification Log
  * ===============================================================
  * Ver  Date        Author            Modification
  * ===============================================================
  * 1.0  2024.04.26  JaeHwan Lee        Create
********************************************************************************
*/
public with sharing class ContactAssetsController {
    @AuraEnabled(cacheable=true)
    public static List<Asset> getAssets(Id contactId) {
    return [SELECT Id, Name, Refund_availability__c, PurchaseDate, SerialNumber, Product2.Name, Warranty_status__c FROM Asset WHERE ContactId = :contactId AND Refund_availability__c = FALSE ORDER BY PurchaseDate DESC];
    }
}