/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class COA_ServiceOrderSubmit {
    global COA_ServiceOrderSubmit() {

    }
    @InvocableMethod(label='Submit Service Orders' description='Submits service orders to the Partner Operations team so that they will be processed.')
    global static List<CHANNEL_ORDERS.COA_ServiceOrderSubmit.COA_ServiceOrderSubmitOutput> submit(List<CHANNEL_ORDERS.COA_ServiceOrderSubmit.COA_ServiceOrderSubmitInput> serviceOrderSubmitInput) {
        return null;
    }
global class COA_ServiceOrderSubmitInput {
    @InvocableVariable( required=true)
    global Id serviceOrderId;
    global COA_ServiceOrderSubmitInput() {

    }
}
global class COA_ServiceOrderSubmitOutput {
    @InvocableVariable( required=false)
    global Boolean isSuccess;
    @InvocableVariable( required=false)
    global List<String> responseMessages;
    @InvocableVariable( required=false)
    global Id serviceOrderId;
}
}
