@IsTest(seeAlldata=false)
global class RestCalloutManagerTest {
  global static testMethod void testCallout() {
    // Set mock callout class
    Test.setMock(HttpCalloutMock.class, new MockHttpRestCallout());

    object res = RestCalloutManager.doRestCallout(
      'http://example.com/example/test',
      new Map<String, String>{ 'Content-Type' => 'application/json' },
      'GET',
      '{"example":"test"}'
    );
  }

  global class MockHttpRestCallout implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
      System.assertEquals('http://example.com/example/test', req.getEndpoint());
      System.assertEquals('GET', req.getMethod());

      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"example":"test"}');
      res.setStatusCode(200);
      return res;
    }
  }
}