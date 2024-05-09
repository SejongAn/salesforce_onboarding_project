import { LightningElement, api } from 'lwc';

export default class CaseDescriptionEditor extends LightningElement {
  @api recordId;

  openModal() {
    const modal = this.template.querySelector('c-edit-case-description-modal');
    if(modal) {
      modal.open();
    }
  }
}