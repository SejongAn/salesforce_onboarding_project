import { LightningElement, wire, api } from 'lwc';
// Apex 메소드 임포트
import getTopProducts from '@salesforce/apex/OppTopProductController.getTopProducts';
import getAccountType from '@salesforce/apex/OppTopProductController.getAccountType';

export default class TopProducts extends LightningElement {
    topLaptops = [];
    topAccessories = [];
    @api recordId; // 현재 페이지의 Opportunity ID

    columns = [
        { label: 'Product Name', fieldName: 'Name', type: 'text' },
        { label: 'Price', fieldName: 'Price', type: 'currency' }
    ];

    @wire(getAccountType, { oppId: '$recordId' })
    wiredAccountType({ error, data }) {
        if (data) {
            this.loadProducts(data);
        } else if (error) {
            console.error('Error:', error);
        }
    }

    loadProducts(accountType) {
        getTopProducts({ productFamily: 'laptop', accountType }).then(result => {
            this.topLaptops = result;
        });
        getTopProducts({ productFamily: 'accessory', accountType }).then(result => {
            this.topAccessories = result;
        });
    }

}