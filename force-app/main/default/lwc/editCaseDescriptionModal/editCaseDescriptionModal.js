import { LightningElement, api } from 'lwc';
import CASE_DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import CASE_ID_FIELD from '@salesforce/schema/Case.Id';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EditCaseDescriptionModal extends LightningElement {
  @api recordId;
  @api description;
  @api isOpen = false;  // 추가된 부분: 모달의 열림 상태를 관리합니다.

  handleDescriptionChange(event) {
    this.description = event.target.value;
  }

  @api
  open() {
    this.isOpen = true;  // 모달을 열기 위해 isOpen 상태를 true로 설정합니다.
  }

  @api
  close() {
    this.isOpen = false;  // 모달을 닫기 위해 isOpen 상태를 false로 설정합니다.
    this.dispatchEvent(new CustomEvent('close'));
  }

  save() {
    const fields = {};
    fields[CASE_ID_FIELD.fieldApiName] = this.recordId;
    fields[CASE_DESCRIPTION_FIELD.fieldApiName] = this.description;

    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Case Description Updated',
            variant: 'success'
          })
        );
        this.close();
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error updating record',
            message: error.body.message,
            variant: 'error'
          })
        );
      });
  }
}