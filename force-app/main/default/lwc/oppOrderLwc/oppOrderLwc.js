import {LightningElement, api, wire, track} from 'lwc';
import getOrders from '@salesforce/apex/OppGetOrderAsset.getOrders';

const COLUMNS = [
    { label: 'Order Number', fieldName: 'OrderNumber', type: 'Auto Number' },
    { label: 'Discount Order Amount', fieldName: 'Discount_Order_Amount__c', type: 'currency' },
    { label: 'Order Date', fieldName: 'EffectiveDate', type: 'Date' },
    { label: 'Payment', fieldName: 'Payment__c', type: 'Picklist' },
    {
        type: 'action',
        typeAttributes: { rowActions: [{ label: 'View Assets', name: 'view_assets' }] },
    },
];

export default class OppOrderLwc extends LightningElement {
    @api recordId;
    @track orderCount = 0; // 주문 개수 초기화
    @track orders = [];
    columns = COLUMNS;

    @wire(getOrders, { oppId: '$recordId' })
    wiredOrders({ error, data }) {
        if (data) {
            this.orders = data;
            this.orderCount = data.length;
        } else if (error) {
            // 에러 처리
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.dispatchEvent(new CustomEvent('orderselect', { detail: { orderId: row.Id } }));
    }
}