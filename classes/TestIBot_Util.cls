@isTest
public class TestIBot_Util {
    
    public static List<Contact> createIndividualContacts(Integer numContacts){
        List<Contact> results = new List<Contact>();
        
        for(Integer i = 0; i < numContacts; i++){
            Contact c = new Contact();
            c.FirstName = 'Tester';
            c.LastName = 'McQueen '+i;
            c.Email = 'tmcqueen'+i+'@salesforce.com';
            c.MobilePhone = '415-001-00'+i;
            c.Phone = '415-001-00'+i;
            c.MailingStreet = '1 Market';
            c.MailingCity = 'San Francisco';
            c.MailingCountry = 'US';
            c.MailingPostalCode = '94105';
            results.add(c);
        }
        insert results;
        return results;
    }
    
    public static Account createIndividualAccount(String name) {
        RecordType recordType = [Select Id from RecordType where DeveloperName = 'IndustriesIndividual'  and SobjectType = 'Account'];
        Account account = new Account();
        account.Name = name;
        
        if(recordType != null)
            account.RecordTypeId = recordType.id;
        
        insert account;
        return account;
    }

    public static Account createIndividualAccount(String name, String email, String mobile) {
        return IBot_DataUtils.createIndividualModalData(name, email, mobile); 
    }

    public static Account createPersonAccount(String name, String email, String mobile) {
        return IBot_DataUtils.createPersonAccountModalData(name, email, mobile);
    }

    public static Contact createIndividualContact(String name) {
        RecordType recordType = [Select Id from RecordType where DeveloperName = 'IndustriesIndividual'  and SobjectType = 'Contact'];
        Contact contact = new Contact();
        contact.LastName = name;
        contact.Email = name + '@salesforce.com';
        contact.MobilePhone = '415-001-00';
        contact.Phone = '415-001-00';
        contact.MailingStreet = '1 Market';
        contact.MailingCity = 'San Francisco';
        contact.MailingCountry = 'US';
        contact.MailingPostalCode = '94105';

        if(recordType != null)
            contact.RecordTypeId = recordType.id;

        insert contact;
        return contact;
    }

    public static SObject createFinancialAccount(String accountId, String accountNumber, String accountType) {
        return IBot_DataUtils.createFinancialAccount(accountId, accountNumber, accountType);
    }

    public static SObject createCard(String cardName, String accountId, String financialAccountId) {
        return IBot_DataUtils.createCard(cardName, accountId, financialAccountId);
    }
    
    public static List<FscBot_Verification_Code__c> createTestVerificationCodes(List<Contact> contacts, String verificationMethod){
        List<FscBot_Verification_Code__c> results = new List<FscBot_Verification_Code__c>();
        for(Contact c : contacts){
            FscBot_Verification_Code__c newCode = new FscBot_Verification_Code__c();
            newCode.Contact__c = c.Id;
            newCode.Verification_Method__c = verificationMethod;
            newCode.Expires_On__c = DateTime.now().addMinutes(60);
            newCode.Code__c = 123123;
            results.add(newCode);
        }
        insert results;
        return results;
    }
}