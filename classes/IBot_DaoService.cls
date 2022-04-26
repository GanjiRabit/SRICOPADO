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
public with sharing class IBot_DaoService implements IBot_ServiceInterface{
    
    private static IBot_DaoService  botDAOService = new IBot_DaoService ();

    /*
        private constructor to make a singleton instance
     */
    private IBot_DaoService () {
    }

    /*
     * Static method that returns singleton instance.
     */
    public static IBot_DaoService getInstance() {
        return botDAOService;
    }

    public List<SObject> fetchSObject(String query) {
        List<SObject> objList = new List<SObject>();
        objList = Database.query(query);

        return objList;
    }

    public List<SObject> fetchSObject(String objectApiName, List<String> fields, String whereCondition, Integer queryLimit) {
        List<SObject> objList = new List<SObject>();
        IBot_AccessController fscIBot_AccessController = new IBot_AccessController(objectApiName);
        if(fscIBot_AccessController.isAccessible()){
            List<String> fieldsList = new List<String>();
            if(fscIBot_AccessController.isFieldListAccessible(fields)){
                String soql = 'select ' + String.join(fields,',') + ' from ';
                       soql = soql + objectApiName + ' ';
                       soql = String.isNotBlank(whereCondition) ? (soql + whereCondition) : soql;
                       soql = (queryLimit != null) ? soql  + ' limit ' + queryLimit : soql; 
            
                IBot_PrintUtils.print('soql ' + soql);
                objList = Database.query(soql);
            }
            
        }else if(!fscIBot_AccessController.isAccessible()){
            throw new IBot_CustomException(objectApiName + ' '  + Label.ibot_obj_not_readable);
        }

        return objList;
    }

    public List<SObject> createSObject(String objType, List<SObject> records){
        IBot_AccessController fscIBot_AccessController = new IBot_AccessController(objType);
        
        if(fscIBot_AccessController.isAccessible() && fscIBot_AccessController.isCreateable()){
            if(!records.isEmpty()) {
                SObject firstRecord = records.get(0);
                List<String> fieldsList = IBot_Utils.getFieldsInObjectInstance(firstRecord);
                if(fscIBot_AccessController.isFieldListUpdateable(fieldsList)){
                    Database.insert(records, true);
                }
            }           
        }else if(!fscIBot_AccessController.isAccessible()){
            throw new IBot_CustomException(objType +  Label.ibot_obj_not_readable);
        }else {
            throw new IBot_CustomException(objType + Label.ibot_obj_not_createable);
        }
        
        return records;
    }

    public void updateSObject(String objectApiName, List<SObject> records) {
        IBot_AccessController fscIBot_AccessController = new IBot_AccessController(objectApiName);
        
        if(fscIBot_AccessController.isAccessible() && fscIBot_AccessController.isUpdateable()){
            if(!records.isEmpty()) {
                SObject firstRecord = records.get(0);
                List<String> fieldsList = IBot_Utils.getFieldsInObjectInstance(firstRecord);
                if(fscIBot_AccessController.isFieldListUpdateable(fieldsList)){
                    Database.update(records, true);
                }
            }            
        }else if(!fscIBot_AccessController.isAccessible()){
            throw new IBot_CustomException(objectApiName + ' ' +  Label.ibot_obj_not_readable);
        }else if(!fscIBot_AccessController.isUpdateable()){
            throw new IBot_CustomException(objectApiName + ' ' + Label.ibot_obj_not_updateable);
        }  
    }

    public void deleteSObject(String objectApiName, String whereCondition) {
        IBot_AccessController fscIBot_AccessController = new IBot_AccessController(objectApiName);
        
        if(fscIBot_AccessController.isAccessible() && fscIBot_AccessController.isDeletable()){
            String query = 'select Id from ' + objectApiName;
            query = String.isNotBlank(whereCondition) ? query + ' ' + whereCondition : query;
            query = query + ' limit 10000';
            List<SObject> records = Database.query(query);
            if(!records.isEmpty())  {
                Database.delete(records,true);
            }
        }else if(!fscIBot_AccessController.isAccessible()){
            throw new IBot_CustomException(objectApiName + ' ' +  Label.ibot_obj_not_readable);
        }else if(!fscIBot_AccessController.isDeletable()){
            throw new IBot_CustomException(objectApiName + ' ' + Label.ibot_obj_not_deleteable);
        }  
    }
}