@isTest
public class TestIBot_TimebasedOTPAuthenticator{
    
    @isTest static void testIsTimebasedOTPValid() {
        Test.setMock(HttpCalloutMock.class, new IBot_MockGoogleOTPHttpResponseGenerator());
        
        Test.startTest();

        IBot_OOBTimebasedOTPAuthenticator timebasedOTPAuthenticator = new IBot_OOBTimebasedOTPAuthenticator();
        Boolean result = timebasedOTPAuthenticator.isTimebasedOTPValid(1234, UserInfo.getUserId());
        
        System.assertEquals(true, result);

        Test.stopTest();
    }
    
    @isTest static void testIsTimebasedOTPValidWithNullId() {
        Test.setMock(HttpCalloutMock.class, new IBot_MockGoogleOTPHttpResponseGenerator());
        
        Test.startTest();
        IBot_OOBTimebasedOTPAuthenticator timebasedOTPAuthenticator = new IBot_OOBTimebasedOTPAuthenticator();
        Boolean result = timebasedOTPAuthenticator.isTimebasedOTPValid(1234, UserInfo.getUserId());
        
        System.assertEquals(true, result);

        Test.stopTest();
    }

}