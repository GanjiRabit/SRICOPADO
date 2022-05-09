public with sharing class SaiabelController {
    @AuraEnabled
    public static String getLabel() {
        String s1 = 'Hello from Apex Controller, ' ;
        String s2 = System.Label.SaiLabel;
        return s1 + s2;
        //Test
    }
}