/**
 * The endpoint that Matches the user input to either yes or no or confused
 */
global with sharing class IBot_ConfirmYesNo {
    
    /**
	* @description this method matches possible inputs for Yes or No
	* @return return 'yes','no','confused' corresponding to match found
	*/
    @InvocableMethod(label='Confirm Yes or No' description='Matches the user input to Yes or No or Confused')
    global static List<String> getMatchedYesNoResponse(List<String> inputList )
    {
        List<String> responseList = new List<String>();
        String response;
        if(inputList == null || inputList.isEmpty() || inputList.get(0) == null) {
            response='Confused';
            responseList.add(response);
            return responseList;
        }
        
        for(String input: inputList){
            if(input.containsIgnoreCase('yes') && input.containsIgnoreCase('no'))
                response='Confused';
            else if(input.startsWithIgnoreCase('yes') )
                response='Yes';
            else if(input.startsWithIgnoreCase('no'))
                response='No';
            else
                response='Confused';
            responseList.add(response);
        }

        return responseList;
    }

}