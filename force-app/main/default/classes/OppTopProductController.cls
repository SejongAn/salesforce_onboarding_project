// <!--*******************************************************************************
//   * File Name   : OppTopProductController.cls
//   * Description : oppty 레코드 페이지에서 1.판매대수 기준 제품군별 상위 제품을 가져오기 위한
//                      2. oppty의 국적(Type)을 가져오기 위한 클래스
//   * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
//   * Author      : i2max
//   * Modification Log
//   * ===============================================================
//   * Ver  Date        Author            Modification
//   * ===============================================================
//   * 1.0  2024.04.29  Byeonghak Lim        Create
// ********************************************************************************-->

public without sharing class OppTopProductController {

    // Product 내에 직접적으로 가격정보를 가져올 수 없으므로 해당 객체 리스트로 반환하는데 어려움이 있음.
    // 따라서 Product에 대한 데이터와 Price에 대한 데이터를 묶어서 반환할 수 있도록 내부 Wrapper class로 준비
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

    // 매개변수로 제품군과 지점 국가를 넣었을 때 각각 나라별 판매대수 상위 제품을 1위부터 순차적으로 나열
    @AuraEnabled(cacheable=false)
    public static List<ProductInfo> getTopProducts(String productFamily, String accountType) {
        List<AggregateResult> topProducts = [
                SELECT Product2Id, COUNT(Id) quantity
                FROM Asset
                WHERE Refund_availability__c = false AND Product2.Family=:productFamily AND Account.Type =:accountType
                GROUP BY Product2Id
                ORDER BY COUNT(Id) DESC
                LIMIT 5
        ];

        // 상위 5위 판매제품에 대한 Id값 가져오기
        List<Id> topProductIds = new List<Id>();
        for (AggregateResult ar : topProducts) {
            topProductIds.add((Id)ar.get('Product2Id'));
        }

        //상위 5위 판매제품에 대한 Id값 기준으로 Product 형태의 변수에 저장
        List<Product2> products = [SELECT Id, Name FROM Product2 WHERE Id IN :topProductIds];

        // 사용자의 통화 설정에 따라 알맞는 Price book entry에 접근하여 가격정보를 가져와 Map 형태로 저장
        Map<Id, Decimal> productPrices = new Map<Id, Decimal>();
        String currencyCode = UserInfo.getDefaultCurrency();
        for (PriceBookEntry pbe : [SELECT Product2Id, UnitPrice FROM PriceBookEntry
        WHERE Product2Id IN :topProductIds AND Pricebook2.IsActive = true AND CurrencyIsoCode = :currencyCode]) {
            productPrices.put(pbe.Product2Id, pbe.UnitPrice);
        }

        // 앞서 저장한 Product 와 Price를 초반에 설정한 ProductInfo 형태로 담아 반환
        List<ProductInfo> productInfos = new List<ProductInfo>();
        for (Product2 product : products) {
            Decimal price = productPrices.containsKey(product.Id) ? productPrices.get(product.Id) : 0;
            productInfos.add(new ProductInfo(product.Id, product.Name, price));
        }

        return productInfos;
    }

    // 상담의 recordId 값을 넣어 상담이 진행된 지점의 국가 정보를 가져옴. 이후 상위 판매제품 메소드의 매개변수로 활용
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