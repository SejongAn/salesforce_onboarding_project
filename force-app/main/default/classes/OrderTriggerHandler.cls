public without sharing class OrderTriggerHandler {
    // afterInsert: 고객 유형,  상담 단계,  주문제품 생성,  자산 생
    public void afterInsert(List<Order> newOrders) {
        try{
            // Order 객체의 필드에서 추출된 Id들을 저장할 List를 선언합니다.
            List<Id> oppIds = new List<Id>();
            List<Id> contactIds = new List<Id>();
            List<Id> orderIds = new List<Id>();
            List<Id> productIds = new List<Id>();

            // 새로 생성된 Order 객체들을 순회하며, 필요한 필드의 Id를 각각의 List에 추가합니다.
            for (Order order : newOrders) {
                oppIds.add(order.OpportunityId);
                contactIds.add(order.Contact__c);
                orderIds.add(order.Id);
            }

            // Order와 연결된 Contact의 Purchasing_Account__c 저장을 위한 Map 생성
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, AccountId,Purchasing_Account__c FROM Contact WHERE Id IN :contactIds]);

            // Contact들과 관련된 Asset을 조회하기 위한 Map을 생성합니다.
            Map<Id, List<Asset>> contactToAssetsMap = new Map<Id, List<Asset>>();

            // 고객의 Asset을 판별해서 인입지점 세팅을 위해 Contact 객체를 저장할 List 선언.
            List<Contact> contactsToUpdateForAccount = new List<Contact>();

            // SOQL 쿼리를 사용하여 추출한 OpportunityId를 가진 모든 OpportunityLineItem을 조회합니다.
            List<OpportunityLineItem> oppLineItems = [SELECT Id, OpportunityId, Product2Id, Quantity, UnitPrice, PricebookEntryId, PricebookEntry.Pricebook2Id FROM OpportunityLineItem WHERE OpportunityId IN :oppIds];

            // SOQL 쿼리를 사용하여 추출한 OpportunityId를 가진 모든 Opportunity를 조회하고, 이를 Map에 저장합니다.
            // 이 Map은 나중에 Order의 Pricebook2Id를 업데이트할 때 사용됩니다.
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Pricebook2Id FROM Opportunity WHERE Id IN :oppIds]);

            // SOQL 쿼리를 사용하여 추출한 OrderId를 가진 모든 Order를 조회합니다. 이들은 나중에 Pricebook2Id를 업데이트할 때 사용됩니다.
            List<Order> ordersToUpdate = [SELECT Id, OpportunityId FROM Order WHERE Id IN :orderIds];

            // SOQL 쿼리를 사용하여 추출한 OpportunityId를 가진 모든 Opportunity를 조회합니다. 이들은 나중에 StageName을 업데이트할 때 사용됩니다.
            List<Opportunity> oppsToUpdate = [SELECT Id, StageName FROM Opportunity WHERE Id IN :oppIds];

            // RecordType을 'CS'에서 'Buy'로 변경할 Contact 객체를 저장할 List를 선언합니다.
            List<Contact> contactsToUpdate = new List<Contact>();

            // Asset을 조회하여 ContactId를 키로, 해당 Contact에 연결된 Asset 리스트를 값으로 가지는 Map을 생성합니다.
            for (Asset asset : [SELECT Id, Refund_availability__c, ContactId FROM Asset WHERE ContactId IN :contactIds]) {
                if (!contactToAssetsMap.containsKey(asset.ContactId)) {
                    contactToAssetsMap.put(asset.ContactId, new List<Asset>());
                }
                contactToAssetsMap.get(asset.ContactId).add(asset);
            }
            // 판매를 순회합니다.
            for (Order order : newOrders) {
                // order의 Contact__c를 키로 사용하여 contactMap에서 Contact를 조회합니다.
                Contact relatedContact = contactMap.get(order.Contact__c);
                // order의 Contact__c를 키로 사용하여 contactToAssetsMap에서 Asset 리스트를 조회합니다.
                List<Asset> relatedAssets = contactToAssetsMap.get(order.Contact__c);
                if (relatedContact != null) {
                    // relatedContact의 AccountId가 null인 경우, 주문의 AccountId를 설정하고 업데이트 대상 리스트에 추가합니다.
                    if (relatedContact.Purchasing_Account__c == null) {
                        relatedContact.Purchasing_Account__c = order.AccountId;
                        contactsToUpdateForAccount.add(relatedContact);
                    } else if (relatedAssets != null) {
                        Boolean allRefunded = true;
                        // Asset을 순회하며, 모든 Asset이 Refund 상태인지 확인합니다.
                        for (Asset asset : relatedAssets) {
                            // Asset이 Refund 상태가 아니라면 allRefunded를 false로 설정하고 루프를 종료합니다.
                            if (asset.Refund_availability__c != true) {
                                allRefunded = false;
                                break;
                            }
                        }
                        // 모든 Asset이 Refund 상태라면, relatedContact의 AccountId를 주문의 AccountId로 설정하고 업데이트 대상 리스트에 추가합니다.
                        if (allRefunded) {
                            relatedContact.Purchasing_Account__c = order.AccountId;
                            contactsToUpdateForAccount.add(relatedContact);
                        }
                    }
                }
            }
            // 업데이트 대상 리스트가 비어 있지 않다면, 리스트에 있는 모든 Contact를 한 번에 업데이트합니다.
            if (!contactsToUpdateForAccount.isEmpty()) {
                update contactsToUpdateForAccount;
            }

            // OpportunityLineItem 객체들을 순회하며, 각각의 Product2Id를 productIds List에 추가합니다.
            for (OpportunityLineItem oppLineItem : oppLineItems) {
                productIds.add(oppLineItem.Product2Id);
            }

            // Order 객체들을 순회하며, 각각의 Pricebook2Id를 oppMap에서 찾아 업데이트합니다.
            for (Order order : ordersToUpdate) {
                Opportunity opp = oppMap.get(order.OpportunityId);
                order.Pricebook2Id = opp.Pricebook2Id;
            }
            // Pricebook2Id가 업데이트된 Order 객체들을 데이터베이스에 반영합니다.
            update ordersToUpdate;

            // Order 객체들을 다시 조회하여, 각각의 OpportunityId를 키로 가지는 Map에 저장합니다.
            Map<Id, Order> orderMap = new Map<Id, Order>();
            for (Order order : [SELECT Id, AccountId,OpportunityId, Contact__c, Pricebook2Id,EffectiveDate FROM Order WHERE Id IN :orderIds]) {
                orderMap.put(order.OpportunityId, order);
            }

            // Opportunity 객체들을 순회하며, StageName이 '상담'인 경우 '구매'로 변경합니다.
            for (Opportunity opp : oppsToUpdate) {
                if (opp.StageName == '상담') {
                    opp.StageName = '구매';
                }
            }
            // StageName이 업데이트된 Opportunity 객체들을 데이터베이스에 반영합니다.
            update oppsToUpdate;

            // 고객유형을 '상담'에서 '구매'로 변경할 Contact 객체를 저장할 List를 선언합니다.
            List<Contact> contactsType = new List<Contact>();
            // 고객유형을 '상담'에서 '구매'로 변경해야 할 Contact 객체들을 조회합니다.
            List<Contact> contacts = [SELECT Id, Type__c FROM Contact WHERE Id IN :contactIds AND Type__c = : 'not-purchased'];
            //고객유형 변경 '상담' -> 구매')
            //Contact 객체들을 순회하며, RecordType을 'CS'에서 'Buy'로 변경하고, 이를 ontactsType List에 추가합니다.
            for (Contact con : contacts) {
                if (con.Type__c == 'not-purchased') {
                    con.Type__c = 'purchased';
                    contactsType.add(con);
                }
            }
            // 고객 유형이 업데이트된 Contact 객체들을 데이터베이스에 반영합니다.
            if (!contactsType.isEmpty()) {
                update contactsType;
            }


            // OrderItem과 Asset 객체를 저장할 List를 선언합니다.
            List<OrderItem> orderItems = new List<OrderItem>();
            List<Asset> assets = new List<Asset>();

            // Contact의 이름과 Product의 이름을 저장할 Map을 선언합니다.
            Map<Id, String> contactNameMap = new Map<Id, String>();
            Map<Id, String> productNameMap = new Map<Id, String>();

            // Contact 객체들을 조회하여, 각각의 이름을 contactNameMap에 저장합니다.
            for (Contact contact : [SELECT Id, Name FROM Contact WHERE Id IN :contactIds]) {
                contactNameMap.put(contact.Id, contact.Name);
            }
            // Product 객체들을 조회하여, 각각의 이름을 productNameMap에 저장합니다.
            for (Product2 product : [SELECT Id, Name FROM Product2 WHERE Id IN :productIds]) {
                productNameMap.put(product.Id, product.Name);
            }
            Map<Id, Double> totalAmounts = new Map<Id, Double>();

            // OpportunityLineItem 객체들을 순회하며, 각각에 대응하는 OrderItem과 Asset 객체를 생성합니다.
            for (OpportunityLineItem oppLineItem : oppLineItems) {
                Order order = orderMap.get(oppLineItem.OpportunityId);
                if (order != null) {
                    OrderItem orderItem = new OrderItem();
                    orderItem.OrderId = order.Id;
                    orderItem.Product2Id = oppLineItem.Product2Id;
                    orderItem.Quantity = oppLineItem.Quantity;
                    orderItem.UnitPrice = oppLineItem.UnitPrice;
                    orderItem.PricebookEntryId = oppLineItem.PricebookEntryId;
                    orderItems.add(orderItem);
                    // 각 상품의 총 가격을 계산하고 주문의 총 금액에 더함
                    Double itemTotalAmount = oppLineItem.Quantity * oppLineItem.UnitPrice;
                    if (!totalAmounts.containsKey(order.Id)) {
                        totalAmounts.put(order.Id, 0.0);
                    }
                    totalAmounts.put(order.Id, totalAmounts.get(order.Id) + itemTotalAmount);

                    for (Integer i = 0; i < oppLineItem.Quantity; i++) {
                        Asset asset = new Asset();
                        asset.AccountId = order.AccountId;
                        asset.Price = oppLineItem.UnitPrice;
                        asset.Order__c = order.Id;
                        asset.ContactId = order.Contact__c;
                        asset.Product2Id = oppLineItem.Product2Id;
                        asset.Quantity = 1;
                        asset.SerialNumber = String.valueOf(Math.random()).substring(2,8) + '_' + DateTime.now().getTime();
                        asset.PurchaseDate = order.EffectiveDate;
                        asset.Name = contactNameMap.get(order.Contact__c) + '-' + productNameMap.get(oppLineItem.Product2Id) + '-' + i;
                        assets.add(asset);
                    }
                }
            }
            // 생성된 OrderItem과 Asset 객체들을 데이터베이스에 저장합니다.
            insert orderItems;
            insert assets;
            calculateDiscountedAmountAndSendEmail(newOrders,totalAmounts);
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    // 할인율 & 할인금액 조건 충족 시 본사 관리자에게 Notification
    public void calculateDiscountedAmountAndSendEmail(List<Order> orders, Map<Id, Double> totalAmounts) {
        List<Order> ordersToUpdate = new List<Order>();
        List<String> emailAddressesHQ = new List<String>();
        List<String> emailAddressesHQ_US = new List<String>();

        Set<String> userIds_HQ = new Set<String>();
        Set<String> userIds_HQ_US = new Set<String>();

        // 사용자 정의 알림 ID 가져오기
        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'DiscountNotification'];
        String notificationTypeId = type.Id;

        User currentUser = [SELECT Id, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        // 'Manager' 롤을 가진 유저들의 이메일 주소 및 ID 가져오기
        for (User u : [SELECT Id, Email, UserRole.Name FROM User]) {
            if (u.UserRole.Name == 'HQ Manager') {
                emailAddressesHQ.add(u.Email);
                userIds_HQ.add(u.Id);  // 사용자 ID 추가
            } else if (u.UserRole.Name == 'HQ Manager_US') {
                emailAddressesHQ_US.add(u.Email);
                userIds_HQ_US.add(u.Id);  // 사용자 ID 추가
            }
        }

        for (Order order : orders) {
            Order orderToUpdate = new Order(Id = order.Id); // 새 Order 객체 생성 후 Id 설정
            Double discountRate = order.DIscountRate__c;
            Double totalAmount = totalAmounts.get(order.Id);
            Double discountedAmount = totalAmount - (totalAmount * (discountRate/100));
            Integer discountedAmountInt = Integer.valueOf(discountedAmount.intValue());
            // 숫자를 콤마로 구분된 문자열로 변환
            String discountedAmountStr = discountedAmountInt.format();

            orderToUpdate.Discount_Order_Amount__c = discountedAmount;  // 할인된 금액 저장
            ordersToUpdate.add(orderToUpdate);

            // 할인율이 10% 이상인 경우 이메일 보내기
            if (discountRate >= 10) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                if (currentUser.UserRole.Name == 'Sales Manager') {
                    mail.setToAddresses(emailAddressesHQ);
                } else if (currentUser.UserRole.Name == 'Sales Manager_US') {
                    mail.setToAddresses(emailAddressesHQ_US);
                }

                mail.setSubject('할인 알림');
                mail.setPlainTextBody('판매 번호: ' + order.OrderNumber + '은(는) 할인율 ' + discountRate + '%이며 할인 적용 최종금액은 ' + discountedAmountStr + '원 입니다.');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

                // push알림 보내기
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setNotificationTypeId(notificationTypeId);
                notification.setTitle('할인 알림');
                notification.setBody('판매 번호: ' + order.OrderNumber + '은(는) 할인율 ' + discountRate + '%이며 할인 적용 최종금액은 ' + discountedAmountStr + '원 입니다.');
                notification.setTargetId(order.Id);
                try {
                    if (currentUser.UserRole.Name == 'Sales Manager') {
                        notification.send(userIds_HQ);
                    } else if (currentUser.UserRole.Name == 'Sales Manager_US') {
                        notification.send(userIds_HQ_US);
                    }
                } catch (Exception e) {
                    System.debug('할인 알림 오류: ' + e.getMessage());
                }
            }
        }

        try {
            update ordersToUpdate; // 리스트에 추가된 Order 레코드 업데이트
        } catch (Exception e) {
            System.debug('Error updating orders: ' + e.getMessage());
        }
    }
    // 고객의 제품 구매금액 업데이트 함수
    public void getLaptopOrdersForContact(List<Id> contactIds) {
        //구매 금액 합
        Decimal sumLaptop=0;
        Decimal sumAccessory=0;

        // 쿼리 실행
        List<Order> orders = [
                SELECT Id, DIscountRate__c,
                (SELECT Id, Product2Id, Quantity, TotalPrice,Product2.Family
                FROM OrderItems
                WHERE Product2.Family IN ('Laptop', 'Accessory'))
                FROM Order
                WHERE Contact__c = :contactIds
                AND Status = 'Order'
                AND EffectiveDate >= LAST_N_DAYS:90
        ];
        System.debug(orders);
        for (Order ord : orders) {
            for (OrderItem oi : ord.OrderItems) {
                Decimal itemAmount = (oi.TotalPrice * (1 - (ord.DIscountRate__c / 100)));
                if (oi.Product2.Family == 'Laptop') {
                    sumLaptop += itemAmount;
                } else if (oi.Product2.Family == 'Accessory') {
                    sumAccessory += itemAmount;
                }
            }
        }
        //contactsToUpdate를 하기 위해 리스트에 담고 아이디 값과 같이 필드값을 갱신
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Id contactId : contactIds) {
            Contact contact = new Contact(Id = contactId, Laptop_Purchase_Amount__c = sumLaptop, Accessory_Purchase_Amount__c=sumAccessory, Purchase_Amount__c=sumLaptop+sumAccessory);
            contactsToUpdate.add(contact);
        }

        // Update contacts
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }

    // 할인율 변경 시 처리를 위한 메서드
    public void handleDiscountRateChange(List<Order> oldOrders, List<Order> newOrders) {
        List<Order> ordersToUpdate = new List<Order>();

        for (Integer i = 0; i < newOrders.size(); i++) {
            Order newOrder = newOrders[i];
            Order oldOrder = oldOrders[i];

            // 할인율이 변경되었는지 확인
            if (newOrder.DIscountRate__c != oldOrder.DIscountRate__c) {
                Double discountedAmount = newOrder.TotalAmount * (1 - newOrder.DIscountRate__c / 100);
                Order orderToUpdate = new Order(Id = newOrder.Id);
                orderToUpdate.DiscountRate__c = discountedAmount;
                ordersToUpdate.add(orderToUpdate);

            }
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }
}