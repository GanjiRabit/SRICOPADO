@isTest
private class TestIBot_OTPValidationService {
    public static String ACCOUNT_NAME = 'TestAccount';
    
    @testSetup static void setup(){
        Account account = TestIBot_Util.createIndividualAccount(ACCOUNT_NAME);
        TestIBot_Util.createFinancialAccount(account.id, '0000123123', 'Checking');
    }
    
    @isTest private static void testIsValidWithInvalidCode(){
        Contact contact = [Select Id from Contact limit 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IBot_MockHttpResponseGenerator());
        
        IBot_OTPValidationCtrl.ValidationRequest req = new IBot_OTPValidationCtrl.ValidationRequest();
        req.verificationCode = '000000';
        req.contact = contact; 
        req.noOfRetries = 0;
        req.verificationMethod = 'Email';
        
        List<IBot_OTPValidationCtrl.ValidationResponse> result = IBot_OTPValidationCtrl.isValid(new List<IBot_OTPValidationCtrl.ValidationRequest>{req});
        System.assertEquals(false, result.get(0).isValid, 'Expected false for invalid code');
        
        Test.stopTest();
    }

    @isTest private static void testIsValidWithValidTestCode(){
        Contact contact = [Select Id from Contact limit 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IBot_MockHttpResponseGenerator());
        
        IBot_OTPValidationCtrl.ValidationRequest req = new IBot_OTPValidationCtrl.ValidationRequest();
        req.verificationCode = '112233';
        req.contact = contact; 
        req.noOfRetries = 0;
        req.verificationMethod = 'Email';

        List<IBot_OTPValidationCtrl.ValidationResponse> result = IBot_OTPValidationCtrl.isValid(new List<IBot_OTPValidationCtrl.ValidationRequest>{req});
        System.assertEquals(false, result.get(0).isValid, 'Expected true for valid code');
        
        Test.stopTest();
    }

    @isTest private static void testIsValidWithValidCode(){
        Contact contact = [Select Id from Contact limit 1];
        contact.MobilePhone = '9999999999';
        update contact;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IBot_MockHttpResponseGenerator());
        List<FscBot_Verification_Code__c> codes = TestIBot_Util.createTestVerificationCodes(new List<Contact>{contact}, 'Email');
        
        IBot_OTPValidationCtrl.ValidationRequest req = new IBot_OTPValidationCtrl.ValidationRequest();
        req.verificationCode = String.valueOf(codes.get(0).Code__c);
        req.contact = contact; 
        req.noOfRetries = 0;
        req.verificationMethod = 'Email';

        List<IBot_OTPValidationCtrl.ValidationResponse> result = IBot_OTPValidationCtrl.isValid(new List<IBot_OTPValidationCtrl.ValidationRequest>{req});
        System.assertEquals(true, result.get(0).isValid, 'Expected true for valid code');
        
        Test.stopTest();
    }

    @isTest private static void testIsValidWithMaxInvalidAttempts(){
        Contact contact = [Select Id from Contact limit 1];
        contact.MobilePhone = '9999999999';
        update contact;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IBot_MockHttpResponseGenerator());
        List<FscBot_Verification_Code__c> codes = TestIBot_Util.createTestVerificationCodes(new List<Contact>{contact}, 'Email');
        
        IBot_OTPValidationCtrl.ValidationRequest req = new IBot_OTPValidationCtrl.ValidationRequest();
        req.verificationCode = '000000';
        req.contact = contact; 
        req.noOfRetries = 4;
        req.verificationMethod = 'Email';

        List<IBot_OTPValidationCtrl.ValidationResponse> result = IBot_OTPValidationCtrl.isValid(new List<IBot_OTPValidationCtrl.ValidationRequest>{req});
        System.assertEquals(true, result.get(0).transferToAgent);
        System.assertEquals('You have exceeded the maximum no of attempts.', result.get(0).transferToAgentMessage);
        
        Test.stopTest();
    }

    @isTest private static void testIsValidWithEmptyRequest(){
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IBot_MockHttpResponseGenerator());
        
        List<IBot_OTPValidationCtrl.ValidationResponse> result = IBot_OTPValidationCtrl.isValid(new List<IBot_OTPValidationCtrl.ValidationRequest>());
        
        Test.stopTest();

        System.assert(result != null);
        System.assertEquals(1, result.size());
        System.assertEquals(false, result.get(0).isValid, 'Expected false for empty input'); 
    }
    
}