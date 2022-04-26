global with sharing class FscBot_ValidateCard {

    global class ValidateCardRequest{
        @InvocableVariable(required=true)
        global String accountId;
        @InvocableVariable(required=true)
        global String card;
        @InvocableVariable
        global Integer noOfRetries;
    }
    
    global class ValidateCardResponse{
        @InvocableVariable
        global Integer noOfRetries;
        @InvocableVariable
		global boolean isValid;        
    }
    
  /**
    * @description this invocable method is wired with a bot dialogue to validate the card selected
    * @param List<ValidateCardRequest> validateCardRequests
    * @return List<boolean>
    **/
    @InvocableMethod(label='Validate Card' description='Checks if the card selected by customer is valid')
    public static List<FscBot_ValidateCard.ValidateCardResponse> validateCard(List<FscBot_ValidateCard.ValidateCardRequest> validateCardRequests) {
        List<FscBot_ValidateCard.ValidateCardResponse> validateResponses = new List<FscBot_ValidateCard.ValidateCardResponse>();
                
        if(validateCardRequests.size() == 0){
            return validateResponses;
        }
        
        for(FscBot_ValidateCard.ValidateCardRequest request : validateCardRequests){
            FscBot_ValidateCard.ValidateCardResponse response = new FscBot_ValidateCard.ValidateCardResponse();
            response.noOfRetries = (request.noOfRetries == null) ? 1 : request.noOfRetries+1;
            String cardNumberField = IBot_ConfigSettings.getInstance().getCardNumberFieldAPIName();
            List<String> accountIds = new List<String>();
            accountIds.add(request.accountId);
            List<SObject> cards = IBot_DynamicQueryUtils.fetchCardsGivenFinancialAccIds(accountIds);
            String cardNumberMask = IBot_ConfigSettings.getInstance().getCardNumberMask();
            List<String> maskedCC = new List<String>();
            for(SObject cardSObj : cards){
                maskedCC.add(cardNumberMask + String.valueOf(cardSObj.get(cardNumberField)).right(4) + ' - '+ cardSObj.get('Name'));
            }

            if(maskedCC.contains(request.card)){
                response.isValid=true;
            } else{
                response.isValid=false;
            }
            validateResponses.add(response);
        }

        return validateResponses;

    }

}