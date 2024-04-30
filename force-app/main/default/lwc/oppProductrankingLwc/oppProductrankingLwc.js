// <!--*******************************************************************************
//   * File Name   : oppProductrankingLwc.js
//   * Description : oppty 레코드 페이지에서 제품군별 상위 제품을 국가에 맞춰 가격과 함께 보여줌
//                        좌측은 노트북 상위제품  // 우측은 주변기기 상위제품
//   * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
//   * Author      : i2max
//   * Modification Log
//   * ===============================================================
//   * Ver  Date        Author            Modification
//   * ===============================================================
//   * 1.0  2024.04.29  Byeonghak Lim        Create
// ********************************************************************************-->
import { LightningElement, wire, api, track } from 'lwc';
import getTopProducts from '@salesforce/apex/OppTopProductController.getTopProducts';
import getAccountType from '@salesforce/apex/OppTopProductController.getAccountType';
import Laptop from '@salesforce/label/c.Laptop';
import Accessories from '@salesforce/label/c.Accessories';
import ProductName from '@salesforce/label/c.ProductName';
import Price from '@salesforce/label/c.Price';
import Product from '@salesforce/label/c.Product';


export default class TopProducts extends LightningElement {

    label = { Laptop, Accessories, ProductName, Price, Product };

    @track topLaptops = [];
    @track topAccessories = [];
    @api recordId; // 현재 페이지의 Opportunity ID

    columns = [
        { label: ProductName, fieldName: 'Name', type: 'text' },
        { label: Price, fieldName: 'Price', type: 'currency' }
    ];



    // 현재 상담 페이지의 recordId를 가져와 지점 국적을 파악하고 별도의 메소드를 통해 제품군별 상위제품을 띄움
    @wire(getAccountType, { oppId: '$recordId' })
    wiredAccountType({ error, data }) {
        if (data) {
            this.loadProducts(data);
        } else if (error) {
            console.error('Error:', error);
        }
    }

    // 지점 국적 별로 매칭되는 제품군별 상위제품을 띄움
    loadProducts(accountType) {
        // 데이터 로드 전에 기존 배열 초기화
        this.topLaptops = [];
        this.topAccessories = [];

        getTopProducts({ productFamily: 'laptop', accountType }).then(result => {
            this.topLaptops = result;
        }).catch(error => {
            console.error('Laptops loading error:', error);
            this.topLaptops = [];
        });

        getTopProducts({ productFamily: 'accessory', accountType }).then(result => {
            this.topAccessories = result;
        }).catch(error => {
            console.error('Accessories loading error:', error);
            this.topAccessories = [];
        });
    }

}