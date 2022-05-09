public with sharing class LabelController2 {
    @AuraEnabled
    public static String getLabel() {
        String s1 = 'Hello from Apex Controller, ' ;
        String s2 = System.Label.MyLabelName2;
        return s1 + s2;
    }
}