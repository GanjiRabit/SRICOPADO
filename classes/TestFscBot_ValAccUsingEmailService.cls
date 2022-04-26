@isTest
public class TestFscBot_ValAccUsingEmailService {
    @testsetup static void createTestData() {
        Account acc = TestIBot_Util.createIndividualAccount('TestAccount', 'test@test.com', '9999999999');
        SObject financialAccount = TestIBot_Util.createFinancialAccount(acc.Id, '0000123123', 'Checking');
    }

    @isTest static void testValidateAccountUsingCorrectEmail(){
		Account account = [Select FinServ__PrimaryContact__r.LastName from Account limit 1];
		System.assertEquals('TestAccount', (String)account.getSObject('FinServ__PrimaryContact__r').get('LastName'));
        
        List<FscBot_ValidateAccntWithEmailCtrl.ValidationRequest> validationRequests = new List<FscBot_ValidateAccntWithEmailCtrl.ValidationRequest>();
        FscBot_ValidateAccntWithEmailCtrl.ValidationRequest request = new FscBot_ValidateAccntWithEmailCtrl.ValidationRequest();
        
        
        request.email ='test@test.com';
        request.lastDigitsOfAccount = '123123';
        request.noOfRetries = 0;
        request.verificationMethod = 'Email';
        validationRequests.add(request);
        
        
        
        Test.startTest();
        
        List<FscBot_ValidateAccntWithEmailCtrl.ValidationResponse> responses = FscBot_ValidateAccntWithEmailCtrl.validateAccountWithEmail(validationRequests);
        System.assertEquals(1, responses.size(), 'Unexpected number of responses');
        
        FscBot_ValidateAccntWithEmailCtrl.ValidationResponse response = responses.get(0);
        
        System.assertEquals(1, response.noOfAccounts, 'Unexpected number of accounts');
                
        System.assertEquals('0000123123', response.faccountNumber, 'Unexpected financial account number');        
        
        System.assertEquals(1, response.noOfRetries, 'Unexpected number of retries');
        System.assertEquals(false, response.retryEmailvalidation, 'Unexpected request to retry email validation');
        System.assertEquals(true, response.sendVerificationCode, 'Unexpected email validation failure');
        System.assertEquals('test@test.com', response.contact.Email, 'Unexpected email id');
        System.assertEquals('9999999999', response.contact.MobilePhone, 'Unexpected mobile number');        
        System.assertEquals(false, response.transferToAgent, 'Unexpected transfer to agent');
        Test.stopTest();

    }

    
    
    @isTest static void testValidateAccountWithNullRequest(){
        
        Test.startTest();
        
        List<FscBot_ValidateAccntWithEmailCtrl.ValidationResponse> responses = FscBot_ValidateAccntWithEmailCtrl.validateAccountWithEmail(null);
        System.assertEquals(1, responses.size(), 'Unexpected number of responses');
        
        FscBot_ValidateAccntWithEmailCtrl.ValidationResponse response = responses.get(0);
        System.assertEquals(null, response.noOfAccounts, 'Unexpected number of accounts');
        System.assertEquals(null, response.noOfRetries, 'Unexpected number of retries');        
        System.assertEquals(null, response.transferToAgent, 'Unexpected transfer to agent');
        System.assertEquals(null, response.retryEmailValidation, 'Unexpected request to retry phone validation');
        System.assertEquals(null, response.sendVerificationCode, 'Unexpected mobile validation failure');
        
        Test.stopTest();

    }
    @isTest static void testValidateAccountUsingWrongEmail(){
        
        List<FscBot_ValidateAccntWithEmailCtrl.ValidationRequest> validationRequests = new List<FscBot_ValidateAccntWithEmailCtrl.ValidationRequest>();
        FscBot_ValidateAccntWithEmailCtrl.ValidationRequest request = new FscBot_ValidateAccntWithEmailCtrl.ValidationRequest();
        request.email ='test1@test.com';
        request.lastDigitsOfAccount = '123123';
        request.noOfRetries = 0;
        request.verificationMethod = 'Email';
        validationRequests.add(request);
        
        Test.startTest();
        
        List<FscBot_ValidateAccntWithEmailCtrl.ValidationResponse> responses = FscBot_ValidateAccntWithEmailCtrl.validateAccountWithEmail(validationRequests);
        System.assertEquals(1, responses.size(), 'Unexpected number of responses');
        
        FscBot_ValidateAccntWithEmailCtrl.ValidationResponse response = responses.get(0);
        System.assertEquals(false, response.transferToAgent, 'Unexpected transfer to agent');
        System.assertEquals(true, response.retryEmailvalidation, 'Unexpected request to retry email validation');
        System.assertEquals(false, response.sendVerificationCode, 'Unexpected email validation failure');
        System.assertEquals(0, response.noOfAccounts, 'Unexpected number of accounts');
        System.assertEquals(1, response.noOfRetries, 'Unexpected number of retries');        
        
        
        Test.stopTest();

    }

