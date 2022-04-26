global with sharing class FscBot_ValidateDatesCtrl {
    
    global class ValidateDatesRequest{
        @InvocableVariable
        global Date fromDate;
        @InvocableVariable
        global Date toDate;
    }

  /**
    * @description this invocable method is wired with a bot dialogue to validate if fromDate is before toDate or not
    * @param List<ValidateDatesRequest> inputList
    * @return List<boolean>
    **/
    @InvocableMethod(label='Validate Dates' description='Validates if from date is before to date')
    public static List<boolean> validateDates(List<FscBot_ValidateDatesCtrl.ValidateDatesRequest> inputList) {
        List<boolean> validateDatesResponses = new List<boolean>();
        for(FscBot_ValidateDatesCtrl.ValidateDatesRequest request : inputList){
            if(request.fromDate <= request.toDate){
                validateDatesResponses.add(true);
            }
            else{
                validateDatesResponses.add(false);
            }
        }
        return validateDatesResponses;
    }
}