public with sharing class OppTopProductController {

    @AuraEnabled(cacheable=true)
    public static List<Product2> getTopLaptopKOR() {
        // Asset에 연결된 Product를 카운트 하여 판매대수 상위 노트북을 조회합니다.
        List<AggregateResult> Top5Laptop = [
                SELECT Product2Id, COUNT(Id) quantity
                FROM Asset
                WHERE Refund_availability__c = false AND Product2.Family='laptop' AND Account.Type ='KOR'
                GROUP BY Product2Id
                ORDER BY COUNT(Id) DESC
                LIMIT 5
        ];

        // Product2Id 리스트를 생성합니다.
        List<Id> topLaptopIds = new List<Id>();
        for (AggregateResult ar : Top5Laptop) {
            topLaptopIds.add((Id)ar.get('Product2Id'));
        }

        // 상위 5개의 Product2Id 순서대로 Product2 레코드를 조회합니다.
        Map<Id, Product2> productsMap = new Map<Id, Product2>(
                [SELECT Id, Name, (SELECT Price FROM Assets LIMIT 1) FROM Product2 WHERE Id IN :topLaptopIds]
        );

        // 정렬된 순서를 유지하기 위해 리스트를 생성합니다.
        List<Product2> topLaptopKOR = new List<Product2>();
        for (Id productId : topLaptopIds) {
            Product2 product = productsMap.get(productId);
            if (product != null) {
                topLaptopKOR.add(product);
            }
        }

        return topLaptopKOR;
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getTopLaptopUS() {
        // Asset에 연결된 Product를 카운트 하여 판매대수 상위 노트북을 조회합니다.
        List<AggregateResult> Top5Laptop = [
                SELECT Product2Id, COUNT(Id) quantity
                FROM Asset
                WHERE Refund_availability__c = false AND Product2.Family='laptop' AND Account.Type ='US'
                GROUP BY Product2Id
                ORDER BY COUNT(Id) DESC
                LIMIT 5
        ];

        // Product2Id 리스트를 생성합니다.
        List<Id> topLaptopIds = new List<Id>();
        for (AggregateResult ar : Top5Laptop) {
            topLaptopIds.add((Id)ar.get('Product2Id'));
        }

        // 상위 5개의 Product2Id 순서대로 Product2 레코드를 조회합니다.
        Map<Id, Product2> productsMap = new Map<Id, Product2>(
                [SELECT Id, Name, (SELECT Price FROM Assets LIMIT 1) FROM Product2 WHERE Id IN :topLaptopIds]
        );

        // 정렬된 순서를 유지하기 위해 리스트를 생성합니다.
        List<Product2> topLaptopUS = new List<Product2>();
        for (Id productId : topLaptopIds) {
            Product2 product = productsMap.get(productId);
            if (product != null) {
                topLaptopUS.add(product);
            }
        }

        return topLaptopUS;
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getTopAccessoryKOR() {
        // Asset에 연결된 Product를 카운트 하여 판매대수 상위 주변기기를 조회합니다.
        List<AggregateResult> Top5Accessory = [
                SELECT Product2Id, COUNT(Id) quantity
                FROM Asset
                WHERE Refund_availability__c = false AND Product2.Family='accessory' AND Account.Type ='KOR'
                GROUP BY Product2Id
                ORDER BY COUNT(Id) DESC
                LIMIT 5
        ];

        // Product2Id 리스트를 생성합니다.
        List<Id> topAccessoryIds = new List<Id>();
        for (AggregateResult ar : Top5Accessory) {
            topAccessoryIds.add((Id)ar.get('Product2Id'));
        }

        // 상위 5개의 Product2Id 순서대로 Product2 레코드를 조회합니다.
        Map<Id, Product2> productsMap = new Map<Id, Product2>(
                [SELECT Id, Name, (SELECT Price FROM Assets LIMIT 1) FROM Product2 WHERE Id IN :topAccessoryIds]
        );


        // 정렬된 순서를 유지하기 위해 리스트를 생성합니다.
        List<Product2> topAccessoryKOR = new List<Product2>();
        for (Id productId : topAccessoryIds) {
            Product2 product = productsMap.get(productId);
            if (product != null) {
                topAccessoryKOR.add(product);
            }
        }

        return topAccessoryKOR;
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getTopAccessoryUS() {
        // Asset에 연결된 Product를 카운트 하여 판매대수 상위 주변기기를 조회합니다.
        List<AggregateResult> Top5Accessory = [
                SELECT Product2Id, COUNT(Id) quantity
                FROM Asset
                WHERE Refund_availability__c = false AND Product2.Family='accessory' AND Account.Type ='US'
                GROUP BY Product2Id
                ORDER BY COUNT(Id) DESC
                LIMIT 5
        ];

        // Product2Id 리스트를 생성합니다.
        List<Id> topAccessoryIds = new List<Id>();
        for (AggregateResult ar : Top5Accessory) {
            topAccessoryIds.add((Id)ar.get('Product2Id'));
        }

        // 상위 5개의 Product2Id 순서대로 Product2 레코드를 조회합니다.
        Map<Id, Product2> productsMap = new Map<Id, Product2>(
                [SELECT Id, Name, (SELECT Price FROM Assets LIMIT 1) FROM Product2 WHERE Id IN :topAccessoryIds]
        );


        // 정렬된 순서를 유지하기 위해 리스트를 생성합니다.
        List<Product2> topAccessoryUS = new List<Product2>();
        for (Id productId : topAccessoryIds) {
            Product2 product = productsMap.get(productId);
            if (product != null) {
                topAccessoryUS.add(product);
            }
        }

        return topAccessoryUS;
    }
}