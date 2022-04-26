/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class COA_ServiceOrderRecall {
    global COA_ServiceOrderRecall() {

    }
    @InvocableMethod(label='Recall Service Orders' description='Recalls service orders that have been sent to the Partner Operations team so that they are no longer processed.')
    global static List<CHANNEL_ORDERS.COA_ServiceOrderRecall.COA_ServiceOrderRecallOutput> recall(List<CHANNEL_ORDERS.COA_ServiceOrderRecall.COA_ServiceOrderRecallInput> serviceOrderRecallInput) {
        return null;
    }
global class COA_ServiceOrderRecallInput {
    @InvocableVariable( required=true)
    global Id serviceOrderId;
    global COA_ServiceOrderRecallInput() {

    }
}
global class COA_ServiceOrderRecallOutput {
    @InvocableVariable( required=false)
    global Boolean isSuccess;
    @InvocableVariable( required=false)
    global List<String> responseMessages;
    @InvocableVariable( required=false)
    global Id serviceOrderId;
}
}
