/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class COA_ServiceOrderClone {
    global COA_ServiceOrderClone() {

    }
    @InvocableMethod(label='Clone Service Orders' description='Clones an existing service order in your organization and optionally its products.')
    global static List<CHANNEL_ORDERS.COA_ServiceOrderClone.COA_ServiceOrderCloneOutput> clone(List<CHANNEL_ORDERS.COA_ServiceOrderClone.COA_ServiceOrderCloneInput> serviceOrderCloneInput) {
        return null;
    }
global class COA_ServiceOrderCloneInput {
    @InvocableVariable( required=true)
    global Boolean cloneProducts;
    @InvocableVariable( required=true)
    global Id serviceOrderId;
    global COA_ServiceOrderCloneInput() {

    }
}
global class COA_ServiceOrderCloneOutput {
    @AuraEnabled
    @InvocableVariable( required=false)
    global Id cloneServiceOrderId;
    @AuraEnabled
    @InvocableVariable( required=false)
    global Boolean isSuccess;
    @AuraEnabled
    @InvocableVariable( required=false)
    global Id originalServiceOrderId;
    @AuraEnabled
    @InvocableVariable( required=false)
    global List<String> responseMessages;
}
}
