public with sharing virtual class RestCalloutManager {
  public static Map<string, object> doRestCallout(
    string endpointUrl,
    Map<string, string> headerInfo,
    string methodType,
    string body
  ) {
    Map<string, object> response = new Map<string, object>();

    try {
      HttpRequest req = new HttpRequest();

      req.setEndpoint(endpointUrl);

      req.setMethod(methodType);

      if (body != null)
        req.setBody(body);

      req.setTimeout(120000);

      for (string key : headerInfo.keySet()) {
        if(headerInfo.get(key) != null)
        req.setHeader(key, headerInfo.get(key));
      }

      Http http = new Http();

      HTTPResponse res = http.send(req);

      response.put('isSuccess', true);
      response.put('status', res.getStatus());
      response.put('statusCode', res.getStatusCode());
      response.put('message', res.getBody());
system.debug('>> api response >> ' + response);

    } catch (Exception ex) {
      response.put('isSuccess', false);
      response.put('message', Ex.getMessage());
    }

    return response;
  }
}