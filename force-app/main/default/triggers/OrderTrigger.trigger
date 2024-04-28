trigger OrderTrigger on Order (after insert, after update) {
    OrderTriggerHandler handler = new OrderTriggerHandler();
   
    List<Id> contactIds = new List<Id>();
    List<Order> updatedOrders = new List<Order>();
    List<Order> ordersWithDiscountRateChanged = new List<Order>();
    List<Order> oldOrdersForDiscountRateChange = new List<Order>();


    //Order 레코드에서 ContactId 추출 및 status 변경 확인
    for (Order ord : Trigger.new) {
        if (ord.Contact__c != null) {
            contactIds.add(ord.Contact__c);
        }


        // Update 상황에서만 status 변경 확인
        if (Trigger.isUpdate) {
            Order oldOrder = Trigger.oldMap.get(ord.Id);
            if (oldOrder.Status != ord.Status) {
                updatedOrders.add(ord);
            }
            // 할인율 변경 확인
            if (oldOrder.DiscountRate__c  != ord.DiscountRate__c ) {
                ordersWithDiscountRateChanged.add(ord);
                oldOrdersForDiscountRateChange.add(oldOrder);
            }
        }
    }
   
    if (Trigger.isInsert) {
        handler.afterInsert(Trigger.new);
        if (!contactIds.isEmpty()) {
            handler.getLaptopOrdersForContact(contactIds);
        }
    } else if (Trigger.isUpdate) {
        if (!updatedOrders.isEmpty()) {
            // handler.statusUpdate(Trigger.old, updatedOrders);
            handler.getLaptopOrdersForContact(contactIds);
        }
        if (!ordersWithDiscountRateChanged.isEmpty()) {
            handler.handleDiscountRateChange(oldOrdersForDiscountRateChange, ordersWithDiscountRateChanged);
            handler.getLaptopOrdersForContact(contactIds);
        }
     }
}