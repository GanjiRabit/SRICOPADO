global class MonitoringServiceScheduler implements Schedulable{
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new AccelQCIJobMonitoringService() , 1);
    }
}