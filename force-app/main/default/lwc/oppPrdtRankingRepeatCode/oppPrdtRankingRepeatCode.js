/**
 * Created by nate on 5/2/24.
 */

import {LightningElement, api} from 'lwc';
// import Laptop from '@salesforce/label/c.Laptop';
// import Accessories from '@salesforce/label/c.Accessories';



export default class OppPrdtRankingRepeatCode extends LightningElement {
    // label = { Laptop, Accessories };

    @api tableTitle = '';
    @api tableData = [];
    @api columns = [];

}