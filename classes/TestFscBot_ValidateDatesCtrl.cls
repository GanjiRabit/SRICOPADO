@isTest
private class TestFscBot_ValidateDatesCtrl {

    @isTest static void testValidDates(){
        FscBot_ValidateDatesCtrl.ValidateDatesRequest request = new FscBot_ValidateDatesCtrl.ValidateDatesRequest();
        request.fromDate=Date.valueOf('2018-07-23');
        request.toDate=Date.valueOf('2018-07-24');
        List<boolean> validateResponses = FscBot_ValidateDatesCtrl.validateDates(new List<FscBot_ValidateDatesCtrl.ValidateDatesRequest>{request});
        
        System.assert(validateResponses != null);
        System.assertEquals(1, validateResponses.size());
        System.assertEquals(true, validateResponses.get(0));

    }

    @isTest static void testInvalidDates(){
        FscBot_ValidateDatesCtrl.ValidateDatesRequest request = new FscBot_ValidateDatesCtrl.ValidateDatesRequest();
        request.fromDate=Date.valueOf('2018-07-24');
        request.toDate=Date.valueOf('2018-07-23');
        List<boolean> validateResponses = FscBot_ValidateDatesCtrl.validateDates(new List<FscBot_ValidateDatesCtrl.ValidateDatesRequest>{request});
        
        System.assert(validateResponses != null);
        System.assertEquals(1, validateResponses.size());
        System.assertEquals(false, validateResponses.get(0));
        
    }

}