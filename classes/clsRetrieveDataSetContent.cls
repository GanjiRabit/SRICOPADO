public class clsRetrieveDataSetContent {
	
	public static List<dataSetWithTemplatesWrapper> wrapDataSets {get; set;}
	public class clsRetrieveDataSetContentException extends Exception {}
    //Select DataSet name DropDown: populate data sets when user choose a user Story
    @AuraEnabled(cacheable=true)
    public static Map<string,string> getDataSetsFromUsCommits(string userStoryId)
    {
        system.debug('clsRetrieveDataSetContent getDataSetsFromUsCommits userStoryId' + userStoryId );
        Map<string,string> dataSets;
        if(!String.isEmpty(userStoryId))
        {   
            copado__User_Story_Data_Commit__c[] lstUsDataCommits = [select copado__User_Story__c,copado__Data_Set__c,copado__Data_Set__r.name,copado__Data_Set__r.copado__Data_Template__r.Name,copado__Data_Set__r.copado__Data_Template__r.copado__Main_Object__c  from copado__User_Story_Data_Commit__c where copado__User_Story__c =: userStoryId order by copado__Data_Set__r.copado__Last_Generated_Date__c DESC];
            if(lstUsDataCommits.size()>0)
            {         
                dataSets = new Map<string,string>();
                for(copado__User_Story_Data_Commit__c usDataCommit: lstUsDataCommits)
                {
                    dataSets.put(usDataCommit.copado__Data_Set__c,usDataCommit.copado__Data_Set__r.name);
       
                }
                return dataSets;
                
            }
            else
            {
                throw new clsRetrieveDataSetContentException('No Data Set found for this User Story : Verify User Story Data Commits');
            }
        }
        else
        {
            throw new clsRetrieveDataSetContentException('Please provide a valid User Story reference');
        }
        	//dataSetIds.add('a4h1F000000ScEv');
        
        
    }
    @AuraEnabled(cacheable=true)
    public static List<dataSetWithTemplatesWrapper> getDataSetsFromUs(string userStoryId)
    {
        system.debug('clsRetrieveDataSetContent getDataSetsFromUs userStoryId' + userStoryId );       
        if(!String.isEmpty(userStoryId))
        {   
            copado__User_Story_Data_Commit__c[] lstUsDataCommits = [select copado__User_Story__c,copado__Data_Set__c,copado__Data_Set__r.name,copado__Data_Set__r.copado__Data_Template__r.Name,copado__Data_Set__r.copado__Data_Template__r.copado__Main_Object__c  from copado__User_Story_Data_Commit__c where copado__User_Story__c =: userStoryId];
            if(lstUsDataCommits.size()>0)
            {         
                wrapDataSets = new List<dataSetWithTemplatesWrapper>();
                for(copado__User_Story_Data_Commit__c usDataCommit: lstUsDataCommits)
                {
                    wrapDataSets.add(new dataSetWithTemplatesWrapper(usDataCommit));
       
                }
                system.debug('wrapDataSets: '+wrapDataSets);
                return wrapDataSets;
                
            }
            else
            {
                throw new clsRetrieveDataSetContentException('getDataSetsFromUs No Data Set found for this User Story : Verify User Story Data Commits');
            }
        }
        else
        {
            throw new clsRetrieveDataSetContentException('getDataSetsFromUs Please provide a valid User Story reference');
        }
        	//dataSetIds.add('a4h1F000000ScEv');
        
        
    }
    //Select File name DropDown: populate template Name on selection of Data Set - note: actyualy file title is templateId+templatename+record.csv - so template name is user friendly to display 
    @AuraEnabled(cacheable=true)
    public static map<string,string> getTemplateFromDataSet(string dataSetId)
    {
        Map<string,string> contDocs;
        
        if(!String.isEmpty(dataSetId))
        {   
            ContentDocumentLink[] lstContDocLinks = [SELECT ContentDocumentId,ContentDocument.Title,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility FROM ContentDocumentLink WHERE LinkedEntityId =: dataSetId and ContentDocument.FileType='CSV'];
            //copado__Data_Set__c[] lstdataSets = [select Id,copado__Data_Template__c,copado__Data_Template__r.name from copado__Data_Set__c where Id =: dataSetId];
            if(lstContDocLinks.size()>0)
            {  
                contDocs = new map<string,string>();
                string contDocName;
                for(ContentDocumentLink contDocLink: lstContDocLinks)
                {
                    contDocName = contDocLink.ContentDocument.Title.substringBetween('-', '.records.csv');
                    contDocs.put(contDocLink.ContentDocumentId,contDocName);                    
                }
                
                return contDocs;
                
            }
            else
            {
                throw new clsRetrieveDataSetContentException('No Data Set found for this User Story : Verify User Story Data Commits');
            }
        }
        else
        {
            throw new clsRetrieveDataSetContentException('Please provide a data Set reference');
        }
    }
    //Select File Version DropDown:populate Source & target File Version on selection of File Name/templateName
    @AuraEnabled(cacheable=true)
    public static map<string,string> getContentVersionFromDocument(string contentDocId)
    {
        Map<string,string> contendDocversionData;
        if(!String.isEmpty(contentDocId))
        {   
            //string contentDocTitle = dataTemplateId+'-'+dataTemplateName+'.records.csv';
            ContentVersion[] lstContentDocVersions = [SELECT ContentDocumentId,Title,Id,VersionNumber,LastModifiedBy.Name,LastModifiedDate FROM ContentVersion WHERE ContentDocumentId =:contentDocId order by LastModifiedDate desc];
            if(lstContentDocVersions.size()>0)
            {   
                contendDocversionData = new Map<string,string>();
                for(ContentVersion contDocVersion:lstContentDocVersions)
                {
                    contendDocversionData.put(contDocVersion.Id,contDocVersion.LastModifiedDate.formatLong()+' '+contDocVersion.LastModifiedBy.Name);	
                    //contendDocversionData.put(contDocVersion.VersionData.toString(),contDocVersion.VersionNumber);
                }
                
                return contendDocversionData;
                
            }
            else
            {
                throw new clsRetrieveDataSetContentException('getContentVersionFromDocument: contentDocId='+contentDocId+'No Data Content found for this DataSet : Verify File section in Data Set');
            }
        }
        else
        {
            throw new clsRetrieveDataSetContentException('getContentVersionFromDocument:contentDocId='+contentDocId+' Please provide a data template reference');
        }
    }
    //Select File Version DropDown:populate Source & target File Version on selection of File Name/templateName
    @AuraEnabled(cacheable=true)
    //public static List<List<string>> getContentVersionData(string contentVersionId)
    public static string getContentVersionData(string contentVersionId)
    {
        
        if(!String.isEmpty(contentVersionId))
        {   
            String backlash = '\n';
			String backlashReplacement = '/n';
            //string contentDocTitle = dataTemplateId+'-'+dataTemplateName+'.records.csv';
            ContentVersion[] contentVersion = [SELECT Id,VersionData FROM ContentVersion WHERE Id =:contentVersionId ];
            Blob fileContent = contentVersion[0].VersionData;
            /*
            string contVersionData= fileContent.toString();
            String seperator = ',';
            //last column has always a value of the object name in type column , hence will always end with "\n
            List<string> lstContVersionDataRows = contVersionData.split('"\n');
            List<List<string>> lstContVersionDataRowCols = new List<List<string>>();
            String[]  lstCells; 
            for(string contVersionDataRow:lstContVersionDataRows)
            {
                //lstCells = new List<string>();
                SSSCsvReader bodyAccSR_csvR = new SSSCsvReader(contVersionDataRow, seperator);
                lstCells = bodyAccSR_csvR.readLine();
                
                lstContVersionDataRowCols.add(lstCells);
            }
            //return lstContVersionDataRowCols;
            */
            return EncodingUtil.base64Encode(fileContent);
            	
        }
        else
        {
            throw new clsRetrieveDataSetContentException('getContentVersionData with contentVersionId='+contentVersionId+' Please provide a data template reference');
        }
    }

    public class dataSetWithTemplatesWrapper
    {
        @AuraEnabled
        public id Id{get; set;}
        @AuraEnabled
        public string Name{get; set;}
        @AuraEnabled
        public string dataTemplateName{get; set;}
        @AuraEnabled
        public string dataTemplateObject{get; set;}
        public dataSetWithTemplatesWrapper(copado__User_Story_Data_Commit__c usdc)
        {
            Id=usdc.copado__Data_Set__c;
            Name=usdc.copado__Data_Set__r.name;
            dataTemplateName=usdc.copado__Data_Set__r.copado__Data_Template__r?.Name;
            dataTemplateObject=usdc.copado__Data_Set__r.copado__Data_Template__r?.copado__Main_Object__c;
        }
    }
    @AuraEnabled
    public static string getContentVersionDataTemp(string contentVersionId)
    {
        
        if(!String.isEmpty(contentVersionId))
        {   
            String backlash = '\n';
			String backlashReplacement = '/n';
            //string contentDocTitle = dataTemplateId+'-'+dataTemplateName+'.records.csv';
            ContentVersion[] contentVersion = [SELECT Id,VersionData FROM ContentVersion WHERE Id =:contentVersionId ];
            Blob fileContent = contentVersion[0].VersionData;
            /*
            string contVersionData= fileContent.toString();
            String seperator = ',';
            //last column has always a value of the object name in type column , hence will always end with "\n
            List<string> lstContVersionDataRows = contVersionData.split('"\n');
            List<List<string>> lstContVersionDataRowCols = new List<List<string>>();
            String[]  lstCells; 
            for(string contVersionDataRow:lstContVersionDataRows)
            {
                //lstCells = new List<string>();
                SSSCsvReader bodyAccSR_csvR = new SSSCsvReader(contVersionDataRow, seperator);
                lstCells = bodyAccSR_csvR.readLine();
                
                lstContVersionDataRowCols.add(lstCells);
            }
            return lstContVersionDataRowCols;
            */	
            //return EncodingUtil.base64Encode(fileContent);
            return EncodingUtil.base64Encode(fileContent);
            
        }
        else
        {
            throw new clsRetrieveDataSetContentException('getContentVersionData with contentVersionId='+contentVersionId+' Please provide a data template reference');
        }
    }
}