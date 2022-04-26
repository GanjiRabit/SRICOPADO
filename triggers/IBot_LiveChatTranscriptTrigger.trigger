trigger IBot_LiveChatTranscriptTrigger on LiveChatTranscript (after insert) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            IBot_LiveChatTranscriptTriggerHelper.handleAfterInsert(Trigger.new);
        }
    }

}