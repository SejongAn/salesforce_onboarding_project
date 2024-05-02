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
        @AuraEnabled public String Family { get; set; }

        @AuraEnabled public Decimal Price { get; set; }

        public ProductInfo(Id id, String name, Decimal price, String family) {
            this.Id = id;
            this.Name = name;
            this.Price = price;
            this.Family = family;
        }
    }

    // 매개변수로 제품군과 지점 국가를 넣었을 때 각각 나라별 판매대수 상위 제품을 1위부터 순차적으로 나열
    @AuraEnabled(cacheable=true)
    public static List<ProductInfo> getTopProducts(String oppId) {

        System.debug('sdfa');

        String accountType = getAccountType(oppId); // 상담지점의 국가 저장
        List<String> PdtFamily = new List<String>{'laptop', 'accessory'};
        List<ProductInfo> ProductInfosToJs = new List<ProductInfo>();


        for(String pdtFam : PdtFamily){
            List<AggregateResult> topProduct = [
                    SELECT Product2Id, COUNT(Id) quantity
                    FROM Asset
                    WHERE Refund_availability__c = false AND Product2.Family =: pdtFam AND Account.Type =: accountType
                    GROUP BY Product2Id
                    ORDER BY COUNT(Id) DESC
                    LIMIT 5
            ];

            // 상위 5위 판매제품에 대한 Id값 가져오기
            List<Id> topIds = new List<Id>();
            for (AggregateResult ar : topProduct) {
                topIds.add((Id) ar.get('Product2Id'));
            }

            // topIds 리스트에 저장된 ID에 기반하여 Product2 레코드를 검색합니다.
            List<Product2> queriedProducts = [SELECT Id, Name, Family FROM Product2 WHERE Id IN :topIds];

            // Products 리스트를 최적화된 순서로 재배열하기 위한 리스트를 준비합니다.
            List<Product2> products = new List<Product2>();

            // topIds의 순서에 따라 queriedProducts 내의 Product2 객체들을 재정렬합니다.
            for (Id productId : topIds) {
                for (Product2 product : queriedProducts) {
                    if (product.Id == productId) {
                        products.add(product);
                        break; // 현재 제품을 찾았으므로 다음 제품 ID로 넘어갑니다.
                    }
                }
            }


            // 사용자의 통화 설정에 따라 알맞는 Price book entry에 접근하여 가격정보를 가져와 Map 형태로 저장
            Map<Id, Decimal> productPrices = new Map<Id, Decimal>();
            String currencyCode = UserInfo.getDefaultCurrency();
            for (PriceBookEntry pbe : [
                    SELECT Product2Id, UnitPrice
                    FROM PriceBookEntry
                    WHERE Product2Id IN :topIds AND Pricebook2.IsActive = true AND CurrencyIsoCode = :currencyCode
            ]) {
                productPrices.put(pbe.Product2Id, pbe.UnitPrice);
            }

            // 앞서 저장한 Product 와 Price를 초반에 설정한 ProductInfo 형태로 담아 반환
            for (Product2 product : products) {
                Decimal price = productPrices.get(product.Id) ?? 0;
                ProductInfosToJs.add(new ProductInfo(product.Id, product.Name, price, product.Family));
            }

        } System.debug('debug' + ProductInfosToJs);
        return ProductInfosToJs;

    }

    // 상담의 recordId 값을 넣어 상담이 진행된 지점의 국가 정보를 가져옴. 이후 상위 판매제품 메소드의 매개변수로 활용
    @AuraEnabled(cacheable=true)
    public static String getAccountType(String oppId) {
        // Opportunity의 Account의 Type을 찾습니다.
        Opportunity opp = [SELECT Account.Type FROM Opportunity WHERE Id =: oppId LIMIT 1];
//        String accountType = opp.Account.Type;
//        return accountType;

        return opp.Account?.Type;
    }
}