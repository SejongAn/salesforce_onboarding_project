public with sharing class OppTopProductController {

    public class ProductInfo {
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public Decimal Price { get; set; }

        public ProductInfo(Id id, String name, Decimal price) {
            this.Id = id;
            this.Name = name;
            this.Price = price;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductInfo> getTopProducts(String productFamily, String accountType) {
        List<AggregateResult> topProducts = [
                SELECT Product2Id, COUNT(Id) quantity
                FROM Asset
                WHERE Refund_availability__c = false AND Product2.Family=:productFamily AND Account.Type =:accountType
                GROUP BY Product2Id
                ORDER BY COUNT(Id) DESC
                LIMIT 5
        ];

        List<Id> topProductIds = new List<Id>();
        for (AggregateResult ar : topProducts) {
            topProductIds.add((Id)ar.get('Product2Id'));
        }

        List<Product2> products = [SELECT Id, Name FROM Product2 WHERE Id IN :topProductIds];

        Map<Id, Decimal> productPrices = new Map<Id, Decimal>();
        String currencyCode = UserInfo.getDefaultCurrency();
        for (PriceBookEntry pbe : [SELECT Product2Id, UnitPrice FROM PriceBookEntry
        WHERE Product2Id IN :topProductIds AND Pricebook2.IsActive = true AND CurrencyIsoCode = :currencyCode]) {
            productPrices.put(pbe.Product2Id, pbe.UnitPrice);
        }

        List<ProductInfo> productInfos = new List<ProductInfo>();
        for (Product2 product : products) {
            Decimal price = productPrices.containsKey(product.Id) ? productPrices.get(product.Id) : 0;
            productInfos.add(new ProductInfo(product.Id, product.Name, price));
        }

        return productInfos;
    }
    @AuraEnabled(cacheable=true)
    public static String getAccountType(String oppId) {
        //Opportunity의 Id를 사용하여 연결된 Account의 Type(국가) 필드를 조회
        Opportunity opp = [
                SELECT Account.Type
                FROM Opportunity
                WHERE Id = :oppId
                LIMIT 1
        ];
        return opp.Account != null ? opp.Account.Type : null;
    }
}