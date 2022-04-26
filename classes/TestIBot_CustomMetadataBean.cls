@isTest
private class TestIBot_CustomMetadataBean {
    @isTest static void testBean() {
        Test.startTest();
        
        IBot_CustomMetadataBean bean = new IBot_CustomMetadataBean();
        bean.setMasterLabel('TestMasterLabel');
        bean.setNamespacePrefix('TestNamespacePrefix');
        bean.setValue('TestValue');
        bean.setDeveloperName('TestName');

        System.assertEquals('TestMasterLabel', bean.getMasterLabel());
        System.assertEquals('TestNamespacePrefix', bean.getNamespacePrefix());
        System.assertEquals('TestValue', bean.getValue());
        System.assertEquals('TestName', bean.getDeveloperName());

        Test.stopTest();
    }
}