@isTest
private class TestFscBot_FetchCardsAssociatedWithAcc {
    private static String ACCOUNT_NAME = 'TestAccount';

    @testsetup static void createTestData() {
        Account account = TestIBot_Util.createIndividualAccount(ACCOUNT_NAME);
        SObject financialAccount = TestIBot_Util.createFinancialAccount(account.id, '0000123123', 'Checking');
        SObject card = TestIBot_Util.createCard('CreditCard', account.id, financialAccount.id);
    }

    @isTest static void testGetCards() {
        FinServ__FinancialAccount__c financialAccount = [Select Id from FinServ__FinancialAccount__c limit 1];
        
        Test.startTest();
        
        List<List<String>> cardsList = FscBot_FetchCardsAssociatedWithFACtrl.getActiveCards(new List<String>{financialAccount.id});
        
        Test.stopTest();

        System.assert(cardsList != null);
        System.assertEquals(1, cardsList.size());
        System.assertEquals('XXXX-XXXX-XXXX-4444 - CreditCard', cardsList.get(0).get(0));
    }

    @isTest static void testGetCardsWithEmptyAccounts() {
        Test.startTest();
        
        List<List<String>> cardsList = FscBot_FetchCardsAssociatedWithFACtrl.getActiveCards(new List<String>());
        
        Test.stopTest();

        System.assert(cardsList != null);
        System.assertEquals(0, cardsList.size());
    }   
}