//<!--*******************************************************************************
//* File Name   : OppGetOrderAsset.cls
//* Description : oppty 레코드 페이지에서 연결된 고객의 (1.주문내역)과 (2.각각의 주문내역에 대한 자산목록)을
//                  불러오기 위한 메소드 2개 포함 클래스
//* Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
//* Author      : i2max
//* Modification Log
//* ===============================================================
//* Ver  Date        Author            Modification
//* ===============================================================
//* 1.0  2024.04.29  Byeonghak Lim        Create
//********************************************************************************-->
public without sharing class OppGetOrderAsset {

    // Oppty 레코드 페이지에서 연결된 고객의 (1.주문내역)을 불러오는 메소드
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrders(String oppId) {
        // Opportunity로부터 주요 Contact의 ID를 찾는 쿼리
        Opportunity opp = [SELECT Contact__c FROM Opportunity WHERE Id = :oppId LIMIT 1];

        // 찾은 Contact ID를 사용하여 연결 Contact와 연관된 Order 객체 찾기
        if (opp.Contact__c != null) {
            return [SELECT Id, OrderNumber, Discount_Order_Amount__c, EffectiveDate, Payment__c
            FROM Order
            WHERE Contact__c = :opp.Contact__c
            ORDER BY EffectiveDate DESC];
        }
        return new List<Order>();
    }

    // Oppty 레코드 페이지에서 1에서 선택한 (2.각각의 주문내역에 대한 자산목록)을 불러오기 위한 메소드
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