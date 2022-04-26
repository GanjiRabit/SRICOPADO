Global with sharing class RunAccelQCIJobWithCustomParams {
    @InvocableMethod(label='Initiate accelQ CI Job With Custom Params')
    global static void execute(List<CIJobRequest> ciJobRequests){
        AccelQConnect.createJobs(null, ciJobRequests);

    }

    global class CIJobRequest {
        @InvocableVariable(label='Parent ID' description='ID of Parent Object' required=true)
        public id parentId;
        @InvocableVariable(label='CI Job ID' description='ID of CI JOB from AccelQ' required=true)
        public string ciJobId;
        @InvocableVariable(label='Run Time Attributes' description='Params to Pass to AccelQ CI Job')
        public string runTimeAttributes;
        
    }
      
}