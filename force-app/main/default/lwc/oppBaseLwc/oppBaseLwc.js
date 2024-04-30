// <!--*******************************************************************************
//   * File Name   : oppBaseLwc.js
//   * Description : 
//   * Copyright   : Copyright © 1995-2024 i2max All Rights Reserved
//   * Author      : i2max
//   * Modification Log
//   * ===============================================================
//   * Ver  Date        Author            Modification
//   * ===============================================================
//   * 1.0  2024.04.26  Sejong An         Create
//   * 1.1  2024.04.26  Sejong An         Change to Contact Table from Contact Card
//   * 1.2  2024.04.30  Sejong An         Add Pagenation
// ********************************************************************************-->
import { LightningElement, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccounts from '@salesforce/apex/OpportunityManager.getAccounts';
import getContacts from '@salesforce/apex/OpportunityManager.getContacts';
import createSimpleConsult from '@salesforce/apex/OpportunityManager.createSimpleConsult';
import createFirstConsult from '@salesforce/apex/OpportunityManager.createFirstConsult';
import createRevisitConsult from '@salesforce/apex/OpportunityManager.createRevisitConsult';
import searchPhoneWithOffset from '@salesforce/apex/ContactSearch.searchPhoneWithOffset';
import USER_ID from '@salesforce/user/Id'
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
//Custom Label import
import c_account from '@salesforce/label/c.Account_Name';
import c_closeDate from '@salesforce/label/c.Close_Date';
import c_consultaion from '@salesforce/label/c.Consultation_Name';
import c_contact from '@salesforce/label/c.Contact';
import c_create from '@salesforce/label/c.Create';
import c_email from '@salesforce/label/c.Email';
import c_firstName from '@salesforce/label/c.First_Name';
import c_LastName from '@salesforce/label/c.Last_Name';
import c_newCustomer from '@salesforce/label/c.new_customer_info';
import c_phone from '@salesforce/label/c.Phone';
import c_selectCustomer from '@salesforce/label/c.Select_Exisitng_Customer';
import c_below from '@salesforce/label/c.Serch_contact_below';
import c_Enter_phone_number from '@salesforce/label/c.Enter_phone_number';
import c_typeInCard from '@salesforce/label/c.typeInCard';
import c_Search from '@salesforce/label/c.Search';
import c_ErrorSearchMessage from '@salesforce/label/c.ErrorSearchMessage';
import c_NoPermission from '@salesforce/label/c.No_Permission';
import requError from '@salesforce/label/c.Required_fields_not_filled_in';
import bothError from '@salesforce/label/c.Both_returning_and_first_time_visit_information_has_been_entered';
import allError from '@salesforce/label/c.Please_enter_all_of_your_customer_information';
import SYSTEM_ADMIN from '@salesforce/label/c.SYSTEM_ADMIN';
import not_purchased from '@salesforce/label/c.not_purchased';
import purchased from '@salesforce/label/c.purchased';
import COM_LAB_NAME from '@salesforce/label/c.COM_LAB_NAME';
import COM_LAB_PHONE from '@salesforce/label/c.COM_LAB_PHONE';

export default class OpportunityForm extends LightningElement {
    //import한 Custom Label값 변수에 할당
    label = {
    c_selectCustomer,
    c_account,
    c_closeDate,
    c_consultaion,
    c_contact,
    c_create,
    c_email,
    c_firstName,
    c_LastName,
    c_newCustomer,
    c_phone,
    c_below,
    c_Enter_phone_number,
    c_typeInCard,
    c_Search,
    c_ErrorSearchMessage,
    c_NoPermission
    };

    columns = [
        { label: '', fieldName: 'RowNum',hideDefaultActions: true},
        { label: COM_LAB_NAME, fieldName: 'Name' , type: 'button' ,typeAttributes: { label: { fieldName: 'Name' }, variant: 'base' }},
        { label: COM_LAB_PHONE, fieldName: 'Phone', hideDefaultActions: true}
    ];

    recordId;
    checkPoint;
    @track opportunityName;
    @track accountId;
    @track contactId;
    @track closeDate;
    @track firstName='';
    @track lastName='';
    @track phone='';
    @track email='';
    @track accountOptions;
    @track contactOptions;
    @track isCustomerInfoVisible = true;
    @track userId = USER_ID;
    @track displayComponent = false;
    @track displayConList = true;
    //검색 부분 변수
    @track phoneNum;
    result;
    error;

    recordPerPage=5;
    pageNum=1;
    
    

    //userId를 통해서 로그인한 유저의 Profile이름 가져와서 확인
    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD] })
    userData({ error, data }) {
        if (data) {
            const profileName = getFieldValue(data, PROFILE_NAME_FIELD);
            // 특정 프로필 이름을 기준으로 컴포넌트 표시 결정
            if(profileName === SYSTEM_ADMIN || profileName === 'Sales Team'){
                this.displayComponent = true;
            }
        } else if (error) {
            console.error('Error retrieving user data', error);
        }
    }

    @wire(getAccounts, { userId: '$userId' })
    wiredOwnedAccounts({ error, data }) {
        if (data) {
            this.accountOptions = data.map(account => ({
                label: account.Name,
                value: account.Id
            }));
            if(data.length==1){
                this.accountId = data[0].Id;
            }
        } else if (error) {
            console.error('Error fetching owned accounts: '+error.body.message, error);
        }
    }

    //Contact 목록 값 가져오기
    @wire(getContacts)
    wiregetContacts({ error, data }) {
        if (data) {
            this.contactOptions = data.map(contact => ({
                label: contact.Name,
                value: contact.Id
            }));
        } else if (error) {
            console.error('Error fetching accounts:', error);
        }
    }

    handleAccountChange(event) {
        this.accountId = event.detail.value;
    }

    handleContactChange(event) {
        this.contactId = event.detail.value;
    }
    handleNameChange(event) {
        this.opportunityName = event.detail.value;
    }
    handleDateChange(event) {
        this.closeDate = event.detail.value;
    }
    handleFirstNameChange(event) {
        this.firstName = event.detail.value;
    }
    handleLastNameChange(event) {
        this.lastName = event.detail.value;
    }
    handleTelChange(event) {
        this.phone = event.detail.value;
    }
    handleEmailChange(event) {
        this.email = event.detail.value;
    }

    //블러 처리
    handleFocus(event) {
        event.target.blur();
    }
    
    //토글 켜고 끄는 동작
    toggle1() {
        this.contactId='';
        this.isCustomerInfoVisible = false;
    }
    toggle2() {
        this.isCustomerInfoVisible = true;
    }

    validationCheck() {
        // 필수 필드 미입력 상태 확인
        if (!this.opportunityName || !this.accountId || !this.closeDate) {
            this.showToast('Error', requError, 'error');
            return false;
        }
    
        // ContactId가 입력되었고, 고객 정보도 일부 입력되었는지 확인
        else if (this.contactId && (this.firstName || this.lastName || this.phone || this.email)) {
            this.showToast('Error', bothError, 'error');
            return false;
        }
    
        // 고객 정보가 부분적으로만 입력된 경우
        else if ((this.firstName || this.lastName || this.phone || this.email) &&
            (!this.firstName || !this.lastName || !this.phone || !this.email)) {
            this.showToast('Error', allError, 'error');
            return false;
        }
        return true;
    }
    
    createOpportunity() {
        //먼저 유효성 검사
        if(this.validationCheck()){ 
            if(!this.contactId && this.email){ //첫방문 상담
                createFirstConsult({ opportunityName: this.opportunityName, accountId: this.accountId, closeDate: this.closeDate, firstName: this.firstName, lastName: this.lastName, phone: this.phone, email: this.email })
                .then(result => {
                    this.recordId = result;
                    this.navigateToRecordPage();
                })
                .catch(error => {
                    console.error('Error: '+error.body.message, error);
                });
            }
            else if(!this.firstName && this.contactId){ //재방문 상담
                createRevisitConsult({ opportunityName: this.opportunityName, accountId: this.accountId, closeDate: this.closeDate, contactId: this.contactId })
                .then(result => {
                    this.recordId = result;
                    this.navigateToRecordPage();
                })
                .catch(error => {
                    console.error('Error: '+error.body.message, error);
                });
            }
            else{
                createSimpleConsult({ opportunityName: this.opportunityName, accountId: this.accountId, closeDate: this.closeDate })
                .then(result => {
                    this.recordId = result;
                    this.navigateToRecordPage();
                })
                .catch(error => {
                    console.error('Error: '+error.body.message, error);
                });
            }
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    navigateToRecordPage() {
        const baseUrl = 'https://csstest2.lightning.force.com';
        const url = `${baseUrl}/lightning/r/Opportunity/${this.recordId}/view`;
        window.location.href = url;
    }

    holdContact(event){
        this.phoneNum = event.target.value;
    }

    //Enter키 동작
    pressEnter(event) {
        if (event.keyCode === 13) {
            this.searchContact();
        }
    }

    //사용자가 입력한 번호가 존재하는지 검색
    searchContact(){
        this.displayConList=true;
        if(!this.pageNum){
            this.pageNum+=1;
        }
        
        if(this.phoneNum){
            let searchNum = this.phoneNum.replace(/[^0-9]/g, '');
            searchPhoneWithOffset({searchNum:searchNum, pageNum:this.pageNum, recordPerPage:this.recordPerPage}).then(result => {
                if(result.length == 0){
                    console.log('search fail');
                    this.pageNum-=1;
                } 
                if(result) {
                    console.log(result);
                    console.log('1');
                    const contacts = result.map(contact => {
                        return {
                            RowNum : contact.RowNum,
                            Id: contact.Id,
                            Name: contact.Name,
                            Phone: contact.Phone,
                            Type__c: (contact.Type === 'purchased') ? purchased : not_purchased   
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
        } else{
            console.log('null');
        }
    }

    firstSearch(){
        this.pageNum=1;
        this.searchContact();
    }

    leftPage(){
        this.pageNum-=1;
        this.searchContact();
    }

    rightPage(){
        this.pageNum+=1;
        this.searchContact();
    }

    //해당 contact 레코드로 이동
    openContact(event){
        this.contactId = event.detail.row.Id;
        this.displayConList=false;
    }

}