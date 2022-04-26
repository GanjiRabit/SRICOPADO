@isTest
private class TestIBot_SendVerificationCodeService {

    @testsetup static void createTestData() {
        TestIBot_Util.createIndividualContact('TestContact');
    }
    
    @isTest
    static void testSendVerificationCode(){
        List<Contact> contacts = [Select MobilePhone, AccountId, Email from Contact];
        List<Id> emaildIds = new List<Id>();
        List<IBot_VerificationCodeService.VerificationCodeRequest> vrList = new List<IBot_VerificationCodeService.VerificationCodeRequest>();
        for(Contact c: contacts){
            emaildIds.add(c.Id);
            IBot_VerificationCodeService.VerificationCodeRequest vr = new  IBot_VerificationCodeService.VerificationCodeRequest();
            vr.contactEmailorMobile = c.Email;
            vr.primaryAccountId = c.AccountId;
            vr.verificationType = 'Email';
            vrList.add(vr);
        }
     
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IBot_MockHttpResponseGenerator());
        
        IBot_VerificationCodeService.sendVerificationCode(vrList);
        System.assertEquals(1, getContactsVerificationCodesCount(emaildIds), 'Unexpected number of verification codes');
        
        Test.stopTest();
    }

    @isTest
    static void testSendVerificationCodeWithMobile(){
        List<Contact> contacts = [Select MobilePhone, AccountId, Email from Contact];
        List<Id> emaildIds = new List<Id>();
        List<IBot_VerificationCodeService.VerificationCodeRequest> vrList = new List<IBot_VerificationCodeService.VerificationCodeRequest>();
        for(Contact c: contacts){
            emaildIds.add(c.Id);
            IBot_VerificationCodeService.VerificationCodeRequest vr = new  IBot_VerificationCodeService.VerificationCodeRequest();
            vr.contactEmailorMobile = c.MobilePhone;
            vr.primaryAccountId = c.AccountId;
            vr.verificationType = 'Mobile Number';
            vrList.add(vr);
        }
     
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IBot_MockHttpResponseGenerator());
        
        IBot_VerificationCodeService.sendVerificationCode(vrList);
        System.assertEquals(1, getContactsVerificationCodesCount(emaildIds), 'Unexpected number of verification codes');
        
        Test.stopTest();
    }
    
    @isTest
    static void testSendVerificationCodeWithExistingCodes(){
        List<Contact> contacts = [Select MobilePhone, AccountId, Email from Contact];
        List<Id> contactIds = new List<Id>();
        List<IBot_VerificationCodeService.VerificationCodeRequest> vrList = new List<IBot_VerificationCodeService.VerificationCodeRequest>();
        for(Contact c: contacts){
            contactIds.add(c.Id);
            IBot_VerificationCodeService.VerificationCodeRequest vr = new  IBot_VerificationCodeService.VerificationCodeRequest();
          vr.contactEmailorMobile = c.Email;
            vr.primaryAccountId = c.AccountId;
            vr.verificationType = 'Email';
            vrList.add(vr);
        }
        List<FscBot_Verification_Code__c> codes = TestIBot_Util.createTestVerificationCodes(contacts,'Email');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IBot_MockHttpResponseGenerator());
        
        IBot_VerificationCodeService.sendVerificationCode(vrList);
        System.assertEquals(1, getContactsVerificationCodesCount(contactIds), 'Unexpected number of verification codes');
        
        Test.stopTest();
    }
    
    private static Integer getContactsVerificationCodesCount(List<Id> contactIds){
        return [select count() from FscBot_Verification_Code__c where Contact__c in :contactIds];
    }

}