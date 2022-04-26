trigger tgrDataTemplate on copado__Data_Template__c (before insert,before update) {
	for(copado__Data_Template__c dt:trigger.new)
    {
          dt.copado__Description__c	 = 'Built and Maintained by Blue5Green - v1.0';
    }
}