/*  Copyright [2018] [salesforce.com]
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
/**
 * @description
 **/
global with sharing class IBot_CountryValidatorCtrl {
    global class ValidationRequest{
        @InvocableVariable
        global String country;
        @InvocableVariable
        global Integer noOfRetries;
    }

    global class ValidationResponse{
        @InvocableVariable
        global boolean isValid;
        @InvocableVariable
        global Integer noOfRetries;
    }

    
    @InvocableMethod(label='Validate Country Name' description='Validates the country name against list of valid country names from csv static resource')
    global static List<ValidationResponse> validateCountryName(List<ValidationRequest> requests){
        List<ValidationResponse> responses = new List<ValidationResponse>();
        if(requests==null || requests.size()==0){
            return responses;
        }

        IBot_CountryValidationService service = IBot_CountryValidationService.getInstance();
        
        for(ValidationRequest request: requests){
            ValidationResponse response = new ValidationResponse();
            response.isValid = service.isValidCountry(request.country);
            response.noOfRetries = (request.noOfRetries == null) ? 1 : request.noOfRetries + 1;
            responses.add(response);
        }
        return responses;
    }
}