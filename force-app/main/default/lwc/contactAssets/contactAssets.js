import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import ProfileName  from '@salesforce/schema/User.Profile.Name';
import getAssets from '@salesforce/apex/ContactAssetsController.getAssets';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import VOC_ASSET_CHANNEL from '@salesforce/messageChannel/vocAssetMessageChannel__c';
import { publish, MessageContext } from 'lightning/messageService';
import searchPlaceholder from '@salesforce/label/c.searchPlaceholder';
import Assets from '@salesforce/label/c.Assets';
import HQ_Team from '@salesforce/label/c.HQ_Team';
import System_Administrator from '@salesforce/label/c.System_Administrator';
import vocMessage from '@salesforce/label/c.vocMessage';
import Asset_Name from '@salesforce/label/c.Asset_Name';
import ProductName from '@salesforce/label/c.ProductName';
import SerialNumber from '@salesforce/label/c.SerialNumber';
import PurchaseDate from '@salesforce/label/c.PurchaseDate';

export default class ContactAssets extends NavigationMixin(LightningElement) {

    label = {
        searchPlaceholder,Assets, 	vocMessage, HQ_Team, System_Administrator
    };
    @api recordId;
    @track searchKey = ''; // 검색어 상태 관리
    @track assetCount = 0; // 자산 개수 초기화
    @track assets = [];    // 자산 데이터를 저장할 변수 초기화
    @track selectedRow = '';
    @track contactId = '';
    userId = Id;
    userProfileName;

    @track columns = [
        { label: Asset_Name, fieldName: 'Name', type: 'button',
            typeAttributes: { label: { fieldName: 'Name' }, variant: 'base' }},
        { label: ProductName, fieldName: 'ProductName', type: 'text' },
        { label: SerialNumber, fieldName: 'SerialNumber' },
        { label: PurchaseDate, fieldName: 'PurchaseDate', type: 'date' },
    ];

    @wire(getAssets, { contactId: '$recordId' })
    wiredAssets(response) {
        if (response.data) {
            this.assets = response.data;
            this.assetCount = response.data.length; // 쿼리된 자산의 개수 업데이트
        } else if (response.error) {
            // 에러 처리
            this.assets = [];
            this.assetCount = 0;
        }
    }

    get processedAssets() {
        // 이제 assets 필드를 기반으로 데이터 처리
        return this.assets.map(asset => {
            const { Product2, Id, ...otherProps } = asset;
            return { ProductName: Product2.Name, Id, ...otherProps };
        }).filter(asset => {
            const searchKeyLower = this.searchKey.toLowerCase();
            return !this.searchKey || asset.Name.toLowerCase().includes(searchKeyLower)
                || asset.ProductName.toLowerCase().includes(searchKeyLower)
                || (asset.SerialNumber && asset.SerialNumber.toLowerCase().includes(searchKeyLower));
        });
    }

    handleSearch(event) {
        this.searchKey = event.target.value;
    }
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

    getSelectedName(event) {
        // Display the Contact of the selected rows
        event.detail.selectedRows.forEach((selectedRow) => {
            this.selectedRow = selectedRow.Id;
            this.contactId = this.recordId;
        });
    }

    @wire(MessageContext)
    messageContext;

    //사용자의 프로필 정보 가져오기
    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
            }
        }
    }

    //사용자 프로필에 따라 voc생성 버튼 활성화
    get havePermission(){
        if(this.userProfileName === HQ_Team || this.userProfileName === System_Administrator){
            return true;
        }
    }

    //voc 진행
    doVoc(){
        if(this.selectedRow != ''){
            const caseAssetId = this.selectedRow;
            const messagePayload = { recordId: caseAssetId };
            publish(this.messageContext, VOC_ASSET_CHANNEL, messagePayload);
        } else{
            this.showToast("Error", vocMessage,"error");

        }
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