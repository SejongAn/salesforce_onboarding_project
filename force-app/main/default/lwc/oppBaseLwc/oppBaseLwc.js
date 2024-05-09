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
    //Custom Label 모음 배열
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

    //contact datatable에 표시될 columns 정의
    columns = [
        { label: '', fieldName: 'RowNum',hideDefaultActions: true}, //첫열은 rownum 표시 label은 공백, 상단 드롭다운 버튼 삭제
        { label: COM_LAB_NAME, fieldName: 'Name' , type: 'button' ,typeAttributes: { label: { fieldName: 'Name' }, variant: 'base' }},
        //2열은 contact의 이름표시, 버튼 효과 삽입으로 rowaction 동작하게 함
        { label: COM_LAB_PHONE, fieldName: 'Phone', hideDefaultActions: true} //3열은 전화번호, 상단 드롭다운 버튼 삭제
    ];

    //생성된 Oppty Record Id 담을 변수
    recordId;

    //입력 받는 변수
    opportunityName;
    accountId;
    contactId;
    closeDate;
    firstName='';
    lastName='';
    phone='';
    email='';

    //처음에 가져오는 account와 contact map을 담을 변수
    @track accountOptions;
    @track contactOptions;

    //화면 구성요소 표시여부 스위치
    isCustomerInfoVisible = true;
    displayComponent = false;
    displayConList = true;

    //검색 부분 변수
    phoneNum; //input에 입력되는 검색할 값
    result; //결과가 담길 변수
    error; //에러가 담길 변수

    //User Id 변수에 할당(동적으로 변수 사용하기 위함)
    userId = USER_ID;

    //페이지네이션 변수 초기값 설정
    recordPerPage=5; //한 페이지에 몇개의 contact레코드를 보여줄 것인지
    pageNum=1; //시작페이지는 1페이지
    
    

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

    //Account목록 가져오기(userId동적 사용으로 userId값이 바뀔때 마다 실행
    //시작 시 Account List를 못가져오던 문제를 변수 동적사용으로 해결
    @wire(getAccounts, { userId: '$userId' })
    wiredOwnedAccounts({ error, data }) {
        if (data) {
            this.accountOptions = data.map(account => ({ //가져온 Account List, accountOptions에 넣어주기
                label: account.Name,
                value: account.Id
            }));
            if(data.length==1){
                this.accountId = data[0].Id;
                //가져온 Account List의 길이가 1 일때(Account가 1개만 있을때) accountId에 Account넣어줌으로서 combo-box에서 해당 Account 바로 보이게함
            }
        } else if (error) {
            console.error('Error fetching owned accounts: '+error.body.message, error);
        }
    }

    //Contact 목록 값 가져와서 Contact combobox에 저장 -> 나중에 검색으로 Id값을 찾고 해당 Id값을 combo-box에서 선택 ->해당 Contact Id의 Contact Name을 보여줌
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

    //input의 값이 변경되면, 변경 값 연결된 변수에 입력
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
    holdContact(event){ //
        this.phoneNum = event.target.value;
    }

    //Contact input의 Enter키 동작(Enter키로도 검색 가능하게)
    pressEnter(event) {
        if (event.keyCode === 13) { //눌려진 키가 Enter라면
            this.firstSearch(); //검색
        }
    }

    //contact combobox 블러 처리
    handleFocus(event) {
        event.target.blur();
    }
    
    //토글 켜고 끄는 동작
    toggle1() { //신규고객정보 입력창으로 이동
        this.contactId=''; //갈때 contact combo-box 내용 지우기(안지워져있으면 신규고객정보랑 동시 입력으로 입력 불가)
        this.isCustomerInfoVisible = false;
    }
    toggle2() { //재방문 고객 선택창으로 이동
        this.isCustomerInfoVisible = true;
    }

    //필드 입력 상태 확인
    validationCheck() {
        // 필수 필드 미입력 상태 확인
        if (!this.opportunityName || !this.accountId || !this.closeDate) {
            this.showToast('Error', requError, 'error');
            return false;
        }
    
        // 재방문 고객 정보와 신규 고객 입력은 동시에 있을 수 없음
        if (this.contactId && (this.firstName || this.lastName || this.phone || this.email)) {
            this.showToast('Error', bothError, 'error');
            return false;
        }
    
        // 신규 고객 정보 입력 필드 중 일부만 입력x 모두 다 입력 되어있어야함
        if ((this.firstName || this.lastName || this.phone || this.email) &&
            (!this.firstName || !this.lastName || !this.phone || !this.email)) {
            this.showToast('Error', allError, 'error');
            return false;
        }
        return true;
    }

    //create(생성) 버튼 누를 시 상담(Opportunity)생성하는 메소드
    createOpportunity() {
        if(this.validationCheck()){ //필드 입력 상태 검사
            if(!this.contactId && this.email){ //contact-combobox가 비어있고, 고객 정보(email만 체크)는 입력되어 있다면 -> "첫방문 상담" 레코드 타입
                createFirstConsult({ opportunityName: this.opportunityName, accountId: this.accountId, closeDate: this.closeDate, firstName: this.firstName, lastName: this.lastName, phone: this.phone, email: this.email })
                .then(result => {
                    this.recordId = result; //해당 레코드 타입으로 상담이 성공적으로 생성 되었다면 record id를 반환함. 반환된 record Id를 변수에 담고
                    this.navigateToRecordPage(); //생성된 상담 페이지로 record Id를 활용해서 이동
                })
                .catch(error => {
                    console.error('Error: '+error.body.message, error);
                });
            }
            if(!this.email && this.contactId){ //contact-combobox가 입력되고, 고객 정보(email만 체크)는 미입력이라면 -> "재방문 상담" 레코드 타입
                createRevisitConsult({ opportunityName: this.opportunityName, accountId: this.accountId, closeDate: this.closeDate, contactId: this.contactId })
                .then(result => {
                    this.recordId = result;
                    this.navigateToRecordPage();
                })
                .catch(error => {
                    console.error('Error: '+error.body.message, error);
                });
            }
            if(!this.email && !this.contactId){ //contact-combobox와 고객 정보(email만 체크) 둘다 미입력 이라면 -> "단순 상담" 레코드 타입
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

    //record id 상담 페이지 이동 메소드
    navigateToRecordPage() {
        const baseUrl = 'https://csstest2.lightning.force.com';
        const url = `${baseUrl}/lightning/r/Opportunity/${this.recordId}/view`;
        window.location.href = url; //이동!
    }

    //pageNum기준으로 연락처 검색
    searchContact(){
        this.displayConList=true; //검색 결과(Contact datatable,pagenation button 표시)
        if(this.phoneNum){ //phoneNum가 입력되어 있다면
            let searchNum = this.phoneNum.replace(/[^0-9]/g, '');
            searchPhoneWithOffset({searchNum:searchNum, pageNum:this.pageNum, recordPerPage:this.recordPerPage}).then(result => {
                if(result.length == 0){ //검색 된 값이 없다면
                    console.log('search fail');
                } 
                if(result) {
                    const contacts = result.map(contact => {
                        return {
                            RowNum : contact.RowNum,
                            Id: contact.Id,
                            Name: contact.Name,
                            Phone: contact.Phone,
                            Type__c: (contact.Type === 'purchased') ? purchased : not_purchased   
                        };   
                    });
                    this.pageNum=result[0].pageNum;
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

    //검색 버튼 누를 시 (검색 내용 초기화, 재검색)
    firstSearch(){
        this.pageNum=1; //페이지 1로 초기화
        this.searchContact(); //연락처 검색
    }

    //이전 페이지 버튼 누를 시
    leftPage(){
        this.pageNum-=1; //페이지 감소
        this.searchContact(); //연락처 검색
    }

    //다음 페이지 버튼 누를 시
    rightPage(){
        this.pageNum+=1; //페이지 증가
        this.searchContact(); //연락처 검색
    }

    //해당 contact 레코드로 이동
    openContact(event){
        this.contactId = event.detail.row.Id;
        this.displayConList=false;
    }
    
    //Toast Message 사용 메소드
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

}