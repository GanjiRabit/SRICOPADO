/**
 * @description       : 
 * @author            : Debanjan Mukherjee
 * @group             : 
 * @last modified on  : 20-11-2021
 * @last modified by  : Debanjan Mukherjee
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   20-11-2021   Debanjan Mukherjee   Initial Version
**/
public with sharing class SearchController {

	//We can also extend this with a second object in retruning clause and find only related in LWC js or Apex to return parent Child
    @AuraEnabled
    public static List<sObject> search(String objectName, List<String> fields, String searchTerm, String order,string filter,string limits ){
        String searchKeyword = searchTerm + '*';
        String returnPart = '';
        returnPart = objectName+' ( Id, '+String.join(fields,',');
              
        if(filter!=Null) returnPart=returnPart+' '+filter;//filter example : WHERE BillingState IN ('California', 'New York') - should go before the ending first brace of returning
        if(order!=Null) returnPart=returnPart+' '+order;//order example : ORDER BY Name DESC NULLS last
        if(limits!=Null) returnPart=returnPart+' '+limits;//limits example : Limit 20
       	returnPart=returnPart+')';
        String query = 'FIND :searchKeyword IN Name FIELDS RETURNING '+returnPart;        
        
        System.debug(' query '+query);
        List<List<sObject>> searchRecords = Search.Query(Query);
        return searchRecords.get(0);
    }
}