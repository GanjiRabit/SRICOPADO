@isTest
public class TestIBot_CountryValidator {
    @isTest static void testValidateCountry(){
        List<IBot_CountryValidatorCtrl.ValidationRequest> requests = new List<IBot_CountryValidatorCtrl.ValidationRequest>();
        
        IBot_CountryValidatorCtrl.ValidationRequest validCountryRequest = new IBot_CountryValidatorCtrl.ValidationRequest();
		validCountryRequest.country='India';
        validCountryRequest.noOfRetries=0;
        requests.add(validCountryRequest);

        IBot_CountryValidatorCtrl.ValidationRequest inValidCountryRequest = new IBot_CountryValidatorCtrl.ValidationRequest();
		inValidCountryRequest.country='Ikea';
        inValidCountryRequest.noOfRetries=2;
        requests.add(inValidCountryRequest);

        List<IBot_CountryValidatorCtrl.ValidationResponse> responses = IBot_CountryValidatorCtrl.validateCountryName(requests);
		System.assertEquals(2,responses.size(),'Invalid number of responses returned');
        System.assertEquals(true,responses.get(0).isValid,'Invalid Country Validation for Valid Country');
        System.assertEquals(1,responses.get(0).noOfRetries,'Invalid number of retries for Valid Country');
        System.assertEquals(false,responses.get(1).isValid,'Invalid Country Validation for Invalid Country');
        System.assertEquals(3,responses.get(1).noOfRetries,'Invalid number of retries for Invalid Country');
    }
    
        @isTest static void testValidateCountry_EmptyRequests(){
        List<IBot_CountryValidatorCtrl.ValidationRequest> requests = new List<IBot_CountryValidatorCtrl.ValidationRequest>();
        List<IBot_CountryValidatorCtrl.ValidationResponse> responses = IBot_CountryValidatorCtrl.validateCountryName(requests);
		System.assertEquals(0,responses.size(),'Invalid number of responses returned');
    }

}