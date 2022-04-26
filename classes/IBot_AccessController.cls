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
 * @description access controller which performs the CRUD/FLSchecks
 **/
public with sharing class IBot_AccessController{
    public SObjectType objectType;
    public Schema.DescribeSObjectResult schemaDescribeResult;
    public Map<String,Schema.SObjectField> fieldsMap = new Map<String,Schema.SObjectField>();

    public IBot_AccessController(){
        objectType = null;
        schemaDescribeResult = null;
    } 
    
    public IBot_AccessController(String sobjectApiName) {
        schemaDescribeResult = null;
        objectType = Schema.getGlobalDescribe().get(sobjectApiName);
        if(objectType != null) {
            schemaDescribeResult = objectType.getDescribe();
            if(schemaDescribeResult != null)
                fieldsMap = schemaDescribeResult.fields.getMap();
            }

    }
    
    public  boolean isSobjectExists() {
        boolean isPresent = false;
        if(objectType != null) {
            isPresent = true;
        }
        return isPresent;
    }
    
    public  boolean isAccessible() {
        boolean isAccessible = false;
        if(schemaDescribeResult != null) {
            isAccessible = schemaDescribeResult.isAccessible();
        }
        return isAccessible;
    }

    public  boolean isCreateable() {
        boolean isCreateable = false;
        if(schemaDescribeResult != null) {
            isCreateable = schemaDescribeResult.isCreateable();
        }
        return isCreateable;
    }
    
    public  boolean isUpdateable() {
        boolean isUpdateable = false;
        if(schemaDescribeResult != null) {
            isUpdateable = schemaDescribeResult.isUpdateable();
        }
        return isUpdateable;
    }
    
    public  boolean isDeletable() {
        boolean isDeletable = false;
        if(schemaDescribeResult != null) {
            isDeletable = schemaDescribeResult.isDeletable();
        }
        return isDeletable;
    }

    public boolean isFieldListAccessible(List<String> fieldList) {
        boolean isAccessible = true;
        List<String> listOfInaccessibleFields = new List<String>();
        for(String field : fieldList) {
            if(String.isNotBlank(field) && (field.equalsIgnoreCase('id') || field.equalsIgnoreCase('AccountId'))) {
                continue;
            }
            if(fieldsMap.containsKey(field) && fieldsMap.get(field).getDescribe().isAccessible()) {
                continue;
            } else {
                //add to list to throw exception
                String fieldName = fieldsMap.containsKey(field) == true ? fieldsMap.get(field).getDescribe().getLabel() : field; 
                listOfInaccessibleFields.add(fieldName);
            }
        }
        
        if(!listOfInaccessibleFields.isEmpty()){
            isAccessible = false;
            throw new IBot_CustomException(Label.ibot_field_not_readable + ':' + listOfInaccessibleFields);
        }
        return isAccessible;
    }
    
    public  boolean isFieldListUpdateable(List<String> fieldList) {
        boolean isUpdateable = true;
        List<String> listOfInaccessibleFields = new List<String>();
        for(String field : fieldList) {
            if(String.isNotBlank(field) && (field.equalsIgnoreCase('id') || field.equalsIgnoreCase('AccountId'))) {
                continue;
            }
            if(fieldsMap.containsKey(field) && fieldsMap.get(field).getDescribe().isUpdateable()) {
                continue;
            } else {
                //add to list to throw exception
                String fieldName = fieldsMap.containsKey(field) == true ? fieldsMap.get(field).getDescribe().getLabel() : field; 
                listOfInaccessibleFields.add(fieldName);
            }
        }
        
        if(!listOfInaccessibleFields.isEmpty()){
            isUpdateable = false;
            throw new IBot_CustomException(Label.ibot_field_not_editable + ':' + listOfInaccessibleFields);
        }
        return isUpdateable;
    }   
    
    public Schema.DisplayType getFieldDataType(String fieldName){
        return fieldsMap.get(fieldName).getDescribe().getType();
    }
}