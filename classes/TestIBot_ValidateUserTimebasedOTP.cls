@IsTest
public class TestIBot_ValidateUserTimebasedOTP {
	static Contact c;
    
    @testsetup static void createTestData() {
    }
    
    @isTest static void testIsValidCorrectTopt(){
        Account acc = TestIBot_Util.createIndividualAccount('TestAccount', 'test@test.com', '9999999999');
        SObject financialAccount = TestIBot_Util.createFinancialAccount(acc.Id, '0000123123', 'Checking');
        c = [select Id, GAUserId__c from contact where accountId = :acc.Id];
        c.GAUserId__c = '123456';
        update c;
        
        Test.startTest();

        List<IBot_ValidateTimebasedOTPCtrl.ValidationRequest> validationRequests = new List<IBot_ValidateTimebasedOTPCtrl.ValidationRequest>();
        IBot_ValidateTimebasedOTPCtrl.ValidationRequest request = new IBot_ValidateTimebasedOTPCtrl.ValidationRequest();
        request.contact = c;
        request.noOfRetries = 0;
        request.verificationCode = 121212;
        validationRequests.add(request);
        
        Test.setMock(HttpCalloutMock.class, new IBot_MockGoogleOTPHttpResponseGenerator());
        List<IBot_ValidateTimebasedOTPCtrl.ValidationResponse> validationResponses = IBot_ValidateTimebasedOTPCtrl.isValid(validationRequests);
        
        System.assertEquals(1, validationResponses.size(), 'Unexpected number of responses');
        
        IBot_ValidateTimebasedOTPCtrl.ValidationResponse response = validationResponses.get(0);
        
        System.assertEquals(1, response.noOfRetries, 'Unexpected number of retries');
        System.assertEquals(true, response.isValid, 'Unexpected Topt Validation');
        
        Test.stopTest();        
    }

    @isTest static void testIsValidWrongTopt(){
        Account acc = TestIBot_Util.createIndividualAccount('TestAccount', 'test@test.com', '9999999999');
        SObject financialAccount = TestIBot_Util.createFinancialAccount(acc.Id, '0000123123', 'Checking');
        c = [select Id, GAUserId__c from contact where accountId = :acc.Id];
        c.GAUserId__c = '123456';
        update c;
        
        Test.startTest();

        List<IBot_ValidateTimebasedOTPCtrl.ValidationRequest> validationRequests = new List<IBot_ValidateTimebasedOTPCtrl.ValidationRequest>();
        IBot_ValidateTimebasedOTPCtrl.ValidationRequest request = new IBot_ValidateTimebasedOTPCtrl.ValidationRequest();
        request.contact = c;
        request.noOfRetries = 0;
        request.verificationCode = 121212;
        validationRequests.add(request);
        
        IBot_MockGoogleOTPHttpResponseGenerator mockGenerator = new IBot_MockGoogleOTPHttpResponseGenerator();
        mockGenerator.response = 'false';
        Test.setMock(HttpCalloutMock.class, mockGenerator);
        List<IBot_ValidateTimebasedOTPCtrl.ValidationResponse> validationResponses = IBot_ValidateTimebasedOTPCtrl.isValid(validationRequests);
        
        System.assertEquals(1, validationResponses.size(), 'Unexpected number of responses');
        
        IBot_ValidateTimebasedOTPCtrl.ValidationResponse response = validationResponses.get(0);
        
        System.assertEquals(1, response.noOfRetries, 'Unexpected number of retries');
        System.assertEquals(false, response.isValid, 'Unexpected Topt Validation');
        
        Test.stopTest();        
    }

