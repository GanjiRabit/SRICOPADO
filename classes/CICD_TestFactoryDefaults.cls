@isTest
public class CICD_TestFactoryDefaults{

  

  public class copadoReleaseDefaults implements CICD_TestFactory.FieldDefaults {
      public Map<Schema.SObjectField, Object> getFieldDefaults() {
          return new Map<Schema.SObjectField, Object> {
            copado__Release__c.Name => 'SFDC 2019-11-11',
            copado__Release__c.CICD_RelatedProjects__c => 'All',
            copado__Release__c.CICD_StartDate__c =>  Date.today(),        
            copado__Release__c.copado__Planned_Date__c => Date.today().addDays(7),
            copado__Release__c.CICD_ReleaseIds__c => '1009;1008'
          };
        }
  } 

   public class copadoProjectDefaults implements CICD_TestFactory.FieldDefaults {
      public Map<Schema.SObjectField, Object> getFieldDefaults() {
          return new Map<Schema.SObjectField, Object> {
            copado__Project__c.Name => 'CICD'
            
          };
        }
  } 

  
}