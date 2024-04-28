import {LightningElement, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import searchPhone from '@salesforce/apex/ContactSearch.searchPhone';
import Enter_phone_number from '@salesforce/label/c.Enter_phone_number';
import ErrorSearchMessage from '@salesforce/label/c.ErrorSearchMessage';
import Phone from '@salesforce/label/c.Phone';
import typeInCard from '@salesforce/label/c.typeInCard';
import Search from '@salesforce/label/c.Search';
import purchased from '@salesforce/label/c.purchased';
import not_purchased from '@salesforce/label/c.not_purchased';

export default class ConBaseLwc extends NavigationMixin(LightningElement) {
    phoneNum;
    result;
    error;

    label = {
        Enter_phone_number, Phone, Search, typeInCard, ErrorSearchMessage, purchased, not_purchased
    };

    //사용자의 입력값 저장
    phoneChangeHandler(event) {
        this.phoneNum = event.target.value;
    }

    //input에서 입력후 enter 눌렀을 때 검색 function 호출
    pressEnter(event) {
        if (event.keyCode === 13) {
            this.doSearch();
        }
    }

    //사용자가 입력한 번호가 존재하는지 검색
    doSearch() {
        if (this.phoneNum != '') {
            let searchNum = this.phoneNum.replace(/[^0-9]/g, '');
            searchPhone({searchNum: searchNum}).then(result => {
                if (result.length == 0) {
                    console.log('search fail');
                } else {
                    const contacts = result.map(contact => {
                        return {
                            Id: contact.Id,
                            Name: contact.Name,
                            Phone: contact.Phone,
                            Type__c: (contact.Type__c === 'purchased') ? purchased : not_purchased
                        };
                    });
                    this.result = contacts;
                    this.error = undefined;
                }
            }).catch(error => {
                console.log('error');
                this.result = undefined;
                this.error = error;
            });
        }
    }

    //해당 contact 레코드로 이동
    doOpen(event) {
        const contactId = event.target.dataset.recordId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contactId,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        });
    }
}