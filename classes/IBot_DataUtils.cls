/*  Copyright [2018] [salesforce.com]
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

/**
 * @description Creates dummy data for FSC bot flow.
 **/
public class IBot_DataUtils {


    public static void createFscBotData() {
        Account account = createAccountAndContact('Johnson Smith (FscBot)', UserInfo.getUserEmail(), '9999999999');
        sObject financialAccount = createFinancialAccount(account.Id, '896700909192', 'Credit Card');
        sObject card = createCard('Gold Card (FscBot)', account.Id, financialAccount.Id);
        card = createCard('Platinum Card (FscBot)', account.Id, financialAccount.Id, '1111222233334444');
        card = createCard('Silver Card (FscBot)', account.Id, financialAccount.Id,'1111222233334445');

        Account account2 = createAccountAndContact('Olivia Lopez (FscBot)', UserInfo.getUserEmail(), '9999999999');
        sObject financialAccount2 = createFinancialAccount(account2.Id, '896700909193', 'Savings');
        sObject card2 = createCard('Silver Card (FscBot)', account2.Id, financialAccount2.Id);
        card2 = createCard('Rubyx (FscBot)', account2.Id, financialAccount2.Id,'1111222233334446');
        card2 = createCard('Coral Card (FscBot)', account2.Id, financialAccount2.Id,'1111222233334447');

        Account account3 = createAccountAndContact('Mary Smith (FscBot)', UserInfo.getUserEmail(), '9999999999');
        sObject financialAccount3 = createFinancialAccount(account3.Id, '896700909194', 'Checking');
        sObject card3 = createCard('Platinum Card (FscBot)', account3.Id, financialAccount3.Id,'1111222233334448');

        Account account4 = createAccountAndContact('Linda Ray (FscBot)', UserInfo.getUserEmail(), '9999999999');
        sObject financialAccount4 = createFinancialAccount(account4.Id, '896700909195', 'Credit Card');
        sObject card4 = createCard('Travel Card (FscBot)', account4.Id, financialAccount4.Id,'1111222233334449');

        Account account5 = createAccountAndContact('David Boon (FscBot)', UserInfo.getUserEmail(), '9999999999');
        sObject financialAccount5 = createFinancialAccount(account5.Id, '896700909196', 'Savings');
        sObject card5 = createCard('Jetmiles Card (FscBot)', account5.Id, financialAccount5.Id,'1111222233334450');
    }

    public static Account createAccountAndContact(String name, String email, String mobile) {
        if(isPersonAccountsEnabled()) {
            return createPersonAccountModalData(name, email, mobile);
        }else{
            return createIndividualModalData(name, email, mobile);
        }
    }

    public static Account createPersonAccountModalData(String name, String email, String mobile) {
        RecordType recordType = [Select Id from RecordType where DeveloperName = 'PersonAccount'  and SobjectType = 'Account'];
        Account account = new Account();
        account.put('LastName', name);
        account.put('PersonEmail', email);
        account.put('PersonMobilePhone', mobile);
        if(recordType != null)
            account.put('RecordTypeId', recordType.id);
        Database.insert(account);

        String soql = 'Select PersonContactId from Account where Id =\'' + account.id + '\'';
        List<Account> accountList = Database.query(soql);
        Account acc = accountList.get(0);
        account.put('FinServ__PrimaryContact__c', acc.get('PersonContactId'));
        update account;

        return account;
    }

    public static Account createIndividualModalData(String name, String email, String mobile) {
        if (Schema.sObjectType.Account.fields.Name.isCreateable() &&
            Schema.sObjectType.Account.fields.RecordTypeId.isCreateable() ){
            
            RecordType recordType = [Select Id from RecordType where DeveloperName = 'IndustriesIndividual'  and SobjectType = 'Account'];
            Account account = new Account();
            account.Name = name;
    
            if(recordType != null){
                account.RecordTypeId = recordType.id;
            }
            
            insert account;
            
            if (Schema.sObjectType.Contact.fields.Email.isUpdateable() &&
                Schema.sObjectType.Contact.fields.MobilePhone.isUpdateable()){
                Contact contact = [Select Id from Contact where AccountId =: account.id];
                contact.Email = email;
                contact.MobilePhone = mobile;
        
                update contact;
                    
                return account;
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access')); 
                return null;
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access')); 
            return null;
        }
    }

    public static sObject createFinancialAccount(String accountId, String accountNumber, String accountType) {
        sObject sObj = IBot_DynamicSObjectCreation.createObject('FinServ__FinancialAccount__c');
        sObj.put('Name', 'Credit Card (FscBot)');
        sObj.put('FinServ__PrimaryOwner__c', accountId);
        sObj.put('FinServ__FinancialAccountNumber__c', accountNumber);
        sObj.put('FinServ__FinancialAccountType__c', accountType);

        Database.insert(sObj);

        return sObj;
    }

    public static sObject createCard(String cardName, String accountId, String financialAccountId, String ccnumber) {
        sObject sObj = IBot_DynamicSObjectCreation.createObject('FinServ__Card__c');
        sObj.put('Name', cardName);
        sObj.put('FinServ__AccountHolder__c', accountId);
        sObj.put('FinServ__Active__c', true);
        sObj.put('FinServ__FinancialAccount__c', financialAccountId);
        sObj.put('FinServ__ValidUntil__c', Date.today().addDays(365));
        sObj.put('FinServ__BinNumber__c', Double.valueOf(ccnumber));

        Database.insert(sObj);

        return sObj;
    }

    public static sObject createCard(String cardName, String accountId, String financialAccountId) {
        sObject sObj = IBot_DynamicSObjectCreation.createObject('FinServ__Card__c');
        sObj.put('Name', cardName);
        sObj.put('FinServ__AccountHolder__c', accountId);
        sObj.put('FinServ__Active__c', true);
        sObj.put('FinServ__FinancialAccount__c', financialAccountId);
        sObj.put('FinServ__ValidUntil__c', Date.today().addDays(365));
        sObj.put('FinServ__BinNumber__c', Double.valueOf('1111222233334444'));

        Database.insert(sObj);

        return sObj;
    }

    public static Boolean isPersonAccountsEnabled(){
        return Account.SObjectType.getDescribe().hasSubtypes;
    }
}