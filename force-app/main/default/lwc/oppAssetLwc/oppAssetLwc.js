/**
 * Created by nate on 4/29/24.
 */

import {LightningElement, api, wire, track} from 'lwc';
import getAssets from '@salesforce/apex/OppGetOrderAsset.getAssets';

const COLUMNS = [
    { label: 'Asset Name', fieldName: 'Name', type: 'text'},
    { label: 'Purchase Date', fieldName: 'PurchaseDate', type: 'Date'},
    { label: 'Warranty Status', fieldName: 'Warranty_status__c', type: 'Formula' },
    { label: 'Refund Status', fieldName: 'Refund_availability__c', type: 'Checkbox'}
];

export default class OppAssetLwc extends LightningElement {
    @api orderId;
    @track assetCount = 0; // 자산 개수 초기화
    assets;
    columns = COLUMNS;

    @wire(getAssets, { orderId: '$orderId' })
    wiredAssets({ error, data }) {
        if (data) {
            this.assets = data;
            this.assetCount = data.length;

        } else if (error) {
            // 에러 처리
        }
    }
}