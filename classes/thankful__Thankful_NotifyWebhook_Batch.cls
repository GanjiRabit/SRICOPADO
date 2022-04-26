/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Thankful_NotifyWebhook_Batch implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {
    global String endPoint;
    global String queryToRun;
    global Map<String,String> webhookHeaders;
    global Thankful_NotifyWebhook_Batch() {

    }
    global void execute(Database.BatchableContext info, List<thankful__CasesToProcess__c> ctpRecords) {

    }
    global void finish(Database.BatchableContext info) {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
}