    @isTest static void testIsValidWithMaxRetryOptions(){
        Account acc = TestIBot_Util.createIndividualAccount('TestAccount', 'test@test.com', '9999999999');
        SObject financialAccount = TestIBot_Util.createFinancialAccount(acc.Id, '0000123123', 'Checking');
        c = [select Id, GAUserId__c from contact where accountId = :acc.Id];
        c.GAUserId__c = '123456';
        update c;
        
        Test.startTest();

        List<IBot_ValidateTimebasedOTPCtrl.ValidationRequest> validationRequests = new List<IBot_ValidateTimebasedOTPCtrl.ValidationRequest>();
        IBot_ValidateTimebasedOTPCtrl.ValidationRequest request = new IBot_ValidateTimebasedOTPCtrl.ValidationRequest();
        request.contact = c;
        request.noOfRetries = 3;
        request.verificationCode = 121212;
        validationRequests.add(request);
        
        IBot_MockGoogleOTPHttpResponseGenerator mockGenerator = new IBot_MockGoogleOTPHttpResponseGenerator();
        mockGenerator.response = 'false';
        Test.setMock(HttpCalloutMock.class, mockGenerator);
        List<IBot_ValidateTimebasedOTPCtrl.ValidationResponse> validationResponses = IBot_ValidateTimebasedOTPCtrl.isValid(validationRequests);
        
        System.assertEquals(1, validationResponses.size(), 'Unexpected number of responses');
        
        IBot_ValidateTimebasedOTPCtrl.ValidationResponse response = validationResponses.get(0);
        
        System.assertEquals(4, response.noOfRetries, 'Unexpected number of retries');
        System.assertEquals(false, response.isValid, 'Unexpected Topt Validation');
        
        Test.stopTest();        
    }

    @isTest static void testIsValidForDemo(){
        Account acc = TestIBot_Util.createIndividualAccount('TestAccount', 'test@test.com', '9999999999');
        SObject financialAccount = TestIBot_Util.createFinancialAccount(acc.Id, '0000123123', 'Checking');
        c = [select Id, GAUserId__c from contact where accountId = :acc.Id];
        c.GAUserId__c = '123456';
        update c;
        
        Test.startTest();

        List<IBot_ValidateTimebasedOTPCtrl.ValidationRequest> validationRequests = new List<IBot_ValidateTimebasedOTPCtrl.ValidationRequest>();
        IBot_ValidateTimebasedOTPCtrl.ValidationRequest request = new IBot_ValidateTimebasedOTPCtrl.ValidationRequest();
        request.contact = c;
        request.noOfRetries = 0;
        request.verificationCode = 112233;
        validationRequests.add(request);
        
        IBot_MockGoogleOTPHttpResponseGenerator mockGenerator = new IBot_MockGoogleOTPHttpResponseGenerator();
        mockGenerator.response = 'false';
        Test.setMock(HttpCalloutMock.class, mockGenerator);
        List<IBot_ValidateTimebasedOTPCtrl.ValidationResponse> validationResponses = IBot_ValidateTimebasedOTPCtrl.isValid(validationRequests);
        
        System.assertEquals(1, validationResponses.size(), 'Unexpected number of responses');
        
        IBot_ValidateTimebasedOTPCtrl.ValidationResponse response = validationResponses.get(0);
        
        System.assertEquals(1, response.noOfRetries, 'Unexpected number of retries');
        System.assertEquals(false, response.isValid, 'Unexpected Topt Validation');
        
        Test.stopTest();        
    }
    
    @isTest static void testIsValidWithNullInput(){
        Test.startTest();

        List<IBot_ValidateTimebasedOTPCtrl.ValidationResponse> validationResponses = IBot_ValidateTimebasedOTPCtrl.isValid(null);
        System.assertEquals(1, validationResponses.size(), 'Unexpected number of responses');
        
        IBot_ValidateTimebasedOTPCtrl.ValidationResponse response = validationResponses.get(0);
        
        System.assertEquals(1, response.noOfRetries, 'Unexpected number of retries');
        System.assertEquals(false, response.isValid, 'Unexpected Topt Validation');
        
        Test.stopTest();        

    }

    @isTest static void testBuildResponseForEmptyInput(){
        Test.startTest();
        
        IBot_ValidateTimebasedOTPCtrl.ValidationResponse response = FscBot_OTPResponseUtils.buildTOPTResponseForEmptyInput();   
        
        System.assertEquals(1, response.noOfRetries, 'Unexpected number of retries');
        System.assertEquals(false, response.isValid, 'Unexpected Topt Validation');

        Test.stopTest();
    }
    
    @isTest static void testBuildResponse(){
        Test.startTest();
        
        IBot_ValidateTimebasedOTPCtrl.ValidationRequest request = new IBot_ValidateTimebasedOTPCtrl.ValidationRequest();
        request.contact = c;
        request.noOfRetries = 0;
        request.verificationCode = 121212;

        IBot_ValidateTimebasedOTPCtrl.ValidationResponse response = FscBot_OTPResponseUtils.buildTOPTResponse(request, true);   
        
        System.assertEquals(1, response.noOfRetries, 'Unexpected number of retries');
        System.assertEquals(true, response.isValid, 'Unexpected Topt Validation');

        Test.stopTest();
    }

}