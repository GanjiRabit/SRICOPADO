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
 * @description This class is the base config bean which provides some common methods which 
 * every config bean class will inherit by extending this class.
 **/
public with sharing  virtual class IBot_ConfigBeanBase {
    private static Map<String,IBot_CustomMetadataBean> botSettingsMap = new Map<String,IBot_CustomMetadataBean>();
    private static Map<String, Object> cachedSettings = new Map<String, Object>();
    
    private void loadCustomMetadata(){
        if(botSettingsMap.isEmpty()) {
            List<FscBot_Settings__mdt> botsettings = [SELECT MasterLabel,NamespacePrefix,Value__c,DeveloperName  FROM FscBot_Settings__mdt limit 4000];
            for(FscBot_Settings__mdt setting : botsettings) {
                IBot_CustomMetadataBean customMetadataBean = new IBot_CustomMetadataBean();
                customMetadataBean.setMasterLabel(setting.MasterLabel);
                customMetadataBean.setNamespacePrefix(setting.NamespacePrefix);
                customMetadataBean.setValue(setting.Value__c);
                customMetadataBean.setDeveloperName(setting.DeveloperName);
    
                botSettingsMap.put(setting.DeveloperName, customMetadataBean);
            }
        }   
    }
    
    public IBot_ConfigBeanBase() {
        loadCustomMetadata();
    }
	public void addFSCBotSetting(String key, IBot_CustomMetadataBean customMetadataBean) {
		botSettingsMap.put(key, customMetadataBean);	
	}
    
	protected String getStringValue(String settingName, String defaultValue) {
		String settingValue = null;
		if (!cachedSettings.containsKey(settingName)) {
			IBot_CustomMetadataBean configRecord = botSettingsMap.get(settingName);
			if (configRecord != null && configRecord.getValue() != null) {
				settingValue = configRecord.getValue();
			} else {
				settingValue = defaultValue;
			}
			cachedSettings.put(settingName, settingValue);
		} else {
			if (cachedSettings.get(settingName) != null)
				settingValue = (String)cachedSettings.get(settingName);
		}

		return settingValue;
	}

	protected Boolean getBooleanValue(String settingName, Boolean defaultValue) {
		Boolean settingValue = false;
		if (!cachedSettings.containsKey(settingName)) {
			IBot_CustomMetadataBean configRecord = botSettingsMap.get(settingName);
			if (configRecord != null && configRecord.getValue() != null) {
				settingValue = (configRecord.getValue() == 'true');
			} else {
				settingValue = defaultValue;
			}
			cachedSettings.put(settingName, settingValue);
		} else {
			if (cachedSettings.get(settingName) != null)
				settingValue = (Boolean)cachedSettings.get(settingName);
		}
		return settingValue;
	}

	protected Long getLongValue(String settingName, Long defaultValue) {
		Long settingValue = null;
		if (!cachedSettings.containsKey(settingName)) {
			IBot_CustomMetadataBean configRecord = botSettingsMap.get(settingName);
			if (configRecord != null && configRecord.getValue() != null) {
				settingValue = Long.valueOf(configRecord.getValue());
			} else {
				settingValue = defaultValue;
			}
			cachedSettings.put(settingName, settingValue);
		} else {
			if (cachedSettings.get(settingName) != null)
				settingValue = (Long)cachedSettings.get(settingName);
		}
		return settingValue;
	}

	protected Integer getIntegerValue(String settingName, Integer defaultValue) {
		Integer settingValue = null;
		if (!cachedSettings.containsKey(settingName)) {
			IBot_CustomMetadataBean configRecord = botSettingsMap.get(settingName);
			if (configRecord != null && configRecord.getValue() != null) {
				settingValue = Integer.valueOf(configRecord.getValue());
			} else {
				settingValue = defaultValue;
			}
			cachedSettings.put(settingName, settingValue);
		} else {
			if (cachedSettings.get(settingName) != null)
				settingValue = (Integer)cachedSettings.get(settingName);
		}
		return settingValue;
	}
    
    
	protected List<String> getCSVToListValue(String settingName, List<String> defaultValue) {
		List<String> settingValue = null;
		if (!cachedSettings.containsKey(settingName)) {
			IBot_CustomMetadataBean configRecord = botSettingsMap.get(settingName);
			if (configRecord != null && configRecord.getValue() != null) {
				settingValue = configRecord.getValue().split(',');
			} else {
				settingValue = defaultValue;
			}
			cachedSettings.put(settingName, settingValue);
		} else {
			if (cachedSettings.get(settingName) != null)
				settingValue = (List<String>)cachedSettings.get(settingName);
		}
		return settingValue;
	}
}