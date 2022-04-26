@isTest
private class TestIBot_LiveChatTranscriptTriggerHelper {

    @testsetup static void createTestData() {
        Case newCase = new Case();
        newCase.Status = 'New';
        newCase.Origin = 'Web';
        newCase.ChatKey__c = 'testkey';
        insert newCase;
    }

    @isTest static void testIBot_LiveChatTranscriptTriggerHelper() {
        Case newCase = [Select Id from Case limit 1];
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        Test.startTest();
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript();
        liveChatTranscript.LiveChatVisitorID = liveChatVisitor.id;
        liveChatTranscript.ChatKey = 'testkey';
        liveChatTranscript.Body = 'TestBody';
        insert liveChatTranscript;

        Test.stopTest();

        Case cases = [Select Id, Live_Chat_Transcript__c from Case where Id =: newCase.id LIMIT 1];
        System.assertEquals(cases.Live_Chat_Transcript__c, liveChatTranscript.Id);
    }
}