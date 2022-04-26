@isTest
global with sharing class AccelQServiceMock {
  public static StaticResourceCalloutMock getMock(
    string mockType,
    integer statuscode
  ) {
    Map<string, string> responseMap = new Map<String, string>{
      'login' => 'AccelQLoginResponse',
      'trigger-ci' => 'AccelQJobInitator',
      'jobsummary' => 'AccelQJobMonitor'
    };

    string resourceName;
    for (string key : responseMap.keySet()) {
      if (mockType.contains(key))
        resourceName = responseMap.get(key);
    }
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(resourceName);
    mock.setStatusCode(statuscode);
    mock.setHeader('Content-Type', 'application/json');

    return mock;
  }
}