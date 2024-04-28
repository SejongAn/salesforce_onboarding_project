import { LightningElement, wire,track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import USER_ID from '@salesforce/user/Id'

export default class HrLWC extends LightningElement {

    @track displayComponent;

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD] })
    userData({ error, data }) {
        if (data) {
            const profileName = getFieldValue(data, PROFILE_NAME_FIELD);
            // 특정 프로필 이름을 기준으로 컴포넌트 표시 결정
            if(profileName === 'System Administrator' || profileName === '시스템 관리자'|| profileName === 'Sales Team'){
                this.displayComponent = true;
            }
        } else if (error) {
            console.error('Error retrieving user data', error);
        }
    }
    
}