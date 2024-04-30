// <!--*******************************************************************************
//   * File Name   : oppAssetLwc.js
//   * Description : oppty 레코드 페이지에서 Order LWC창의 레코드 클릭시 연결된 자산 내역을 보여줌
//   * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
//   * Author      : i2max
//   * Modification Log
//   * ===============================================================
//   * Ver  Date        Author            Modification
//   * ===============================================================
//   * 1.0  2024.04.29  Byeonghak Lim        Create
// ********************************************************************************-->
import {LightningElement, api, wire, track} from 'lwc';
import getAssets from '@salesforce/apex/OppGetOrderAsset.getAssets';
import OrderAssetMessageChannel from '@salesforce/messageChannel/OrderAssetMessageChannel__c';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, MessageContext } from 'lightning/messageService';
// custom labeling 부분
import Assets from '@salesforce/label/c.Assets';
import Asset_Name from '@salesforce/label/c.Asset_Name';
import PurchaseDate from '@salesforce/label/c.PurchaseDate';
import Warranty_Status from '@salesforce/label/c.Warranty_Status';
import Refund_Status from '@salesforce/label/c.Refund_Status';


const COLUMNS = [
    { label: Asset_Name, fieldName: 'Name', type: 'button',
        typeAttributes: { label: { fieldName: 'Name' }, variant: 'base' }},
    { label: 'Purchase Date', fieldName: 'PurchaseDate', type: 'Date',
        cellAttributes: { alignment: 'center' }, fixedWidth: 150},
    { label: 'Warranty Status', fieldName: 'Warranty_status__c', type: 'Formula',
        cellAttributes: { alignment: 'center' }, fixedWidth: 170},
    { label: 'Refund Status', fieldName: 'Refund_availability__c', type: 'Checkbox',
        cellAttributes: { alignment: 'center' }, fixedWidth: 150}
];

export default class OppAssetLwc extends NavigationMixin(LightningElement) {

    label = { Assets, Asset_Name, PurchaseDate, Warranty_Status, Refund_Status  };

    @track asset = {
        Name: '',
        PurchaseDate: '',
        Warranty_End_Date__c: '',
        Refund_availability__c: ''
    };

    @track assetCount = 0; // 자산 개수 초기화
    @track showNoOrdersMessage = false; // 데이터가 없을 때 메시지를 표시할지 결정하는 변수
    assets;
    columns = COLUMNS;

    _orderId; // 내부적으로 사용할 orderId

    @wire(MessageContext)
    messageContext;

    // 컴포넌트가 DOM에 연결되었을 때 호출됩니다.
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    // 메시지 채널을 구독합니다.
    subscribeToMessageChannel() {
        this.subscription = subscribe(this.messageContext, OrderAssetMessageChannel,
            (message) => this.handleMessage(message));
    }

    // Order LWC (oppOrderLwc) 로부터 넘어온 주문의 recordId 값을 orderId 값에 저장
    handleMessage(message) {
        this.orderId = message.recordId;
        console.log(this.recordId);
    }

    // orderId 값을 OppGetOrderAsset 클래스의 자산을 불러오는 메소드에 넣어 연결된 자산 내역을 보여줌
    @wire(getAssets, {orderId: '$orderId'})
    wiredAssets({error, data}) {
        if (data) {
            console.log(this.orderId);
            this.assets = data;
            this.assetCount = data.length;
            this.showNoOrdersMessage = data.length === 0; // 데이터가 없으면 true로 설정


        } else if (error) {
            console.error('Error retrieving assets:', error);
        }
    }

    // 자산 LWC에서 자산 이름을 클릭시 해당 레코드의 상세페이지로 이동
    navigateToRecord(event) {
        const assetId = event.detail.row.Id; // Get the Id of the clicked asset
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: assetId,
                actionName: 'view'
            },
        });
    }

    // orderId에 대한 세터와 게터 추가
    @api
    get orderId() {
        return this._orderId;
    }

    set orderId(value) {
        this._orderId = value;
        // orderId가 설정될 때 필요한 로직 수행, 예를 들어 메시지 표시 여부 업데이트
        this.showNoOrdersMessage = !this._orderId;

    }
}