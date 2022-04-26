@isTest
public class TestFscBot_ValAccUsingGAUserAndAccntNum {
    
    @testsetup static void createTestData() {
        Account acc = TestIBot_Util.createIndividualAccount('TestAccount', 'test@test.com', '9999999999');
        SObject financialAccount = TestIBot_Util.createFinancialAccount(acc.Id, '0000123123', 'Checking');
    }

    @isTest
    static void testValidateAccountWithNullRequest() {
        Test.startTest();

        List<FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse> responseList = FscBot_ValAccWithGAUser_AccntNumberCtrl.validateAccountWithEmail(null);
        FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse response = responseList.get(0);
        
        System.assertEquals(null, response.contact, 'Unexpected number of contact');
        System.assertEquals(null, response.noOfAccounts, 'Unexpected number of accounts');
        System.assertEquals(null, response.noOfRetries, 'Unexpected number of retries');        
        System.assertEquals(null, response.transferToAgent, 'Unexpected transfer to agent');

        Test.stopTest();
    }

    @isTest static void testValidateAccountRetrylimitExceeded(){
        List<FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationRequest> validationRequests = new List<FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationRequest>();
        
        FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationRequest request = new FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationRequest();
        request.gaUserId = 'TestUserId';
        request.lastDigitsOfAccount = '123123';
        request.noOfRetries = 2;
        request.verificationMethod = 'Mobile Number';
        validationRequests.add(request);

        Test.startTest();
        
        List<FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse> responses = FscBot_ValAccWithGAUser_AccntNumberCtrl.validateAccountWithEmail(validationRequests);
        System.assertEquals(1, responses.size(), 'Unexpected number of responses');
        
        FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse response = responses.get(0);
        System.assertEquals(0, response.noOfAccounts, 'Unexpected number of accounts');
        System.assertEquals(3, response.noOfRetries, 'Unexpected number of retries');
        
        Test.stopTest();
    }

    @isTest static void testValidateAccountUsingEmailWithValidInput(){
        List<FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationRequest> validationRequests = new List<FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationRequest>();
        
        FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationRequest request = new FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationRequest();
        request.gaUserId = '9999999999';
        request.lastDigitsOfAccount = '123123';
        request.noOfRetries = 0;
        request.verificationMethod = 'Mobile Number';
        validationRequests.add(request);

        Test.startTest();
        
        List<FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse> responses = FscBot_ValAccWithGAUser_AccntNumberCtrl.validateAccountWithEmail(validationRequests);
        System.assertEquals(1, responses.size(), 'Unexpected number of responses');
        
        FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse response = responses.get(0);
        System.assertEquals(1, response.noOfAccounts, 'Unexpected number of accounts');
        System.assertEquals(1, response.noOfRetries, 'Unexpected number of retries');
        
        Test.stopTest();
    }

    @isTest static void testValidateAccountUsingEmailWithDemoResponse(){
        IBot_CustomMetadataBean customMetadataBean = new IBot_CustomMetadataBean();
        customMetadataBean.setMasterLabel('DemoModeEnabled');
        customMetadataBean.setNamespacePrefix('');
        customMetadataBean.setValue('true');
        customMetadataBean.setDeveloperName('DemoModeEnabled');

        IBot_ConfigSettings.getInstance().addFSCBotSetting('DemoModeEnabled',customMetadataBean);

        List<FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationRequest> validationRequests = new List<FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationRequest>();
        
        FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationRequest request = new FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationRequest();
        request.gaUserId = '9999999999';
        request.lastDigitsOfAccount = '212121';
        request.noOfRetries = 0;
        request.verificationMethod = 'Mobile Number';
        validationRequests.add(request);

        Test.startTest();
        
        List<FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse> responses = FscBot_ValAccWithGAUser_AccntNumberCtrl.validateAccountWithEmail(validationRequests);
        System.assertEquals(1, responses.size(), 'Unexpected number of responses');
        
        FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse response = responses.get(0);
        System.assertEquals(1, response.noOfAccounts, 'Unexpected number of accounts');
        
        Test.stopTest();
    }
}