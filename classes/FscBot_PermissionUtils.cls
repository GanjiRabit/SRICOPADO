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
 * @description This class provides permission of the fields and object available in json for given PermissionSet
 **/
public with sharing class FscBot_PermissionUtils {

	public static List<FieldLevelPermissions> fieldLevelPermissions {get;set;}
	public static List<ObjectLevelPermissions> objectLevelPermissions {get;set;}
	
	public static void parseJson(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'fieldPermissions') {
						fieldLevelPermissions = arrayOfFieldPermissions(parser);
					} else if (text == 'objectPermissions') {
						objectLevelPermissions = arrayOfObjectPermissions(parser);
					}
				}
			}
		}
	}

	public static void assignObjectAndFieldPermissions(String permissionsAssignmentJson, String permissionSetId) {
		StaticResource sr = [Select body from StaticResource where name =: permissionsAssignmentJson];
		parseJson(sr.body.toString());

		if(!fieldLevelPermissions.isEmpty()) {
			List<FieldPermissions> fieldPemissions = new List<FieldPermissions>();
			for(FieldLevelPermissions flp :  fieldLevelPermissions) {
				FieldPermissions fp = new FieldPermissions();
				fp.ParentId = permissionSetId;
				fp.PermissionsRead = Boolean.valueOf(flp.readable);
				fp.PermissionsEdit = Boolean.valueOf(flp.editable);
				fp.SobjectType = flp.field.split('\\.')[0];
				fp.Field = flp.field;

				fieldPemissions.add(fp);
			}

			if(!fieldPemissions.isEmpty()) {
				Database.SaveResult[] results = Database.insert(fieldPemissions, false);
			}
		}

		if(!objectLevelPermissions.isEmpty()) {
			List<ObjectPermissions> objectPemissions = new List<ObjectPermissions>();
			for(ObjectLevelPermissions olp :  objectLevelPermissions) {
				ObjectPermissions op = new ObjectPermissions();
				op.ParentId = permissionSetId;
				op.PermissionsCreate = Boolean.valueOf(olp.allowCreate);
				op.PermissionsDelete = Boolean.valueOf(olp.allowDelete);
				op.PermissionsEdit = Boolean.valueOf(olp.allowEdit);
				op.PermissionsModifyAllRecords = Boolean.valueOf(olp.modifyAllRecords);
				op.PermissionsRead = Boolean.valueOf(olp.allowRead);
				op.PermissionsViewAllRecords = Boolean.valueOf(olp.viewAllRecords);
				op.SobjectType = olp.objectName;

				objectPemissions.add(op);
			}

			if(!objectPemissions.isEmpty()) {
				Database.SaveResult[] results = Database.insert(objectPemissions, false);
			}
		}
	}
    
    private static List<FieldLevelPermissions> arrayOfFieldPermissions(System.JSONParser p) {
        List<FieldLevelPermissions> res = new List<FieldLevelPermissions>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new FieldLevelPermissions(p));
        }
        return res;
    }

    private static List<ObjectLevelPermissions> arrayOfObjectPermissions(System.JSONParser p) {
        List<ObjectLevelPermissions> res = new List<ObjectLevelPermissions>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ObjectLevelPermissions(p));
        }
        return res;
    }
     
    public class ObjectLevelPermissions {
		public String allowCreate {get;set;} 
		public String allowDelete {get;set;}
		public String allowEdit {get;set;}
		public String allowRead {get;set;}
		public String objectName {get;set;}
		public String modifyAllRecords {get;set;}
		public String viewAllRecords {get;set;}
        
        public ObjectLevelPermissions(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'allowCreate') {
							allowCreate = parser.getText();
						} else if (text == 'allowDelete') {
							allowDelete = parser.getText();
						} else if (text == 'allowEdit') {
							allowEdit = parser.getText();
						} else if (text == 'allowRead') {
							allowRead = parser.getText();
						} else if (text == 'modifyAllRecords') {
							modifyAllRecords = parser.getText();
						} else if (text == 'object') {
							objectName = parser.getText();
						} else if (text == 'viewAllRecords') {
							viewAllRecords = parser.getText();
						}
					}
				}
			}
		}
	}
	
	public class FieldLevelPermissions {
		public String editable {get;set;}
		public String field {get;set;}
		public String readable {get;set;}
        
        public FieldLevelPermissions(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'editable') {
							editable = parser.getText();
						} else if (text == 'field') {
							field = parser.getText();
						} else if (text == 'readable') {
							readable = parser.getText();
						}
					}
				}
			}
		}
	}
}