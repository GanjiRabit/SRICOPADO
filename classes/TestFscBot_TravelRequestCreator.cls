@isTest
private class TestFscBot_TravelRequestCreator {

    private static String ACCOUNT_NAME = 'TestAccount';
    
    @testsetup static void createTestData() {
        Account account = TestIBot_Util.createIndividualAccount(ACCOUNT_NAME);
        SObject financialAccount = TestIBot_Util.createFinancialAccount(account.id, '0000123123', 'Checking');
        SObject card = TestIBot_Util.createCard('CreditCard', account.id, financialAccount.id);
    }

    @isTest static void testCreateTravelRequest() {
        Contact contact = [Select Id from Contact limit 1];

        List<FscBot_TravelRequest__c> existingTravelRequests = [Select Id from FscBot_TravelRequest__c];
        System.assertEquals(0, existingTravelRequests.size());

        FscBot_TravelRequestCtrl.TravelRequest travelRequest = new FscBot_TravelRequestCtrl.TravelRequest();
        travelRequest.contact = contact;
        travelRequest.fromDate = Date.today();
        travelRequest.toDate = Date.today().addDays(365);
        travelRequest.travelCountry = 'USA';
        travelRequest.selectedAccNo = '000111222';

        Test.startTest();

        FscBot_TravelRequestCtrl.createTravelRequest(new List<FscBot_TravelRequestCtrl.TravelRequest>{travelRequest});

        Test.stopTest();

        existingTravelRequests = [Select FromDate__c, FinancialAccountNumber__c, ToDate__c, Travelling_Country__c from FscBot_TravelRequest__c];
        System.assertEquals(1, existingTravelRequests.size());
        System.assertEquals(Date.today(), existingTravelRequests.get(0).FromDate__c);
        System.assertEquals(Date.today().addDays(365), existingTravelRequests.get(0).ToDate__c);
        System.assertEquals('USA', existingTravelRequests.get(0).Travelling_Country__c);
        System.assertEquals('000111222', existingTravelRequests.get(0).FinancialAccountNumber__c);
    }
}