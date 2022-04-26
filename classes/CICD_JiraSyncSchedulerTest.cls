@isTest
public class CICD_JiraSyncSchedulerTest {

    public static testMethod void testScheduler(){

        Test.startTest();

            System.schedule( 'CICD_JiraSyncSchedulerTest' ,  '0 0 23 * * ?', new CICD_JiraSyncScheduler());

        Test.stopTest();
    }
    
}