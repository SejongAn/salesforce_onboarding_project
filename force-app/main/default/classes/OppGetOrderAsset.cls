public with sharing class OppGetOrderAsset {

    @AuraEnabled(cacheable=true)
    public static List<Order> getOrders(String oppId) {
        // Opportunity로부터 주요 Contact의 ID를 찾는 쿼리
        Opportunity opp = [SELECT Contact__c FROM Opportunity WHERE Id = :oppId LIMIT 1];
        
        // 찾은 Contact ID를 사용하여 주요 Contact와 연관된 Order 객체 찾기
        if (opp.Contact__c != null) {
            return [SELECT Id, OrderNumber, Discount_Order_Amount__c, EffectiveDate, Payment__c
                    FROM Order 
                    WHERE Contact__c = :opp.Contact__c
                    ORDER BY EffectiveDate DESC];
        }
        return new List<Order>();
    }

    @AuraEnabled(cacheable=true)
	public static List<Asset> getAssets(String orderId) {
    	List<Asset> assets = [SELECT Id, Name, PurchaseDate, Warranty_status__c, Refund_availability__c
                          FROM Asset 
                          WHERE Order__c = :orderId];
    	if (assets.isEmpty()) {
    	    return new List<Asset>(); // 빈 리스트 반환
    	}
    	return assets;
}


}