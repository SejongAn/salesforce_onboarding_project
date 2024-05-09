// <!--*******************************************************************************
//   * File Name   : oppOrderLwc.js
//   * Description : oppty 레코드 페이지에서 연결된 고객의 주문 내역을 보여줌
//   * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
//   * Author      : i2max
//   * Modification Log
//   * ===============================================================
//   * Ver  Date        Author            Modification
//   * ===============================================================
//   * 1.0  2024.04.29  Byeonghak Lim        Create
// ********************************************************************************-->
import { LightningElement, api, wire, track} from 'lwc';
import getOrders from '@salesforce/apex/OppGetOrderAsset.getOrders';
import { publish, MessageContext } from 'lightning/messageService';
import { NavigationMixin } from 'lightning/navigation';
import OrderAssetMessageChannel from '@salesforce/messageChannel/OrderAssetMessageChannel__c';
//custom label
import Orders from '@salesforce/label/c.Orders';
import OrderNumber from '@salesforce/label/c.OrderNumber';
import OrderDate from '@salesforce/label/c.OrderDate';
import DiscountOrderAmount from '@salesforce/label/c.DiscountOrderAmount';
import Payment from '@salesforce/label/c.Payment';
import ViewAssets from '@salesforce/label/c.ViewAssets';


const COLUMNS = [
    { label: OrderNumber, fieldName: 'OrderNumber', type: 'button', cellAttributes: { alignment: 'center' },
        typeAttributes: {
            label: { fieldName: 'OrderNumber' }, // OrderNumber 값을 버튼의 라벨로 사용합니다.
            name: 'OrderNo', // OrderNumORAsset 함수에서 action.name을 통해 이 값을 확인합니다.
            title: 'View Order',
            variant: 'base'
        }},
    { label: DiscountOrderAmount, fieldName: 'Discount_Order_Amount__c', type: 'currency' },
    { label: OrderDate, fieldName: 'EffectiveDate', type: 'Date', cellAttributes: { alignment: 'center' }, fixedWidth: 130 },
    { label: Payment, fieldName: 'Payment__c', type: 'Picklist', cellAttributes: { alignment: 'center' }, fixedWidth: 110 },
    {
        type: 'button',  fixedWidth: 130,
        typeAttributes: {
            label: ViewAssets,
            name: 'view_asset',
            title: 'View Asset'
            // variant: 'brand'
        },
        cellAttributes: { alignment: 'center' }
    }
];

export default class OppOrderLwc extends NavigationMixin(LightningElement) {

    label = { Orders, OrderNumber, DiscountOrderAmount, OrderDate, Payment  };

    @api recordId;
    orderCount = 0; // 주문 개수 초기화
    @track orders = [];
    showNoOrdersMessage = false; // 데이터가 없을 때 메시지를 표시할지 결정하는 변수
    columns = COLUMNS;

    @wire(MessageContext)
    messageContext;

    //현재 상담 페이지의 Id값을 매개변수로 하여 연결된 고객의 주문 내역을 불러와 보여줌
    @wire(getOrders, { oppId: '$recordId' })
    wiredOrders({ error, data }) {
        if (data) {
            this.orders = data;
            this.orderCount = data.length;
            this.showNoOrdersMessage = data.length === 0; // 데이터가 없으면 true로 설정
        } else if (error) {
            console.error('Error retrieving orders:', error);
        }
    }

    // datatable상 같은 행에서 발생시키는 2가지 rowaction을 event 별로 다른 action 실행 (아래 참조)
    orderNumORAsset(event){
        console.log(event.detail.action.name);
        const actionName = event.detail.action.name; // 버튼의 이름을 가져옵니다.
        if (actionName === 'OrderNo') {
            this.navigateToRecord(event);
        } else if (actionName === 'view_asset') {
            this.handleRowAction(event);
        }
    }

    // 주문 내역의 show asset 버튼을 클릭했을 때의 rowaction 1: 해당 주문의 recordId값을 자산 LWC(oppAssetLwc)로 보냄
    handleRowAction(event) {
        const row = event.detail.row;
        const orderId = row.Id;
        console.log(orderId);
        const payload = { recordId: orderId };
        publish(this.messageContext, OrderAssetMessageChannel, payload);
    }

    // 주문 내역의 주문번호를 클릭했을 때의 rowaction 2: 해당 주문의 레코드 상세 페이지로 이동
    navigateToRecord(event) {
        const orderId = event.detail.row.Id; // Get the Id of the clicked asset
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: orderId,
                actionName: 'view'
            },
        });
    }
}