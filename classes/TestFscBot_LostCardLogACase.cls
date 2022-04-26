@isTest
private class TestFscBot_LostCardLogACase {

    private static String ACCOUNT_NAME = 'TestAccount';
    
    @testsetup static void createTestData() {
        Account account = TestIBot_Util.createIndividualAccount(ACCOUNT_NAME);
        SObject financialAccount = TestIBot_Util.createFinancialAccount(account.id, '0000123123', 'Checking');
        SObject card = TestIBot_Util.createCard('CreditCard', account.id, financialAccount.id);
    }

    @isTest static void testCreateCase() {
        List<FscBot_LostCardLogACaseCtrl.CaseRequest> caseCreationRequests = new List<FscBot_LostCardLogACaseCtrl.CaseRequest>();

        Contact contact = [Select Id from Contact limit 1];
        FinServ__FinancialAccount__c financialAccount = [Select Id from FinServ__FinancialAccount__c limit 1];
        FinServ__Card__c card = [Select Id from FinServ__Card__c limit 1];

        FscBot_LostCardLogACaseCtrl.CaseRequest caseCreationRequest = new FscBot_LostCardLogACaseCtrl.CaseRequest();
        caseCreationRequest.con = contact;
        caseCreationRequest.financialAccId = financialAccount.id;
        caseCreationRequest.selectedCard = card.id;
        caseCreationRequest.chatKey = 'TestKey';

        caseCreationRequests.add(caseCreationRequest);

        List<Case> cases = [Select Id from Case];
        System.assertEquals(0, cases.size());
        
        Test.startTest();

        List<FscBot_LostCardLogACaseCtrl.CaseResponse> caseCreationResponses = FscBot_LostCardLogACaseCtrl.createCase(caseCreationRequests);
        
        Test.stopTest();

        cases = [Select Id, CaseNumber from Case];
        System.assertEquals(1, cases.size());
        
        System.assert(caseCreationResponses != null);
        System.assertEquals(1, caseCreationResponses.size());
        System.assertEquals(cases.get(0).caseNumber, caseCreationResponses.get(0).caseNumber);
        System.assert(caseCreationResponses.get(0).message.contains('Your request has been submitted'));   
    }

    @isTest static void testCreateCaseWithEmptyData() {
        List<Case> cases = [Select Id from Case];
        System.assertEquals(0, cases.size());
        
        Test.startTest();

        List<FscBot_LostCardLogACaseCtrl.CaseResponse> caseCreationResponses = FscBot_LostCardLogACaseCtrl.createCase(null);
        
        Test.stopTest();

        cases = [Select Id, CaseNumber from Case];
        System.assertEquals(0, cases.size());
        
        System.assert(caseCreationResponses != null);
        System.assertEquals(1, caseCreationResponses.size());
        System.assertEquals(null, caseCreationResponses.get(0).caseNumber);   
    }   
}