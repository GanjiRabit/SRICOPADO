public with sharing class AccelQConnect extends UIResponse {
    public static list<string> configItems = new List<String>{
        'accelQUserName',
            'accelQPassword',
            'accelQAuthType',
            'accelQAuthValidated',
            'accelQAuthLastValidatedOn',
            'accelQUrl',
            'accelQDefaultProject',
            'accelQDefaultCIJob',
            'accelQDefualtRunTimeAttributes',
            'accelQTenant'
            };
                
                public static Map<string, object> login(
                    string userName,
                    string password,
                    string url
                ) {
                    Map<string, object> response = new Map<string, object>();
                    try {
                        Map<string, string> headerInfo = new Map<string, string>{
                            'cache-control' => 'no-cache',
                                'invalidate-active-tokens' => 'true',
                                'content-type' => 'application/x-www-form-urlencoded'
                                };
                                    
                                    userName = userName == null ? getConfigValue('accelQUserName') : userName;
                        password = password == null ? getConfigValue('accelQPassword') : password;
                        url = url == null ? getConfigValue('accelQUrl') : url;
                        url = url.endsWith('/') ? url.substring(0, url.lastIndexOf('/')) : url;
                        Map<string, string> bodyParams = new Map<string, string>();
                        
                        bodyParams.put('username', userName);
                        
                        bodyParams.put(
                            'password',
                            EncodingUtil.base64Encode(Blob.valueOf(password))
                        );
                        
                        string body = ' ';
                        
                        for (string key : bodyParams.keySet()) {
                            body += key + '=' + bodyParams.get(key) + '&';
                        }
                        
                        response = RestCalloutManager.doRestCallout(
                            url + '/awb/api/aq_global/security/login',
                            headerInfo,
                            'POST',
                            body.trim()
                        );
                    } catch (Exception Ex) {
                        response.put('isSuccess', false);
                        response.put('message', Ex.getMessage());
                        logError('AccelQConnect.login', Ex);
                    }
                    return response;
                }
    
    @AuraEnabled(cacheable=true)
    public static string getConfig() {
        string response;
        try {
            Map<string, object> responseToReturn = new Map<string, object>();
            
            for (string configItem : configItems) {
                responseToReturn.put(configItem, getConfigValue(configItem));
            }
            
            responseToReturn.put('objectsInfo', getObjectsMetadata());
            response = prepareUIResponse(true, responseToReturn);
        } catch (Exception Ex) {
            response = prepareUIResponse(false, Ex.getMessage());
            logError('AccelQConnect.getConfig', Ex);
        }
        return response;
    }
    
    public static List<Map<string, string>> getObjectsMetadata() {
        List<Map<string, string>> objectsInfo = new List<Map<string, string>>();
        Map<string, schema.sobjecttype> schemaInfo = Schema.getGlobalDescribe();
        set<string> allowedStandardObjects = new Set<String>();
        allowedStandardObjects.add('Account');
        allowedStandardObjects.add('Contact');
        allowedStandardObjects.add('Lead');
        allowedStandardObjects.add('Opportunity');
        
        Schema.DescribeSObjectResult objectInfo;
        
        for (string key : schemaInfo.keySet()) {
            objectInfo = schemaInfo.get(key).getDescribe();
            if (
                (objectInfo.isCustom() &&
                 !objectInfo.isCustomSetting() &&
                 !objectInfo.getName().endsWith('__mdt')) ||
                (allowedStandardObjects.contains(objectInfo.getName()))
            ) {
                objectsInfo.add(
                    (new Map<string, string>{
                        'label' => objectInfo.getLabel(),
                            'value' => objectInfo.getName()
                            })
                );
            }
        }
        
        return objectsInfo;
    }
    
    @AuraEnabled
    public static string saveConfig(string config) {
        string response;
        try {
            Map<string, object> deSerializedConfig = (Map<string, object>) JSON.deserializeUntyped(
                config
            );
            List<CS_IntegrationConfig__c> intConfigList = new List<CS_IntegrationConfig__c>();
            for (string key : configItems) {
                if (deSerializedConfig.get(key) != null) {
                    intConfigList.add(
                        new CS_IntegrationConfig__c(
                            Name = key,
                            Value__c = (string) deSerializedConfig.get(key)
                        )
                    );
                }
            }
            upsert intConfigList Name;
            response = prepareUIResponse(true, true);
        } catch (Exception Ex) {
            response = prepareUIResponse(false, Ex.getMessage());
            logError('AccelQConnect.saveConfig', Ex);
        }
        
        return response;
    }
    
    @AuraEnabled
    public static string verifyCredentials(
        string userName,
        string password,
        string url
    ) {
        return prepareUIResponse(true, login(userName, password, url));
    }
    
    public static string getConfigValue(string configName) {
        string response;
        try {
            response = CS_IntegrationConfig__c.getInstance(configName).Value__c;
        } catch (Exception Ex) {
            //doesnt need to log
        }
        return response;
    }
    
    @AuraEnabled
    public static string createNewJob(string recordId) {
        string response;
        try {
            createJobs(new List<Id>{ recordId }, null);
            response = prepareUIResponse(true, 'New Job Created');
        } catch (Exception Ex) {
            response = prepareUIResponse(false, Ex.getMessage());
        }
        return response;
    }
    
    public static void createJobs(
        List<Id> parentIds,
        List<RunAccelQCIJobWithCustomParams.CIJobRequest> ciJobRequests
    ) {
        try {
            List<CIJob__c> jobsToCreate = new List<CIJob__c>();
            parentIds = parentIds == null ? new List<id>() : parentIds;
            ciJobRequests = ciJobRequests == null
                ? new List<RunAccelQCIJobWithCustomParams.CIJobRequest>()
                : ciJobRequests;
            
            for (id parentId : parentIds) {
                jobsToCreate.add(new CIJob__c(ParentId__c = parentId));
            }
            for (
                RunAccelQCIJobWithCustomParams.CIJobRequest request : ciJobRequests
            ) {
                jobsToCreate.add(
                    new CIJob__c(
                        ParentId__c = request.parentId,
                        AccelQCIJobId__c = request.ciJobId,
                        RunTimeAttributes__c = request.runTimeAttributes
                    )
                );
            }
            
            if (jobsToCreate.size() > 0)
                insert jobsToCreate;
        } catch (Exception Ex) {
            logError('AccelQConnect.createJobs', Ex);
        }
    }
    
    public static Map<string, string> getAccessToken() {
        Map<string, string> tokens = new Map<String, string>();
        try {
            Map<String, object> loginResponse = login(null, null, null);
            
            Map<string, object> loginSessionInfo = (Map<string, object>) JSON.deserializeUntyped(
                (string) loginResponse.get('message')
            );
            
            tokens.put(
                'accessToken',
                String.valueOf(loginSessionInfo.get('access_token'))
            );
            tokens.put(
                'refreshToken',
                String.valueOf(loginSessionInfo.get('refresh_token'))
            );
            tokens.put('clientId', String.valueOf(loginSessionInfo.get('client_id')));
            
            system.debug('>>> tokens ' + tokens);
        } catch (Exception Ex) {
            logError('AccelQConnect.GetAccessToken', Ex);
        }
        return tokens;
    } //end of getAccessToken
    
    public static void initiateJob(
        string apiEndPoint,
        Map<string, string> tokens,
        CIJob__c jobRecord
    ) {
        try {
            string endPointUrl =
                apiEndPoint +
                '/' +
                jobRecord.Project__c +
                '/v1/test-exec/jobs/auto/' +
                jobRecord.AccelQCIJobId__c +
                '/trigger-ci';
            
            string body = jobRecord.RunTimeAttributes__c != null
                ? JSON.serialize(jobRecord.RunTimeAttributes__c)
                : null;
            System.debug('>>> apiEndPoint initiate job' + endPointUrl);
            Map<string, object> jobResponse = RestCalloutManager.doRestCallout(
                endpointUrl,
                prepareHeaders(tokens),
                'PUT',
                body
            );
            system.debug('>>jobResponse ' + jobResponse);
            if ((integer) jobResponse.get('statusCode') == 200) {
                Map<String, objecT> jobInfo = (Map<String, objecT>) JSON.deserializeUntyped(
                    (string) jobResponse.get('message')
                );
                
                jobRecord.CIJobInstanceId__c = string.valueOf(jobInfo.get('pid'));
                update jobRecord;
            } else {
                throw new IntException(string.valueof(jobResponse.get('message')));
            }
        } catch (Exception Ex) {
            logError('AccelQConnect.InitiateJob', Ex);
        }
    }
    
    public static string getEndpoint() {
        string endPoint;
        string baseUrl = AccelQConnect.getConfigValue('accelQUrl');
        baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.lastIndexOf('/'))
            : baseUrl;
        endPoint =
            baseUrl +
            '/awb/api/' +
            AccelQConnect.getConfigValue('accelQTenant');
        return endPoint;
    }
    
    @AuraEnabled
    public static string triggerMonitoringService(string recordId) {
        string response;
        try {
            CIJob__c jobRecord = [
                SELECT
                id,
                Project__c,
                Status__c,
                TotalTestCases__c,
                RunTimeAttributes__c,
                ParentId__c,
                CIJobInstanceId__c,
                AccelQCIJobId__c,
                TestCasesPassed__c,
                TestCasesNotRun__c,
                TestCasesFailed__c
                FROM CIJob__c
                WHERE id = :recordId
            ];
            monitorJob(getEndpoint(), getAccessToken(), jobRecord);
            response = prepareUIResponse(true, 'Job Status Synced');
        } catch (Exception Ex) {
            logError('AccelQ.TriggerMonitoringService', Ex);
            response = prepareUIResponse(false, Ex.getMessage());
        }
        return response;
    }
    
    public static void monitorJob(
        string apiEndPoint,
        Map<string, string> tokens,
        CIJob__c jobRecord
    ) {
        try {
            string endPointUrl =
                apiEndPoint +
                '/' +
                jobRecord.Project__c +
                '/v1/test-exec/runs/auto/' +
                jobRecord.CIJobInstanceId__c +
                '?onlySummary=true';
            
            Map<string, object> jobResponse = RestCalloutManager.doRestCallout(
                endpointUrl,
                prepareHeaders(tokens),
                'GET',
                null
            );
            
            system.debug('>>monitoring job response  ' + jobResponse);
            if ((integer) jobResponse.get('statusCode') == 200) {
                Map<String, objecT> jobSummary = (Map<string, object>) (((Map<String, objecT>) JSON.deserializeUntyped(
                    (string) jobResponse.get('message')
                ))
                                                                        .get('summary'));
                
                jobRecord.Status__c = string.valueOf(jobSummary.get('status'));
                jobRecord.TestCasesPassed__c = getIntegerValue(jobSummary.get('pass'));
                jobRecord.TestCasesFailed__c = getIntegerValue(jobSummary.get('fail'));
                jobRecord.TestCasesNotRun__c = getIntegerValue(
                    jobSummary.get('notRun')
                );
                jobRecord.TotalTestCases__c = getIntegerValue(
                    jobSummary.get('testcaseCount')
                );
                jobRecord.StatusUpdatedOn__c = getDateTime(
                    jobSummary.get('lastUpdatedTimestamp')
                );
                jobRecord.JobCompletedOn__c = getDateTime(
                    jobSummary.get('completedTimestamp')
                );
                jobRecord.JobStartedOn__c = getDateTime(
                    jobSummary.get('startTimestamp')
                );
                
                update jobRecord;
            } else {
                throw new IntException(string.valueof(jobResponse.get('message')));
            }
        } catch (Exception Ex) {
            logError('AccelQConnect.InitiateJob', Ex);
        }
    }
    
    public static dateTime getDateTime(object value) {
        dateTime dateTimeValue;
        try {
            long utcTime = getLongValue(value);
            if (utcTime != null && utcTime > 0) {
                dateTimeValue = datetime.newinstance(utcTime);
            }
        } catch (exception ex) {
            logError('AccelQConnect.convert to datetime', Ex);
        }
        return dateTimeValue;
    }
    
    public static integer getIntegerValue(object value) {
        integer intValue;
        try {
            intValue = Integer.valueOf(value);
        } catch (Exception ex) {
            logError('AccelQConnect.ConvertToInteger', Ex);
        }
        return intValue;
    }
    
    public static long getLongValue(object value) {
        long intValue;
        try {
            if (value != null)
                intValue = long.valueOf(string.valueOf(value));
        } catch (Exception ex) {
            logError('AccelQConnect.ConvertToLong', Ex);
        }
        return intValue;
    }
    
    public static Map<String, string> prepareHeaders(Map<string, string> tokens) {
        tokens = tokens == null ? new Map<String, string>() : tokens;
        Map<string, string> headerInfo = new Map<string, string>();
        headerInfo.put('refresh_token', tokens.get('refreshToken'));
        headerInfo.put('client_id', tokens.get('clientId'));
        headerInfo.put('access_token', tokens.get('accessToken'));
        headerInfo.put('Content-Type', 'application/json');
        headerInfo.put(
            'User-Agent',
            'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36'
        );
        
        return headerInfo;
    }
    
    @AuraEnabled
    public static string saveMapping(
        string configToCreate,
        string configToDelete,
        string selfReference,
        string objectAPIName
    ) {
        string response;
        try {
            List<CS_IntegrationFieldMapping__c> listToCreate = (List<CS_IntegrationFieldMapping__c>) JSON.deserialize(
                configToCreate,
                List<CS_IntegrationFieldMapping__c>.class
            );
            List<CS_IntegrationFieldMapping__c> listToDelete = (List<CS_IntegrationFieldMapping__c>) JSON.deserialize(
                configToDelete,
                List<CS_IntegrationFieldMapping__c>.class
            );
            CS_IntegrationFieldMapping__c self = (CS_IntegrationFieldMapping__c) JSON.deserialize(
                selfReference,
                CS_IntegrationFieldMapping__c.class
            );
            
            if (listToCreate == null)
                listToCreate = new List<CS_IntegrationFieldMapping__c>();
            if (self != null) {
                self.MappingType__c = 'Self';
                listToCreate.add(self);
            }
            
            integer index = 0;
            for (CS_IntegrationFieldMapping__c item : listToCreate) {
                item.SobjectAPIName__c = objectAPIName;
                item.Name = item.SobjectAPIName__c + string.valueof(index);
                item.Id = null;
                index++;
            }
            
            if (listToCreate != null && listToCreate.size() > 0)
                upsert listToCreate Name;
            if (listToDelete != null && listToDelete.size() > 0)
                delete listToDelete;
            response = prepareUIResponse(true, 'Mapping Saved');
        } catch (Exception Ex) {
            response = prepareUIResponse(false, Ex.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static string getFieldMapping(string objectAPIName) {
        string response;
        try {
            Map<String, objecT> resposneToReturn = new Map<string, objecT>();
            resposneToReturn.put(
                'config',
                [
                    SELECT
                    id,
                    FieldAPIName__c,
                    MappingType__c,
                    SourceAPIName__c,
                    SobjectAPIName__c
                    FROM CS_IntegrationFieldMapping__c
                    WHERE SobjectAPIName__c = :objectAPIName AND MappingType__c != 'Self'
                ]
            );
            resposneToReturn.put(
                'selfReference',
                [
                    SELECT
                    id,
                    FieldAPIName__c,
                    MappingType__c,
                    SourceAPIName__c,
                    SobjectAPIName__c
                    FROM CS_IntegrationFieldMapping__c
                    WHERE SobjectAPIName__c = :objectAPIName AND MappingType__c = 'Self'
                ]
            );
            response = prepareUIResponse(true, resposneToReturn);
        } catch (Exception Ex) {
            response = prepareUIResponse(false, Ex.getMessage());
        }
        return response;
    }
}