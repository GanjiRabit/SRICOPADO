@isTest
public class TestFscBot_NumberOfDigitsForAccountCheck {

    @isTest
    public static void testFscBot_NumberOfDigitsForAccountCheckEmptyAccount () {
        
        Test.startTest();

        List<FscBot_NumberOfDigitsForAccountCheckCtrl.NoOfDigitsResponse> res =  FscBot_NumberOfDigitsForAccountCheckCtrl.getNumberOfDigitsForAccountCheck();

        Test.stopTest();

        System.assert(res != null);
        System.assertEquals(1, res.size());
        System.assert(res.get(0).noOfDigits == 6);
    }
}