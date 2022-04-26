global class CICD_JiraSyncScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
      Database.executeBatch( new CICD_BatchJob() , 1);
   }
}