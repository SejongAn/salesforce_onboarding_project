import { api, LightningElement, track, wire } from "lwc";
import getOpportunities from "@salesforce/apex/OrderCreate.getOpportunities";
import getOpportunityProducts from "@salesforce/apex/OrderCreate.getOpportunityProducts";
import isPriceBookActiveForOpportunity from "@salesforce/apex/OrderCreate.isPriceBookActiveForOpportunity";
import getProductOptions from "@salesforce/apex/OrderCreate.getProductOptions"; // Apex 메서드를 가져오는 부분
import createOrder from "@salesforce/apex/OrderCreate.createOrder";
import saveProductToOpportunity from "@salesforce/apex/OrderCreate.saveProductToOpportunity"; //제품 수정
import deleteOpportunityLineItem from "@salesforce/apex/OrderCreate.deleteOpportunityLineItem";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import { NavigationMixin } from "lightning/navigation";
import getProductDetailsWithPrice from "@salesforce/apex/OrderCreate.getProductDetailsWithPrice";
import getPaymentPicklistValues from "@salesforce/apex/OrderCreate.getPaymentPicklistValues";

import addProduct from "@salesforce/label/c.addProduct";
import CreateanOrder from "@salesforce/label/c.CreateanOrder";
import Refresh from "@salesforce/label/c.Refresh";
import selectConsultation from "@salesforce/label/c.selectConsultation";
import DiscountRateA from "@salesforce/label/c.DiscountRateA";

import DiscoutAmount from "@salesforce/label/c.DiscoutAmount";
import CreateOrder from "@salesforce/label/c.CreateOrder";
import Cancellation from "@salesforce/label/c.Cancellation";
import MaxDiscountRate from "@salesforce/label/c.MaxDiscountRate";
import MinDiscountRate from "@salesforce/label/c.MinDiscountRate";
import FinalPrice from "@salesforce/label/c.FinalPrice";
import OrderDateA from "@salesforce/label/c.OrderDateA";
import OrderDescription from "@salesforce/label/c.OrderDescription";
import PaymentMethod from "@salesforce/label/c.PaymentMethod";
import ProductCode from "@salesforce/label/c.ProductCode";
import ProductFamily from "@salesforce/label/c.ProductFamily";
import ProductName from "@salesforce/label/c.ProductName";
import QuantityA from "@salesforce/label/c.QuantityA";
import Save from "@salesforce/label/c.Save";
import SelectAProduct from "@salesforce/label/c.SelectaProduct"; // 이름 확인 필요
import SelectPayment from "@salesforce/label/c.SelectPayment";
import SelectProduct from "@salesforce/label/c.SelectProduct";
import TotalPrice from "@salesforce/label/c.TotalPrice";
import UnitPriceA from "@salesforce/label/c.UnitPriceA";
import lang from '@salesforce/i18n/lang';


export default class OrderCreate extends NavigationMixin(LightningElement) {

    label = {
        DiscoutAmount,
        DiscountRateA,
        addProduct,
        CreateanOrder,
        Refresh,
        selectConsultation,
        CreateOrder,
        Cancellation,
        MaxDiscountRate,
        MinDiscountRate,
        FinalPrice,
        OrderDateA,
        OrderDescription,
        PaymentMethod,
        ProductCode,
        ProductFamily,
        ProductName,
        QuantityA,
        Save,
        SelectAProduct,
        SelectPayment,
        SelectProduct,
        TotalPrice,
        UnitPriceA
    };

    @track opportunityOptions = [];
    @track selectedOpportunityId = '';
    @track currencyIsoCode; //기본 통화 한국

    @track opportunityProducts = [];
    @track discountRate = 0;
    @track totalAmount = 0;      //총 제품 금액
    @track discountedAmount = 0; //할인된 최종 금액
    @track discountMoney = 0;    //할인된 금액
    @track orderDate;   //날짜 보여주는 용
    @track minDate;     //형식 다름 주의 이건 내부 날짜
    @track selectedProductDetails = {
        Name: '',
        ProductCode: '',
        Family: ''
    };    
    @track selectedProductPrice='0';

