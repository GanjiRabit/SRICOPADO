@isTest
public class TestFscBot_LiveAgentSetupCtrl{
    public static testmethod void testAcctsAndContactsCallout() {
        TestIBot_SingleRequestMock fakeSkillResp = new TestIBot_SingleRequestMock(200,
                                                         'Complete',
                                                         '{"id": "sForceTest1","success":true,"errors":[]}',
                                                         null);

        TestIBot_SingleRequestMock fakeLCDResp = new TestIBot_SingleRequestMock(200,
                                                  'Complete',
                                                  '{"id": "sForceTest1","success":true,"errors":[]}',
                                                   null);
        TestIBot_SingleRequestMock fakeLCBResp = new TestIBot_SingleRequestMock(200,
                                                  'Complete',
                                                  '{"id": "sForceTest1","success":true,"errors":[]}',
                                                   null);
        TestIBot_SingleRequestMock fakeLCUCResp = new TestIBot_SingleRequestMock(200,
                                                  'Complete',
                                                  '{"id": "sForceTest1","success":true,"errors":[]}',
                                                   null);

        Map<String, HttpCalloutMock> endpoint2TestResp =
                                   new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v43.0/sobjects/Skill',fakeSkillResp);
        endpoint2TestResp.put(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v43.0/sobjects/LiveChatDeployment',fakeLCDResp);
        endpoint2TestResp.put(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v43.0/sobjects/LiveChatButton',fakeLCBResp);
        endpoint2TestResp.put(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v43.0/sobjects/LiveChatUserConfig',fakeLCUCResp);

        TestIBot_MultipleRequestMock multiCalloutMock =
                                   new TestIBot_MultipleRequestMock(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        FscBot_LiveAgentSetupCtrl lasc = new FscBot_LiveAgentSetupCtrl();
        lasc.createLiveAgentSetup();
        FscBot_LiveAgentSetupCtrl.Response response = FscBot_LiveAgentSetupCtrl.restRes;
        system.debug(response);
        System.assertEquals(200, response.create_la_skill_code);
        System.assertEquals('Complete', response.create_la_skill_status);
        System.assertEquals(200, response.create_lcd_code);
        System.assertEquals('Complete', response.create_lcd_status);
        System.assertEquals(200, response.create_lcb_code);
        System.assertEquals('Complete', response.create_lcb_status);
        System.assertEquals(200, response.create_lcuc_code);
        System.assertEquals('Complete', response.create_lcuc_status);
    }
}