@isTest
private class TestIBot_ConfigSettings {
    @isTest static void testGetSMSService() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getSMSService();

        System.assertEquals('TwilioService', result);

        Test.stopTest();
    }

    @isTest static void testIsTwoFactorAuthenticationEnabled() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        Boolean result = IBot_ConfigSettings.getInstance().isTwoFactorAuthenticationEnabled();

        System.assertEquals(true, result);

        Test.stopTest();
    }

    @isTest static void testIsDemoModeEnabled() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        Boolean result = IBot_ConfigSettings.getInstance().isDemoModeEnabled();

        System.assertEquals(false, result);

        Test.stopTest();
    }

    @isTest static void testGetNoOfDigitsforAccCheck() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        Integer result = IBot_ConfigSettings.getInstance().getNoOfDigitsforAccCheck();

        System.assertEquals(6, result);

        Test.stopTest();
    }

    @isTest static void testGetAccountNumberFieldAPIName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getAccountNumberFieldAPIName();

        System.assertEquals('FinServ__FinancialAccountNumber__c', result);

        Test.stopTest();
    }

    @isTest static void testGetFinancialAccountNumberFieldAPIName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getFinancialAccountNumberFieldAPIName();

        System.assertEquals('FinServ__FinancialAccountNumber__c', result);

        Test.stopTest();
    }

    @isTest static void testGetListBotSupportedFinancialAccountTypes() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        List<String> result = IBot_ConfigSettings.getInstance().getListBotSupportedFinancialAccountTypes();

        System.assert(result != null);
        System.assertEquals('Checking', result.get(0));
        System.assertEquals('Credit Card', result.get(1));

        Test.stopTest();
    }

    @isTest static void testGetFinancialAccountObjectAPIName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getFinancialAccountObjectAPIName();

        System.assertEquals('FinServ__FinancialAccount__c', result);

        Test.stopTest();
    }   

    @isTest static void testGetFinancialAccountPOFieldAPIName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getFinancialAccountPOFieldAPIName();

        System.assertEquals('FinServ__PrimaryOwner__c', result);

        Test.stopTest();
    }

    @isTest static void testGetFinancialAccountTypeFieldAPIName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getFinancialAccountTypeFieldAPIName();

        System.assertEquals('FinServ__FinancialAccountType__c', result);

        Test.stopTest();
    }

    @isTest static void testGetPrimaryOwnerContactEmailRelationshipName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getPrimaryOwnerContactEmailRelationshipName();

        System.assertEquals('FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.Email', result);

        Test.stopTest();
    }

    @isTest static void testGetPrimaryOwnerContactGAUserIdFieldName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getPrimaryOwnerContactGAUserIdFieldName();

        System.assertEquals('FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.GAUserId__c', result);

        Test.stopTest();
    }

    @isTest static void testGetPrimaryOwnerContactMobileRelationshipName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getPrimaryOwnerContactMobileRelationshipName();

        System.assertEquals('FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.MobilePhone', result);

        Test.stopTest();
    }

    @isTest static void testGetPrimaryOwnerContactIdRelationshipName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getPrimaryOwnerContactIdRelationshipName();

        System.assertEquals('FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.Id', result);

        Test.stopTest();
    }

    @isTest static void testGetPrimaryOwnerContactFNameRelationshipName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getPrimaryOwnerContactFNameRelationshipName();

        System.assertEquals('FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.FirstName', result);

        Test.stopTest();
    }

    @isTest static void testGetPrimaryOwnerEmailRelationshipName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getPrimaryOwnerEmailRelationshipName();

        System.assertEquals('FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.Email', result);

        Test.stopTest();
    }

    @isTest static void testGetContactGAUSerIdFieldName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getContactGAUSerIdFieldName();

        System.assertEquals('GAUserId__c', result);

        Test.stopTest();
    }

    @isTest static void testGetPrimaryOwnerMobileRelationshipName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getPrimaryOwnerMobileRelationshipName();

        System.assertEquals('FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.MobilePhone', result);

        Test.stopTest();
    }

    @isTest static void testIsEnforceFSCPackageInstallation() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        Boolean result = IBot_ConfigSettings.getInstance().isEnforceFSCPackageInstallation();

        System.assertEquals(true, result);

        Test.stopTest();
    }

    @isTest static void testGetPrimaryOwnerRelationshipName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getPrimaryOwnerRelationshipName();

        System.assertEquals('FinServ__PrimaryOwner__r', result);

        Test.stopTest();
    }

    @isTest static void testGetPrimaryOwnerContactRelationshipName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getPrimaryOwnerContactRelationshipName();

        System.assertEquals('FinServ__PrimaryContact__r', result);

        Test.stopTest();
    }

    @isTest static void testGetSelectFieldsForFinancialAccountDQ() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        List<String> results = IBot_ConfigSettings.getInstance().getSelectFieldsListForFADQ();

        System.assert(results != null);
        System.assert(results.size() > 0);
        System.assertEquals('Id', results.get(0));

        Test.stopTest();
    }

    @isTest static void testGetSelectFieldsForCardDQ() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        List<String> results = IBot_ConfigSettings.getInstance().getSelectFieldsListForCardDQ();

        System.assert(results != null);
        System.assert(results.size() > 0);
        System.assertEquals('Id', results.get(0));

        Test.stopTest();
    }

    @isTest static void testGetCardObjectAPIName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getCardObjectAPIName();

        System.assertEquals('FinServ__Card__c', result);

        Test.stopTest();
    }

    @isTest static void testGetCardFALookUpAPIName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getCardFALookUpAPIName();

        System.assertEquals('FinServ__FinancialAccount__c', result);

        Test.stopTest();
    }

    @isTest static void testGetCardNumberFieldAPIName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getCardNumberFieldAPIName();

        System.assertEquals('FinServ__BinNumber__c', result);

        Test.stopTest();
    }

    @isTest static void testGetCaseFALookUpAPIName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getCaseFALookUpAPIName();

        System.assertEquals('FinServ__FinancialAccount__c', result);

        Test.stopTest();
    }

    @isTest static void testGetOrgWideEmailAddress() {
        IBot_CustomMetadataBean customMetadataBean = new IBot_CustomMetadataBean();
        customMetadataBean.setMasterLabel('BotOrgWideEmailAddress');
        customMetadataBean.setNamespacePrefix('');
        customMetadataBean.setValue('abc@salesforce.com');
        customMetadataBean.setDeveloperName('BotOrgWideEmailAddress');

        IBot_ConfigSettings.getInstance().addFSCBotSetting('BotOrgWideEmailAddress',customMetadataBean);

        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getOrgWideEmailAddress();

        System.assertEquals('abc@salesforce.com', result);

        Test.stopTest();
    }

    @isTest static void testGetEmailService() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getEmailService();

        System.assertEquals('IBot_OOBEmailService', result);

        Test.stopTest();
    }

    @isTest static void testGetMessagingService() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getMessagingService();

        System.assertEquals('IBot_OOBTwilioMessagingService', result);

        Test.stopTest();
    }

    @isTest static void testGetnoReplyEmailAddress() {
        IBot_CustomMetadataBean customMetadataBean = new IBot_CustomMetadataBean();
        customMetadataBean.setMasterLabel('NoReplyEmailAddress');
        customMetadataBean.setNamespacePrefix('');
        customMetadataBean.setValue('noreply@salesforce.com');
        customMetadataBean.setDeveloperName('NoReplyEmailAddress');

        IBot_ConfigSettings.getInstance().addFSCBotSetting('NoReplyEmailAddress',customMetadataBean);

        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getnoReplyEmailAddress();

        System.assertEquals('noreply@salesforce.com', result);

        Test.stopTest();
    }

    @isTest static void testGetTwilioFromPhoneNumber() {
        IBot_CustomMetadataBean customMetadataBean = new IBot_CustomMetadataBean();
        customMetadataBean.setMasterLabel('TwilioFromPhoneNumber');
        customMetadataBean.setNamespacePrefix('');
        customMetadataBean.setValue('904-329-7443');
        customMetadataBean.setDeveloperName('TwilioFromPhoneNumber');

        IBot_ConfigSettings.getInstance().addFSCBotSetting('TwilioFromPhoneNumber',customMetadataBean);

        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getTwilioFromPhoneNumber();

        System.assertEquals('904-329-7443', result);

        Test.stopTest();
    }

    @isTest static void testGetTwilioAccountSid() {
        IBot_CustomMetadataBean customMetadataBean = new IBot_CustomMetadataBean();
        customMetadataBean.setMasterLabel('TwilioAccountSid');
        customMetadataBean.setNamespacePrefix('');
        customMetadataBean.setValue('abcdef');
        customMetadataBean.setDeveloperName('TwilioAccountSid');

        IBot_ConfigSettings.getInstance().addFSCBotSetting('TwilioAccountSid',customMetadataBean);

        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getTwilioAccountSid();

        System.assertEquals('abcdef', result);

        Test.stopTest();
    }

    @isTest static void testGetTwilioAuthToken() {
        IBot_CustomMetadataBean customMetadataBean = new IBot_CustomMetadataBean();
        customMetadataBean.setMasterLabel('TwilioAuthToken');
        customMetadataBean.setNamespacePrefix('');
        customMetadataBean.setValue('abcdef');
        customMetadataBean.setDeveloperName('TwilioAuthToken');

        IBot_ConfigSettings.getInstance().addFSCBotSetting('TwilioAuthToken',customMetadataBean);

        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getTwilioAuthToken();

        System.assertEquals('abcdef', result);

        Test.stopTest();
    }

    @isTest static void testGetTwilioEndPoint() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getTwilioEndPoint();

        System.assertEquals('https://api.twilio.com/2010-04-01/Accounts/{accountSid}/SMS/Messages.json', result);

        Test.stopTest();
    }

    @isTest static void testIsOTPTestModeEnabled() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        Boolean result = IBot_ConfigSettings.getInstance().isOTPTestModeEnabled();

        System.assertEquals(false, result);

        Test.stopTest();
    }

    @isTest static void testGetVCExpirationMinutes() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        Integer result = IBot_ConfigSettings.getInstance().getVCExpirationMinutes();

        System.assertEquals(15, result);

        Test.stopTest();
    }

    @isTest static void testGetCardValidUntilFieldAPIName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getCardValidUntilFieldAPIName();

        System.assertEquals('FinServ__ValidUntil__c', result);

        Test.stopTest();
    }

    @isTest static void testGetCardActiveFieldAPIName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getCardActiveFieldAPIName();

        System.assertEquals('FinServ__Active__c', result);

        Test.stopTest();
    }

    @isTest static void testGetCaseChatKeyFieldAPIName() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getCaseChatKeyFieldAPIName();

        System.assertEquals('ChatKey__c', result);

        Test.stopTest();
    }

    @isTest static void testGetTimebasedOTPDefaultUserId() {
        IBot_CustomMetadataBean customMetadataBean = new IBot_CustomMetadataBean();
        customMetadataBean.setMasterLabel('TimebasedOTPDefaultUserId');
        customMetadataBean.setNamespacePrefix('');
        customMetadataBean.setValue('1234');
        customMetadataBean.setDeveloperName('TimebasedOTPDefaultUserId');

        IBot_ConfigSettings.getInstance().addFSCBotSetting('TimebasedOTPDefaultUserId',customMetadataBean);

        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getTimebasedOTPDefaultUserId();

        System.assertEquals('1234', result);

        Test.stopTest();
    }

    @isTest static void testGetTimebasedOTPAppKey() {
        IBot_CustomMetadataBean customMetadataBean = new IBot_CustomMetadataBean();
        customMetadataBean.setMasterLabel('TimebasedOTPAppKey');
        customMetadataBean.setNamespacePrefix('');
        customMetadataBean.setValue('abcd');
        customMetadataBean.setDeveloperName('TimebasedOTPAppKey');

        IBot_ConfigSettings.getInstance().addFSCBotSetting('TimebasedOTPAppKey',customMetadataBean);

        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getTimebasedOTPAppKey();

        System.assertEquals('abcd', result);

        Test.stopTest();
    }

    @isTest static void testGetTimebasedOTPAuthenticator() {
        Test.startTest();
        
        IBot_ConfigBeanBase configBeanBase =  new IBot_ConfigBeanBase();
        String result = IBot_ConfigSettings.getInstance().getTimebasedOTPAuthenticator();

        System.assertEquals('IBot_OOBTimebasedOTPAuthenticator', result);

        Test.stopTest();
    }
}