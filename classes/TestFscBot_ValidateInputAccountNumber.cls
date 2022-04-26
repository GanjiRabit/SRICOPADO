@isTest
public class TestFscBot_ValidateInputAccountNumber {
    @testsetup static void createTestData() {
        Account acc = TestIBot_Util.createIndividualAccount('TestAccount', 'test@test.com', '9999999999');
        SObject financialAccount = TestIBot_Util.createFinancialAccount(acc.Id, '123123', 'Checking');
    }

    @isTest static void testGetFscBot_NumberOfDigitsForAccountCheck(){
        Test.startTest();
        List<FscBot_ValidateInputAccountNumber.AccountNumberRequest> requests = new List<FscBot_ValidateInputAccountNumber.AccountNumberRequest>();
	FscBot_ValidateInputAccountNumber.AccountNumberRequest request = new FscBot_ValidateInputAccountNumber.AccountNumberRequest();
	request.lastDigitsOfAccount='123123';
	request.noOfRetries=0;
	requests.add(request);
        List<FscBot_ValidateInputAccountNumber.ValidationResponse> responses = FscBot_ValidateInputAccountNumber.getNumberOfDigitsForAccountCheck(requests);
        System.assertEquals(1, responses.size(), 'Unexpected number of responses');
        
        FscBot_ValidateInputAccountNumber.ValidationResponse response = responses.get(0);
        
        System.assertEquals(true, response.isValidLength);
        System.assertEquals(6, response.inputLength);
        System.assertEquals(true, response.isTwoFactorAuthEnabled);
        
        Test.stopTest();

    }
}