    @isTest static void testValidateAccountRetrylimitExceeded(){
        
        List<FscBot_ValidateAccntWithEmailCtrl.ValidationRequest> validationRequests = new List<FscBot_ValidateAccntWithEmailCtrl.ValidationRequest>();
        FscBot_ValidateAccntWithEmailCtrl.ValidationRequest request = new FscBot_ValidateAccntWithEmailCtrl.ValidationRequest();
        request.email ='test@test.com';
        request.lastDigitsOfAccount = '123123';
        request.noOfRetries = 2;
        request.verificationMethod = 'Mobile Number';
        validationRequests.add(request);
        
        Test.startTest();
        
        List<FscBot_ValidateAccntWithEmailCtrl.ValidationResponse> responses = FscBot_ValidateAccntWithEmailCtrl.validateAccountWithEmail(validationRequests);
        System.assertEquals(1, responses.size(), 'Unexpected number of responses');
        
        FscBot_ValidateAccntWithEmailCtrl.ValidationResponse response = responses.get(0);
        System.assertEquals(0, response.noOfAccounts, 'Unexpected number of accounts');
        System.assertEquals(3, response.noOfRetries, 'Unexpected number of retries');        
        System.assertEquals(true, response.transferToAgent, 'Unexpected transfer to agent');
        System.assertEquals(false, response.retryEmailValidation, 'Unexpected request to retry phone validation');
        System.assertEquals('You have exceeded the maximum no of attempts.', response.transferToAgentMessage, 'Unexpected message before transfering to agent');
        
        Test.stopTest();
    }

    @isTest static void testValidateAccountWithDemoResponse(){
        IBot_CustomMetadataBean customMetadataBean = new IBot_CustomMetadataBean();
        customMetadataBean.setMasterLabel('DemoModeEnabled');
        customMetadataBean.setNamespacePrefix('');
        customMetadataBean.setValue('true');
        customMetadataBean.setDeveloperName('DemoModeEnabled');

        IBot_ConfigSettings.getInstance().addFSCBotSetting('DemoModeEnabled',customMetadataBean);

        List<FscBot_ValidateAccntWithEmailCtrl.ValidationRequest> validationRequests = new List<FscBot_ValidateAccntWithEmailCtrl.ValidationRequest>();
        
        FscBot_ValidateAccntWithEmailCtrl.ValidationRequest request = new FscBot_ValidateAccntWithEmailCtrl.ValidationRequest();
        request.lastDigitsOfAccount = '212121';
        request.noOfRetries = 0;
        request.verificationMethod = 'Email';
        validationRequests.add(request);

        Test.startTest();
        
        List<FscBot_ValidateAccntWithEmailCtrl.ValidationResponse> responses = FscBot_ValidateAccntWithEmailCtrl.validateAccountWithEmail(validationRequests);
        System.assertEquals(1, responses.size(), 'Unexpected number of responses');
        
        FscBot_ValidateAccntWithEmailCtrl.ValidationResponse response = responses.get(0);
        System.assertEquals(1, response.noOfAccounts, 'Unexpected number of accounts');
        
        Test.stopTest();
    }
}