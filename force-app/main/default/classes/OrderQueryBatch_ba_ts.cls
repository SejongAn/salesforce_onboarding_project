@isTest
public class OrderQueryBatch_ba_ts {
    private static Contact createTestContact(Integer i) {
        // 테스트용 Account 생성
        Account testAccount = new Account(Name='Test Account ' + i);
        insert testAccount;

        Contact a = new Contact(
            LastName='Test Contact ' + i, // Contact 필드는 LastName이 필요
            Phone='010-5154-2341',
            Email='wejnwe@aownoi.com',
            CurrencyIsoCode='USD',
            AccountId=testAccount.Id // 생성된 테스트 Account의 ID를 할당
        );
        return a;
    }

    @TestSetup
    static void makeData() {
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            testContacts.add(createTestContact(i));
        }
        insert testContacts;
    }
    static testMethod void testProcessing() {
        // 테스트 실행 코드
        OrderQueryBatch_ba batch = new OrderQueryBatch_ba();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
       
        // 업데이트된 데이터 검증
        List<Contact> updatedContacts = [SELECT Id, LastName FROM Contact WHERE LastName LIKE 'Test Contact %'];
        System.assertEquals(10, updatedContacts.size(), 'There should be 10 updated Contacts.');
        // 추가적인 assert문을 포함하여 변경된 데이터가 기대한대로 업데이트 되었는지 확인
    }
}