/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/v1/cases/*')
global class Thankful_FetchCaseDetails extends thankful.Thankful_Utilities {
    global static Map<String,String> additionalConfig;
    global static Boolean isApiInProgress;
    global static Boolean issueRetrievingCase;
    global static Map<String,Object> responseToReturn;
    global static Map<Id,List<Object>> sobjectAttachmentRecords;
    global Thankful_FetchCaseDetails() {

    }
    global static void collectAttachments(String parentId, String title, String recordId) {

    }
    global static String convertToUTCString(Datetime dateTimeValue) {
        return null;
    }
    global static void dispensePostRequest(System.RestRequest req, System.RestResponse res) {

    }
    global static void dispensePutRequest(System.RestRequest req, System.RestResponse res) {

    }
    @HttpGet
    global static void doGet() {

    }
    global static void fetchCaseDetails(String requestUrl, System.RestResponse res) {

    }
    global static List<Map<String,Object>> getAddtionalInformation(Case caseRecord) {
        return null;
    }
    global static Object getCaseActivty(String caseId) {
        return null;
    }
    global static List<String> getCaseTopics(String caseId) {
        return null;
    }
    global static thankful__ThankfulActivity__c getStrictActivity(Map<String,Object> message, String caseId) {
        return null;
    }
    global static Object getValueFromRecordData(String field, SObject recordData) {
        return null;
    }
    global static void handleApiError(System.RestResponse res, Exception Ex, Boolean isGetRequest) {

    }
    global static void handleApiSuccess(System.RestResponse res) {

    }
    global static void handleCreateTicket(System.RestRequest req, System.RestResponse res) {

    }
    @HttpPost
    global static void handlePost() {

    }
    @HttpPut
    global static void handlePut() {

    }
    global static void handleTagging(System.RestRequest req, System.RestResponse res) {

    }
    global static void handleUpsertMessage(System.RestRequest req, System.RestResponse res) {

    }
}