    @track formattedTotalAmount = 0; 
    @track formattedDiscountedAmount = 0;
    @track formattedDiscountMoney = 0;
    wiredOpportunityProductsResult;
    @track description = '';
    @track status = '구매'; //수정 필요 예시로 띄워둠 apex에서 추가 수정
    @api recordId;
    @track isModalOpen = false;
    @track selectedProductId;
    @track selectedQuantity;
    @track isAddButtonDisabled = true;

    @track isEditMode = false; // 제품 수정 모드 여부
    @track selectedLineItemId = ''; // 수정할 제품의 Line Item ID

    @track paymentOptions = []; //결제 방식
    selectedValue;

    @track productOptions = [];
    @track pricebookFlag = false;
    
    @wire(getProductOptions)
    wiredProductOptions({ error, data }) {
        if (data) {
            this.productOptions = data.map(product => ({
                label: product.label, // 또는 제품명을 표시하는 데 사용하는 다른 필드
                value: product.value
            }));
        } else if (error) {
            console.error('Error:', error);
        }
    }

    handleQuantityChange(event) { 
        this.selectedQuantity = event.detail.value;
        this.updateTotalAmount();
        this.calculateDiscountedAmount();
    }
    updateTotalAmount() {
        if (this.selectedProductPrice && this.selectedQuantity) {
            this.totalAmount = parseFloat(this.selectedProductPrice) * parseInt(this.selectedQuantity);
            this.formattedTotalAmount = this.formatCurrency(this.totalAmount);
        }
    }

    // 제품 상세 정보 업데이트 로직을 별도의 함수로 분리
    updateProductDetails(productId) {
        if (productId) {
            getProductDetailsWithPrice({ productId })
                .then(result => {
                    if (result && result.product) {
                        this.selectedProductDetails = result.product;
                        this.selectedProductPrice = this.formatCurrency(result.unitPrice);
                        
                    } else {
                        this.selectedProductDetails = {};
                        this.selectedProductPrice = 0;
                    }
                })
                .catch(error => {
                    this.selectedProductDetails = {};
                    this.selectedProductPrice = 0;
                });
        } else {
            this.selectedProductDetails = {};
            this.selectedProductPrice = 0;
        }
    }

    // handleProductChange 함수 수정: 이벤트 처리에 집중
    handleProductChange(event) {
        this.selectedProductId = event.detail.value;
        this.updateProductDetails(this.selectedProductId);
    }
    

    actions = [
        { label: 'Delete', name: 'delete' }
    ];

    columns = [
        { label: this.label.ProductFamily, fieldName: 'ProductFamily', type: 'text' },
        { label: this.label.ProductName, fieldName: 'Name', type: 'text' },
        //{ label: '제품 코드', fieldName: 'ProductCode', type: 'text' },
        { label: this.label.QuantityA, fieldName: 'Quantity', type: 'number' },
        { label: this.label.UnitPriceA, fieldName: 'ListPrice', type: 'currency' },
        {
            type: 'action',
            typeAttributes: { rowActions: this.getRowActions.bind(this) },
        },    
    ];
    
