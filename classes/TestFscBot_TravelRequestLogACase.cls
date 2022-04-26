@isTest
public class TestFscBot_TravelRequestLogACase {
    
    private static String ACCOUNT_NAME = 'TestAccount';
    
    @testsetup static void createTestData() {
        Account account = TestIBot_Util.createIndividualAccount(ACCOUNT_NAME);
        SObject financialAccount = TestIBot_Util.createFinancialAccount(account.id, '0000123123', 'Checking');
        SObject card = TestIBot_Util.createCard('CreditCard', account.id, financialAccount.id);
    }

    @isTest
    public static void testvalidateAccountUsingEmailWithNullCaseCreationRequest () {
        
        List<FscBot_TravelRequestLogACaseCtrl.CaseRequest> inputList;
        Test.startTest();

        FscBot_TravelRequestLogACaseCtrl.CaseResponse response =  FscBot_TravelRequestLogACaseCtrl.createCase(inputList).get(0);

        Test.stopTest();

        System.assert(response.caseId == null, 'CaseId cannot be created for NULL Case Creation Request');
        System.assert(response.caseNumber == null, 'CaseNumber cannot be created for NULL Case Creation Request');
        System.assert(response.message == null, 'Case Message cannot be created for NULL Case Creation Request');
    }
    
    @isTest
    public static void testCreateCaseWithEmptyCaseCreationRequest () {
        
        List<FscBot_TravelRequestLogACaseCtrl.CaseRequest> inputList = new List<FscBot_TravelRequestLogACaseCtrl.CaseRequest>();
        Test.startTest();

        FscBot_TravelRequestLogACaseCtrl.CaseResponse response =  FscBot_TravelRequestLogACaseCtrl.createCase(inputList).get(0);

        Test.stopTest();

        System.assert(response.caseId == null, 'CaseId cannot be created for Empty Case Creation Request');
        System.assert(response.caseNumber == null, 'CaseNumber cannot be created for Empty Case Creation Request');
        System.assert(response.message == null, 'Case Message cannot be created for Empty Case Creation Request');
    }

    @isTest static void testCreateCase() {
        List<FscBot_TravelRequestLogACaseCtrl.CaseRequest> caseCreationRequestList = new List<FscBot_TravelRequestLogACaseCtrl.CaseRequest>();

        Contact contact = [Select Id from Contact limit 1];
        FinServ__FinancialAccount__c financialAccount = [Select Id from FinServ__FinancialAccount__c limit 1];
        FinServ__Card__c card = [Select Id from FinServ__Card__c limit 1];

        FscBot_TravelRequestLogACaseCtrl.CaseRequest caseCreationRequest = new FscBot_TravelRequestLogACaseCtrl.CaseRequest();
        caseCreationRequest.con = contact;
        caseCreationRequest.financialAccId = financialAccount.id;
        caseCreationRequest.selectedCard = card.id;
        caseCreationRequest.chatKey = 'TestKey';
        caseCreationRequest.fromDate = Date.today().addDays(3);
        caseCreationRequest.toDate = Date.today().addDays(30);
        caseCreationRequest.travelCountry = 'USA';

        caseCreationRequestList.add(caseCreationRequest);

        List<Case> cases = [Select Id from Case];
        System.assertEquals(0, cases.size());
        
        Test.startTest();

        List<FscBot_TravelRequestLogACaseCtrl.CaseResponse> caseCreationResponseList = FscBot_TravelRequestLogACaseCtrl.createCase(caseCreationRequestList);
        
        Test.stopTest();

        cases = [Select Id, CaseNumber from Case];
        System.assertEquals(1, cases.size());
        
        System.assert(caseCreationResponseList != null);
        System.assertEquals(1, caseCreationResponseList.size());
        System.assertEquals(cases.get(0).caseNumber, caseCreationResponseList.get(0).caseNumber);
        System.assert(caseCreationResponseList.get(0).message.contains('Your request has been submitted'));   
    }
    
}