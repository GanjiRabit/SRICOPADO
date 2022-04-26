@isTest
private class TestFscBot_ValidateCard {
    private static String ACCOUNT_NAME = 'TestAccount';

    @testsetup static void createTestData() {
        Account account = TestIBot_Util.createIndividualAccount(ACCOUNT_NAME);
        SObject financialAccount = TestIBot_Util.createFinancialAccount(account.id, '0000123123', 'Checking');
        SObject card = TestIBot_Util.createCard('CreditCard', account.id, financialAccount.id);
    }

    @isTest static void testValidCard() {
        FinServ__FinancialAccount__c financialAccount = [Select Id from FinServ__FinancialAccount__c limit 1];
        FscBot_ValidateCard.ValidateCardRequest request = new FscBot_ValidateCard.ValidateCardRequest();
        request.card = 'XXXX-XXXX-XXXX-4444 - CreditCard';
        request.accountId = financialAccount.id;
        
        Test.startTest();
        
        List<FscBot_ValidateCard.ValidateCardResponse> validateResponses = FscBot_ValidateCard.validateCard(new List<FscBot_ValidateCard.ValidateCardRequest>{request});
        
        Test.stopTest();

        System.assert(validateResponses != null);
        System.assertEquals(1, validateResponses.size());
        System.assertEquals(true, validateResponses.get(0).isValid);
        System.assertEquals(1, validateResponses.get(0).noOfRetries);
    }

    @isTest static void testInvalidCard() {
        FinServ__FinancialAccount__c financialAccount = [Select Id from FinServ__FinancialAccount__c limit 1];
        FscBot_ValidateCard.ValidateCardRequest request = new FscBot_ValidateCard.ValidateCardRequest();
        request.card = 'XXXX-XXXX-XXXX-4444 - DebitCard';
        request.accountId = financialAccount.id;
        request.noOfRetries = 2;
        
        Test.startTest();
        
        List<FscBot_ValidateCard.ValidateCardResponse> validateResponses = FscBot_ValidateCard.validateCard(new List<FscBot_ValidateCard.ValidateCardRequest>{request});
        
        Test.stopTest();

        System.assert(validateResponses != null);
        System.assertEquals(1, validateResponses.size());
        System.assertEquals(false, validateResponses.get(0).isValid);
        System.assertEquals(3, validateResponses.get(0).noOfRetries);
    }

}