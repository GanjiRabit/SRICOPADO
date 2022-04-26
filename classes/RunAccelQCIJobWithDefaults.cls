global with sharing class RunAccelQCIJobWithDefaults {
    @InvocableMethod(label='Initiate accelQ CI Job With Defaults')
    global static void execute(List<Id> parentIds){
        AccelQConnect.createJobs(parentIds, null);
    }

}