    getRowActions(row, doneCallback) {
        const actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];
        doneCallback(actions);
    }

    connectedCallback() {
        if(this.selectedOpportunityId) {
            this.refreshOpportunityLineItems();
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const rowId = event.detail.row.Id;
    
        if (actionName === 'delete') {
            this.deleteOpportunityProduct(rowId);
        } else if (actionName === 'edit') {
            this.editOpportunityProduct(rowId);
        }
    }

// 이 메서드는 "편집" 작업이 선택되면 트리거됩니다.
    editOpportunityProduct(lineItemId) {
    this.isEditMode = true;
    this.selectedLineItemId = lineItemId; // 광고 항목 ID가 올바르게 설정되었는지 확인합니다.
    const selectedProduct = this.opportunityProducts.find(product => product.Id === lineItemId);
    if (selectedProduct) {
        this.selectedProductId = selectedProduct.ProductId;
        this.selectedQuantity = selectedProduct.Quantity;
        this.updateProductDetails(this.selectedProductId); // selectedProductId를 기반으로 제품 세부정보를 업데이트합니다.
        this.isModalOpen = true;
    }
}

    handleAddProductClick() {
        this.isModalOpen = true; // 모달 열기
    }
    closeModal() {
        this.isModalOpen = false; // 모달 닫기
    }
    
    saveProduct() {
        if (!this.selectedOpportunityId) {
            return;
        }

        const params = this.isEditMode ? {
            lineItemId: this.selectedLineItemId,
            opportunityId: this.selectedOpportunityId,
            productId: this.selectedProductId,
            quantity: Number(this.selectedQuantity)
        } : {
            opportunityId: this.selectedOpportunityId,
            productId: this.selectedProductId,
            quantity: Number(this.selectedQuantity)
        };

        if(this.selectedQuantity < 1 || this.selectedQuantity>100){
            this.showToast('Error', (lang == 'ko') ?'1~100개의 주문만 생성이 가능합니다.':"Successfully VoC Only 1 to 100 orders can be created", 'error');
            return;
        }
        this.selectedQuantity = Math.floor(this.selectedQuantity);

        saveProductToOpportunity(params)
            .then(result => {
                this.showToast('Success', (lang == 'ko') ?'제품이 성공적으로 추가/업데이트되었습니다.':"The product has been added/updated successfully.", 'Success');
                this.closeModal();
                this.updateOpportunityProductsAndPriceInfo();
                // 모드 및 선택된 제품 ID 초기화
                this.isEditMode = false;
                this.selectedLineItemId = '';
            })
            .catch(error => {
                this.showToast('Error', (lang == 'ko') ?'제품 추가/업데이트 중 오류가 발생했습니다:':"An error occurred while adding/updating products:", 'error');
                
            });
    }     
    deleteOpportunityProduct(lineItemId) {
        deleteOpportunityLineItem({ lineItemId })
            .then(() => {
                this.showToast('Success',(lang == 'ko') ?'제품을 성공적으로 삭제했습니다.':"You have successfully deleted the product." , 'success');
                
                this.updateOpportunityProductsAndPriceInfo(); // 제품 목록 및 가격 정보 업데이트
            })
            .catch(error => {
                // 에러 핸들링 개선
                console.error('삭제 에러:', error);
                this.showToast('Error', (lang == 'ko')?'상품 삭제 에러: ':"Product deletion error:", 'error');
            });
    }
    // 제품 목록 및 가격 정보 업데이트 함수
    updateOpportunityProductsAndPriceInfo() {
        refreshApex(this.wiredOpportunityProductsResult).then(() => {
            getOpportunityProducts({ opportunityId: this.selectedOpportunityId })
            .then(data => {
                this.opportunityProducts = data;
                this.totalAmount = data.reduce((total, product) => total + (product.ListPrice * product.Quantity), 0);
                // 화면용 금액 업데이트
                this.formattedTotalAmount = this.formatCurrency(this.totalAmount);
                this.calculateDiscountedAmount(); // 가격 정보 업데이트
            })
            .catch(error => {
                console.error('제품 목록 업데이트 중 오류 발생:', error);
            });
        });
    }        
    refreshOpportunityLineItems() {
        refreshApex(this.wiredOpportunityProductsResult).then(() => {
        });
    }      
    @wire(getOpportunities, { contactId: '$recordId' })
    wiredOpportunities(result) {
        this.wiredOpportunityResults = result;
        if (result.data) {
            this.opportunityOptions = result.data.map(opportunity => ({ label: opportunity.Name, value: opportunity.Id, closeDate: opportunity.CloseDate, currencyCode: opportunity.CurrencyIsoCode }));
        } else if (result.error) {
            this.showToast('Error', result.error.body.message, 'error');
        }
    }

    //여기가 opp골랐을때
    handleOpportunityChange(event) {
        this.selectedOpportunityId = event.target.value;
        if (this.selectedOpportunityId) {
            // 먼저 선택한 기회의 제품이 활성 가격 목록을 사용하는지 확인합니다.
            isPriceBookActiveForOpportunity({ opportunityId: this.selectedOpportunityId })
                .then(isActive => {
                    if (!isActive) {
                        // 가격 목록이 활성화되지 않은 경우 오류를 표시하고 재설정합니다.
                        this.showToast('Error',(lang == 'ko')? '선택한 상담의 제품이 활성화된 가격 책을 사용하지 않습니다.':"The products in the selected consultation do not use an activated price book.", 'error');
                        this.selectedOpportunityId = ''; // Reset selection
                        this.isAddButtonDisabled = true; // Ensure button is disabled
                    } else {
                        // 가격 목록이 활성화된 경우 기회 제품 가져오기를 진행합니다.
                        this.isAddButtonDisabled = false; // 기회가 선택되면 활성화 버튼
                        const selectedOpportunity = this.opportunityOptions.find(
                            opp => opp.value === this.selectedOpportunityId
                        );
                        if (selectedOpportunity) {
                            this.currencyIsoCode = selectedOpportunity.currencyCode; 
                        }
                        if (selectedOpportunity && selectedOpportunity.closeDate) {
                            this.minDate = this.formatDateForInput(selectedOpportunity.closeDate); // 기회에 따라 최소 날짜를 설정합니다.
                        }
                        getOpportunityProducts({ opportunityId: this.selectedOpportunityId })
                            .then(data => {
                                this.opportunityProducts = data;
                                this.totalAmount = data.reduce((total, product) => total + product.ListPrice * product.Quantity, 0);
                                this.formattedTotalAmount = this.formatCurrency(this.totalAmount);
                                this.calculateDiscountedAmount();
                            })
                            .catch(error => {
                                this.showToast('Error', error.body.message, 'error');
                            });
                    }
                })
                .catch(error => {
                    // Apex 호출에서 발생할 수 있는 오류를 처리합니다.
                    this.showToast('Error', (lang == 'ko')? '가격 책 활성 상태 확인 중 오류 발생':"Error checking price book activation status", 'error');
                    console.error('Error checking price book active status:', error);
                });
        } else {
            // 선택된 기회가 없으면 버튼을 비활성화합니다.
            this.isAddButtonDisabled = true;
        }
    }
    
    handleDiscountRateChange(event) {
        this.discountRate = event.target.value;
        this.calculateDiscountedAmount();
    }

    calculateDiscountedAmount() {
        if (this.discountRate > 20) {
            this.showToast('Error', (lang == 'ko')?'최대 할인율은 20%입니다.':"The maximum discount rate is 20%.", 'error');
            this.discountRate = 20;
        } else if (this.discountRate < 0) {
            this.showToast('Error',(lang == 'ko')? '할인율 음수는 입력 불가능합니다.':"Negative discount rates cannot be entered.", 'error');
            this.discountRate = 0;
        }
    
        this.discountedAmount = this.totalAmount * (1 - this.discountRate / 100);
        this.formattedDiscountedAmount= this.formatCurrency(this.discountedAmount);
        this.discountMoney = this.totalAmount - this.discountedAmount;
        this.formattedDiscountMoney = this.formatCurrency(this.discountMoney);
    }

    @wire(getPaymentPicklistValues) //결제 방식 선택하는 input
    wiredPaymentValues({ error, data }) {
        if (data) {
            this.paymentOptions = data.map(record => ({
                label: record.label, value: record.value
            }));
        } else if (error) {
            // 오류 처리
            console.error(error);
        }
    }

    handleChange(event) {
        this.selectedValue = event.detail.value;
    }

    handleInputChange(event) {
        this.description = event.target.value;
    }

    //주문생성 버튼 
    handleCreateOrder() {
        if(this.discountRate==null){
            this.discountRate=0;
        }
        else {
            this.discountRate=Math.floor(Number(this.discountRate)); //소수점 제거
        }
        if(this.orderDate == null || this.orderDate.trim() === ''){
            this.showToast('Error', '주문 날짜를 입력해주세요.', 'error');
            return; 
        }
        /*if(this.paymentOptions==null || this.paymentOptions.trim() === ''){
            this.showToast('Error', '결제 방식을 선택해주세요.', 'error');
            return;
        }*/
        const orderDateObj = new Date(this.orderDate);
        const minDateObj = new Date(this.minDate); 
        const currentDate = new Date();

        // 주문 날짜가 minDate보다 이르면 에러 메시지 표시
        if(orderDateObj < minDateObj) {
            this.showToast('Error', (lang == 'ko')?'주문 날짜는 최소 날짜 이후여야 합니다.':"Order date must be at least a few days later.", 'error');
            return;
        }
        if(orderDateObj > currentDate) {
            this.showToast('Error', (lang == 'ko')?'주문 날짜는 오늘을 넘어갈 수 없습니다.':"The order date cannot be later than today.", 'error');
            return;
        }
        createOrder({ opportunityId: this.selectedOpportunityId, discountRate: this.discountRate, description: this.description, status: this.status, contactId: this.recordId, day: this.orderDate, paymentMethod: this.selectedValue })
        .then((result) => { //사용은 안해도 일단 넣어둠
            this.refreshPage();
            this.showToast('Success', (lang == 'ko')?'판매가 성공적으로 생성되었습니다!':"Your sale has been created successfully!", 'success');
        })
        .catch((error) => {
            this.showToast('Error', error.body.message, 'error');
        });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    refreshComponentData() {
        refreshApex(this.wiredOpportunityResults);
    }
    refreshPage() {
        // 현재 페이지의 URL을 사용하여 페이지를 새로 고침
        window.location.reload();
    }
    formatCurrency(value) {
        if (isNaN(value)) {
            return "0"; // 값이 숫자가 아닌 경우 기본값은 "0"입니다.
        }    
        switch (this.currencyIsoCode) {
            case 'USD':
                return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value);
            case 'KRW':
                return new Intl.NumberFormat('ko-KR', { style: 'currency', currency: 'KRW' }).format(value);
            default:
                // 지정하지 않은 경우 USD로 대체
                return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value);
        }
    }
    @wire(getOpportunityProducts, { opportunityId: '$selectedOpportunityId' })
    wiredOpportunityProducts(result) {
        this.wiredOpportunityProductsResult = result; // 결과 저장
        if (result.data) {
            this.opportunityProducts = result.data;
            // 데이터 처리 로직...
        } else if (result.error) {
            // 에러 처리 로직...
        }
    } 
    //날짜
	handleDateChange(event) {
		this.orderDate = event.target.value;
	}

    //데이터 검사용 형식
    formatDateForInput(date) {
        if (date) {
            // UTC 기준으로 날짜 객체 생성
            const d = new Date(date);
            // 연, 월, 일을 UTC 기준으로 추출하여 형식에 맞게 변환합니다.
            const year = d.getUTCFullYear();
            const month = (d.getUTCMonth() + 1).toString().padStart(2, '0'); // 월은 0부터 시작하므로 1을 더해줍니다.
            const day = d.getUTCDate().toString().padStart(2, '0');
            // 'YYYY-MM-DD' 형식으로 문자열을 반환합니다.
            return `${year}-${month}-${day}`;
        }
        return null;
    }
}