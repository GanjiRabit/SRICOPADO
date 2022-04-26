trigger IBot_VerificationCodeTrigger on FscBot_Verification_Code__c (after insert) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            IBot_VerificationCodeTriggerHelper.handleAfterInsert(Trigger.new);
        }
    }

}