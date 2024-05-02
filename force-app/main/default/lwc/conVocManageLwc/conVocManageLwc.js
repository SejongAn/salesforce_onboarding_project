import { LightningElement,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, MessageContext } from 'lightning/messageService';
import VOC_ASSET_CHANNEL from '@salesforce/messageChannel/vocAssetMessageChannel__c';
import searchCase from '@salesforce/apex/CaseController.searchCase';
import insertCase from '@salesforce/apex/CaseController.insertCase';
import caseSubject from '@salesforce/label/c.caseSubject';
import caseDescription from '@salesforce/label/c.caseDescription';
import caseType from '@salesforce/label/c.caseType';
import caseReason from '@salesforce/label/c.caseReason';
import caseStatus from '@salesforce/label/c.caseStatus';
import caseCreatedDate from '@salesforce/label/c.caseCreatedDate';
import Asset from '@salesforce/label/c.Asset';
import Warranty_Period from '@salesforce/label/c.Warranty_Period';
import Warranty_Information from '@salesforce/label/c.Warranty_Information';
import Replaceable_Date from '@salesforce/label/c.Replaceable_Date';
import Warranty_Status from '@salesforce/label/c.Warranty_Status';
import Create_VOC from '@salesforce/label/c.Create_VOC';
import VOC_Information from '@salesforce/label/c.VOC_Information';
import Question from '@salesforce/label/c.Question';
import AS from '@salesforce/label/c.AS';
import createSuccess from '@salesforce/label/c.createSuccess';
import createError from '@salesforce/label/c.createError';
import Free_Repair from '@salesforce/label/c.Free_Repair';
import Paid_Repair from '@salesforce/label/c.Paid_Repair';
import Replacement from '@salesforce/label/c.Replacement';
import Replaceable_Free_Repair from '@salesforce/label/c.Replaceable_Free_Repair';
import User_didn_t_attend_training from '@salesforce/label/c.User_didn_t_attend_training';
import New_problem from '@salesforce/label/c.New_problem';
import Existing_problem from '@salesforce/label/c.Existing_problem';
import Complex_functionality from '@salesforce/label/c.Complex_functionality';
import Instructions_not_clear from '@salesforce/label/c.Instructions_not_clear';

const FIELDS = ["Asset.Name", "Asset.PurchaseDate", "Asset.Replaceable_Date__c", "Asset.Warranty_End_Date__c", "Asset.Warranty_status__c", "Asset.ContactId"];
const columns = [
    { label:'Case No', fieldName: 'CaseNumber', type: 'button',
        typeAttributes: { label: { fieldName: 'CaseNumber' }, variant: 'base' }},
    { label: caseSubject, fieldName: 'Subject', type: 'text' },
    { label: caseType, fieldName: 'Type', type: 'text' },
    {label: caseCreatedDate, fieldName: 'CreatedDate', type:'date'},
];

export default class ConVocManageLwc extends NavigationMixin(LightningElement) {
    label = {
        Asset,Warranty_Period,Warranty_Information,Replaceable_Date,Warranty_Status,
        caseSubject,caseDescription,caseType,caseReason,caseStatus,caseCreatedDate,
        Create_VOC,VOC_Information, AS, Question, createSuccess, createError,
        Free_Repair, Paid_Repair, Replaceable_Free_Repair, Replacement,
        User_didn_t_attend_training, New_problem, Existing_problem, Complex_functionality, Instructions_not_clear
    };
    caseAssetId;
    columns = columns;
    @track asset = {
        Name: '',
        PurchaseDate: '',
        Replaceable_Date__c: '',
        Warranty_End_Date__c: '',
        Warranty_status__c: '',
        ContactId: ''
    };
    @track cases;
    typeValue;
    typeOptions = [
        {value: 'Question', label: Question},
        {value: 'AS', label: AS}
    ];
    reasonValue;
    @track reasonOptions = [];
    Subject;
    Description;

    /*자산 목록 컴포넌트에서 선택한 자산 정보를 pub-sub으로 넘겨받음*/
    @wire(MessageContext)
    messageContext;

    subscription;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            VOC_ASSET_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        this.caseAssetId = message.recordId;
        this.typeValue = null;
        this.reasonValue = null;
        this.Subject = null;
        this.Description = null;
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    /*VoC 진행 관련*/
    //1.선택한 asset에 대한 정보 가져옴
    @wire(getRecord, { recordId: '$caseAssetId', fields: FIELDS })
    wiredAsset({ error, data }) {
        if (data) {
            const assetRecord = data.fields;
            this.asset = {
                Name: assetRecord.Name.value,
                PurchaseDate: assetRecord.PurchaseDate.value,
                Replaceable_Date__c: assetRecord.Replaceable_Date__c.value,
                Warranty_End_Date__c: assetRecord.Warranty_End_Date__c.value,
                Warranty_status__c: assetRecord.Warranty_status__c.value,
                ContactId: assetRecord.ContactId.value
            };

        } else if (error) {
            console.error('error', error);
        }
    }

    //2.선택한 asset에 대해 관련된 case record 유무 확인 후 있으면 데이터테이블로 나타냄
    @wire(searchCase, { assetId: '$caseAssetId'})
    wiredCase({ error, data }) {
        if (data == null) {
            this.cases = undefined;
            this.error = error;
        } else{
            this.cases = data.map(eachCase =>{
                return {
                    Id: eachCase.Id,
                    CaseNumber : eachCase.CaseNumber,
                    Subject: eachCase.Subject,
                    Type: (eachCase.Type === Question)? Question : AS,
                    CreatedDate: eachCase.CreatedDate
                };
            })
            this.error = undefined;
        }
    }

    //2-1.데이터테이블 내 해당 Case record 오픈
    openRecord(event){
        const caseId = event.detail.row.Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }

    //3-1.Type field value tracking & Reason field value setting
    handleTypeChange(event){
        this.typeValue = event.detail.value;
        if(this.typeValue === Question){
            this.reasonOptions = [
                {value: "User didn't attend training", label: User_didn_t_attend_training },
                {value: 'Complex functionality', label: Complex_functionality},
                {value: 'Existing problem', label: Existing_problem},
                {value: 'New problem', label: New_problem},
                {value: 'Instructions not clear', label: Instructions_not_clear},
            ];
        } else if(this.typeValue === AS){
            this.reasonOptions = [];
            if (this.asset.Warranty_status__c === Replaceable_Free_Repair) {
                this.reasonOptions.push({value: '교체', label: Replaceable_Free_Repair});
                this.reasonOptions.push({value: '무상AS', label: Free_Repair});
            }
            if (this.asset.Warranty_status__c === Free_Repair) {
                this.reasonOptions.push({value: '무상AS', label: Free_Repair});
            }

            this.reasonOptions.push({value: '유상AS', label: Paid_Repair});
        }
    }

    //3-2.Reason field value tracking
    handleReasonChange(event){
        this.reasonValue = event.detail.value
    }

    //3-3.Subject field value tracking
    handleSubjectChange(event){
        this.Subject = event.detail.value
    }

    //3-4.Description field value tracking
    handleDescriptionChange(event){
        this.Description = event.detail.value
    }

    //4.VoC 생성 function
    doCreation(){
        insertCase({Subject: this.Subject, Description: this.Description, Type: this.typeValue, Reason: this.reasonValue, AssetId: this.caseAssetId, ContactId: this.asset.ContactId}).then((result) => {
            this.showToast("Success",createSuccess,"success");
            setTimeout(() => {
                window.location.reload();
            }, 600);
        })
            .catch((error) => {
                this.showToast("Error",createError,"error");
            });
    }

    //toast 발생 function
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}