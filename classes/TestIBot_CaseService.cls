@isTest
private class TestIBot_CaseService {
    
    @testsetup static void createTestData() {
        Account account = TestIBot_Util.createIndividualAccount('TestAccount');
        TestIBot_Util.createFinancialAccount(account.id, '0000123123', 'Checking');
    }

    @isTest static void testInsertCase() {
        Contact contact = [Select Id from Contact limit 1];
        FinServ__FinancialAccount__c financialAccount = [Select Id from FinServ__FinancialAccount__c limit 1];
        
        List<Case> cases = [Select Id, Subject from Case];
        System.assertEquals(0, cases.size());
        
        Test.startTest();
        
        Case caseData = IBot_CaseService.getInstance().insertCase(financialAccount.id, contact.id, 'TestSubject', 'TestDescription', 'High', '12345');
        
        Test.stopTest();
        
        cases = [Select Id, Subject from Case];
        
        System.assertEquals(1, cases.size());
        System.assert(caseData != null);
        System.assertEquals('TestSubject', cases.get(0).subject);   
    }   
}