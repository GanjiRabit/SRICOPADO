@isTest(seeAllData=false isParallel=true)
public with sharing class AccelQService_isTest {
  @TestSetup
  static void setupData() {
    createDefaultConig();
    createDefaultMapping();
  }

  public static void createDefaultConig() {
    list<string> configItems = new List<String>{
      'accelQUserName',
      'accelQPassword',
      'accelQAuthType',
      'accelQAuthValidated',
      'accelQAuthLastValidatedOn',
      'accelQUrl',
      'accelQDefaultProject',
      'accelQDefaultCIJob',
      'accelQDefualtRunTimeAttributes',
      'accelQTenant'
    };

    List<CS_IntegrationConfig__c> configsToSetup = new List<CS_IntegrationConfig__c>();

    for (string item : configItems) {
      configsToSetup.add(
        new CS_IntegrationConfig__c(Name = item, value__c = item)
      );
    }

    insert configsToSetup;
  }

  public static void createDefaultMapping() {
    CS_IntegrationFieldMapping__c mapping = new CS_IntegrationFieldMapping__c(
      SobjectAPIName__c = 'Task',
      SourceAPIName__c = 'Status__c'
    );

    AccelQConnect.saveMapping(
      JSON.serialize((new List<CS_IntegrationFieldMapping__c>{ mapping })),
      JSON.serialize((new List<CS_IntegrationFieldMapping__c>())),
      JSON.serialize((new List<CS_IntegrationFieldMapping__c>())),
      'Task'
    );
  }
  public static testMethod void testLogin() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      AccelQServiceMock.getMock('login', 200)
    );
    AccelQConnect.login(null, null, null);
    AccelQConnect.verifyCredentials(null, null, null);
    test.stopTest();
  }

  public static testMethod void testConfig() {
    Test.startTest();
    AccelQConnect.getConfig();
    AccelQConnect.getObjectsMetadata();

    //negative scenario
    AccelQConnect.configItems = null;
    AccelQConnect.getConfig();
    Test.stopTest();
  }

  public static testMethod void testSaveConfig() {
    Test.startTest();
    List<CS_IntegrationConfig__c> items = new List<CS_IntegrationConfig__c>();
    items.add(new CS_IntegrationConfig__c());
    AccelQConnect.saveConfig(JSON.serialize(items));
    AccelQConnect.saveConfig(null);
    Map<string, string> config = new Map<String, string>{
      'accelQPassword' => 'test'
    };

    AccelQConnect.saveConfig(JSON.serialize(config));
    Test.stopTest();
  }

  public static testMethod void createJob() {
    Test.startTest();
    Task t = new Task(Type = 'call', subject = 'Test call');
    insert t;

    List<RunAccelQCIJobWithCustomParams.CIJobRequest> requests = new List<RunAccelQCIJobWithCustomParams.CIJobRequest>();
    RunAccelQCIJobWithCustomParams.CIJobRequest request = new RunAccelQCIJobWithCustomParams.CIJobRequest();
    request.parentId = t.Id;
    request.ciJobId = '500';
    request.runTimeAttributes = 'test';
    requests.add(request);
    RunAccelQCIJobWithCustomParams.execute(requests);

    Test.stopTest();
  }
  public static testMethod void createJobs() {
    Test.startTest();
    Task t = new Task(Type = 'call', subject = 'Test call');
    insert t;
    RunAccelQCIJobWithDefaults.execute((new List<string>{ t.Id }));

    Test.stopTest();
  }
  public static testMethod void triggerAndMonitor() {
    Test.startTest();
    Task t = new Task(Type = 'call', subject = 'Test call');
    insert t;
    AccelQConnect.createNewJob(t.Id);

    Test.setMock(
      HttpCalloutMock.class,
      AccelQServiceMock.getMock('login', 200)
    );
    Map<String, string> tokens = AccelQConnect.getAccessToken();
    AccelQConnect.login(null, null, null);
    AccelQCIJobInitiator jobInitator = new AccelQCIJobInitiator(tokens);
    Test.setMock(
      HttpCalloutMock.class,
      AccelQServiceMock.getMock('trigger-ci', 200)
    );
    Database.executeBatch(jobInitator, 1);

    CIJob__c job = [
      SELECT id, CIJobInstanceId__c, Status__c
      FROM CIJob__c
      LIMIT 1
    ];
    job.CIJobInstanceId__c = '5500';
    job.Status__c = 'Running';
    update job;

    Test.setMock(
      HttpCalloutMock.class,
      AccelQServiceMock.getMock('jobsummary', 200)
    );
    AccelQCIJobMonitoringService jonmonitor = new AccelQCIJobMonitoringService(
      tokens
    );
    Database.executeBatch(jonmonitor, 1);

    AccelQConnect.triggerMonitoringService(job.id);

    delete job;
    undelete job;
    Test.stopTest();
  }

  public static testMethod void testMonitoringServices() {
    test.startTest();
    (new MonitoringServiceScheduler()).execute(null);
    test.stopTest();
  }
}