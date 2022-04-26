@isTest
private class TestFscBot_TravelRequestService {

    private static String ACCOUNT_NAME = 'TestAccount';
    
    @testsetup static void createTestData() {
        Account account = TestIBot_Util.createIndividualAccount(ACCOUNT_NAME);
    }

    @isTest static void testCreateNewTravelRequestsWithContact() {
        Contact contact = [Select Id from Contact limit 1];

        List<FscBot_TravelRequest__c> existingTravelRequests = [Select Id from FscBot_TravelRequest__c];
        System.assertEquals(0, existingTravelRequests.size());

        Test.startTest();

        FscBot_TravelRequestService.getInstance().createNewTravelRequest(contact.Id, Date.today(), Date.today().addDays(365), 'USA', '000111222');

        Test.stopTest(); 

        existingTravelRequests = [Select FromDate__c, FinancialAccountNumber__c, ToDate__c, Travelling_Country__c from FscBot_TravelRequest__c];
        System.assertEquals(1, existingTravelRequests.size());
        System.assertEquals(Date.today(), existingTravelRequests.get(0).FromDate__c);
        System.assertEquals(Date.today().addDays(365), existingTravelRequests.get(0).ToDate__c);
        System.assertEquals('USA', existingTravelRequests.get(0).Travelling_Country__c);
        System.assertEquals('000111222', existingTravelRequests.get(0).FinancialAccountNumber__c);
    }

    @isTest static void testCreateNewTravelRequestsWithCase() {
        Case newCase = new Case();
        newCase.Status = 'New';
        newCase.Origin = 'Web';
        newCase.ChatKey__c = 'testkey';
        insert newCase;

        Contact contact = [Select Id from Contact limit 1];

        List<FscBot_TravelRequest__c> existingTravelRequests = [Select Id from FscBot_TravelRequest__c];
        System.assertEquals(0, existingTravelRequests.size());

        Test.startTest();

        FscBot_TravelRequestService.getInstance().createNewTravelRequest(contact.Id, newCase.id, Date.today(), Date.today().addDays(365), 'USA',null);

        Test.stopTest(); 

        existingTravelRequests = [Select Case__c, FromDate__c, FinancialAccountNumber__c, ToDate__c, Travelling_Country__c from FscBot_TravelRequest__c];
        System.assertEquals(1, existingTravelRequests.size());
        System.assertEquals(newCase.id, existingTravelRequests.get(0).Case__c);
        System.assertEquals(Date.today(), existingTravelRequests.get(0).FromDate__c);
        System.assertEquals(Date.today().addDays(365), existingTravelRequests.get(0).ToDate__c);
        System.assertEquals('USA', existingTravelRequests.get(0).Travelling_Country__c);
        System.assertEquals(null, existingTravelRequests.get(0).FinancialAccountNumber__c);
    }

    @isTest static void testFetchActiveTravelRequests() {
        Contact contact = [Select Id from Contact limit 1];

        FscBot_TravelRequest__c tr = new FscBot_TravelRequest__c();
        tr.contact__c = contact.id;
        tr.FromDate__c = Date.today();
        tr.ToDate__c  = Date.today().addDays(365);
        tr.Travelling_Country__c  = 'USA';
        tr.FinancialAccountNumber__c = '000000';
        insert tr;

        Test.startTest();

        List<FscBot_TravelRequest__c> result = FscBot_TravelRequestService.getInstance().fetchActiveTravelRequests(contact.Id);

        System.assertEquals(contact.id, result[0].Contact__c);
        System.assertEquals(Date.today(), result[0].FromDate__c);
        System.assertEquals(Date.today().addDays(365), result[0].ToDate__c);
        System.assertEquals('USA', result[0].Travelling_Country__c);

        Test.stopTest(); 
    }
}