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
public with sharing class IBot_Utils {
    
    public static Contact buildContactSObject(SObject finAccount) {
        Contact primaryContact = new Contact();
        
        String contactGAUSerId = IBot_ConfigSettings.getInstance().getContactGAUSerIdFieldName();
        String primaryOwnerRelationship = IBot_ConfigSettings.getInstance().getPrimaryOwnerRelationshipName();
        String primaryOwnerContactRelationship = IBot_ConfigSettings.getInstance().getPrimaryOwnerContactRelationshipName();
        IBot_PrintUtils.print('MANI CONTACT : '+finAccount.getSObject(primaryOwnerRelationship).getSObject(primaryOwnerContactRelationship));
        primaryContact.Id = (Id) finAccount.getSObject(primaryOwnerRelationship).getSObject(primaryOwnerContactRelationship).get('Id');
        primaryContact.FirstName = (String) finAccount.getSObject(primaryOwnerRelationship).getSObject(primaryOwnerContactRelationship).get('FirstName');
        primaryContact.MobilePhone = (String) finAccount.getSObject(primaryOwnerRelationship).getSObject(primaryOwnerContactRelationship).get('MobilePhone');
        primaryContact.Email = (String) finAccount.getSObject(primaryOwnerRelationship).getSObject(primaryOwnerContactRelationship).get('Email');
        primaryContact.put(contactGAUSerId, (String) finAccount.getSObject(primaryOwnerRelationship).getSObject(primaryOwnerContactRelationship).get(contactGAUSerId));
        return primaryContact;
    }
    
    public static Integer generateRandomCode(){
        Double random = Math.random() * 1000000;
        return random.intValue();
    }
    
    public static boolean isFSCObjectAvailable(String objType){
        IBot_AccessController fscIBot_AccessController = new IBot_AccessController(objType);
        return fscIBot_AccessController.isSobjectExists(); 
    }
    
    public static sobject populateSobject(String objType, Map<String, object> fieldMap){
        
        SObject obj = IBot_DynamicSObjectCreation.createObject(objType);
        IBot_AccessController fscIBot_AccessController = new IBot_AccessController(objType);
        
        if(fscIBot_AccessController.isAccessible() && fscIBot_AccessController.isCreateable()){
            if(fscIBot_AccessController.isFieldListAccessible(new List<String>(fieldMap.keyset())) && fscIBot_AccessController.isFieldListUpdateable(new List<String>(fieldMap.keyset()))){
                for(String field : fieldMap.keyset()){
                    try {
                        IBot_PrintUtils.print('field ' + field);
                        Schema.DisplayType fieldType = fscIBot_AccessController.getFieldDataType(field);
                        IBot_PrintUtils.print('fieldType ' + fieldType);
                        if(fieldType == Schema.DisplayType.CURRENCY || fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.PERCENT){
                            obj.put(field, Double.valueOf(fieldMap.get(field)));
                        } else if(fieldType == Schema.DisplayType.BOOLEAN){
                            obj.put(field, Boolean.valueOf(fieldMap.get(field))); 
                        } else if(fieldType == Schema.DisplayType.DATE){
                            obj.put(field, Date.valueOf(fieldMap.get(field))); 
                        } else if(fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.REFERENCE || fieldType == Schema.DisplayType.TEXTAREA || fieldType == Schema.DisplayType.PICKLIST){
                            obj.put(field, String.valueOf(fieldMap.get(field)));
                        }
                    } catch(Exception ex) {
                        throw new IBot_CustomException('Invalid Type Conversion ' + ex.getMessage());
                    }
                }
            }
        } else if(!fscIBot_AccessController.isAccessible()){
            throw new IBot_CustomException(objType + ' is not accessible');
        }else if(!fscIBot_AccessController.isCreateable()){
            throw new IBot_CustomException(objType + ' is not createable');
        }
          
        return obj;  
    }
    
    public static List<String> getFieldsInObjectInstance(Sobject obj) {
        Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
        fieldMap.remove('attributes');
		return new List<String>(fieldMap.keySet());
    }
    
    public static List<String> getIdValues(List<sObject> objList) {
        List<Id> idsList = new List<Id>();
        for(sObject obj : objList) {
            idsList.add((String)obj.get('Id'));
        }
        
        return idsList;
    }
    
    public static Set<Object> listToSet(List<Object> aList){
        Set<Object> returnValue = null;
        if(aList != null){
            returnValue = new Set<Object>();
            if(aList.size() > 0){
                for(Object value : aList){
                    returnValue.add(value);
                }
            }
        }
        return returnValue;
    }

    /*
     * transform a list of string to soql in list
     */
    public static String createInFilter(List<String> inList) {
        String inStr = '';
        for (String value : inList) {
            inStr += '\'' + String.escapeSingleQuotes(value) + '\',';
        }
        if (String.isNotBlank(inStr)) {
            inStr = inStr.subString(0,inStr.length()-1);
            inStr = '(' + inStr + ')';
        }
        return inStr;
    }

    /*
     * transform a list of string to soql in list
     */
    public static String createInFilter(List<Integer> inList) {
        String inStr = '';
        for (Integer value : inList) {
            inStr += String.escapeSingleQuotes(String.valueOf(value)) + ',';
        }
        if (String.isNotBlank(inStr)) {
            inStr = inStr.subString(0,inStr.length()-1);
            inStr = '(' + inStr + ')';
        }
        return inStr;
    }

    /*
     * Assign permission set to given userId
     */
    public static void assignPermSet(String userName) {
        if(String.isEmpty(userName))
            return;
        
        List<User> users = [Select Id from User where username =: userName];
        if(users.isEmpty())
            return;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'FscBot_Admin_Permset'];
        
        List<PermissionSetAssignment> existingPermissionSet = [Select Id from PermissionSetAssignment where AssigneeId =:users.get(0).id and PermissionSetId =: ps.id];
        
        if(existingPermissionSet.isEmpty()) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = users.get(0).id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }
    }
}