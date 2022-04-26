public with sharing class FscBot_LiveAgentSetupCtrl {
    
    public static String LA_SKILL_URL='/services/data/v43.0/sobjects/Skill';
    public static String LCD_URL='/services/data/v43.0/sobjects/LiveChatDeployment';
    public static String LCB_URL='/services/data/v43.0/sobjects/LiveChatButton';
    public static String LCUC_URL='/services/data/v43.0/sobjects/LiveChatUserConfig';

    public final String botPermissionSetName = 'sfdc_chatbot_service_permset';
    public final String customBotPermissionSetName = 'fsc_chatbot_service_permset';
    public final String sysAdminBotPermissionSet = 'FscBot_Admin_Permset';
    public final String permissionsAssignmentJson = 'FscBot_StandardObjectPerms';

    public static Response restRes = new Response();
    
    public boolean hasPageMessages {
        get {
            return ApexPages.getMessages().size() > 0;
        }
    }
    
    public String pageMessage {
        get {
            return ApexPages.getMessages().get(0).getDetail();
        }
    }

    public void createFscBotData() {
        IBot_DataUtils.createFscBotData();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.fscbot_bot_data_setup_complete));
        return;
    }

    public void assignBotPermSet() {
        postPackageInstall();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.fscbot_bot_permset_complete));
        return;
    }

    public void revokeBotPermSet() {
        prePackageUnInstall();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.fscbot_permset_assignnment_revoke));
        return;
    }

    public void postPackageInstall() {
        // Assign bot permission set to Bot context user
        List<PermissionSet> botPermissionSets = [Select Id from PermissionSet where Name =: botPermissionSetName];
        List<PermissionSet> customBotPermissionSets = [Select Id from PermissionSet where Name =: customBotPermissionSetName];

        if(!botPermissionSets.isEmpty()) {
            List<PermissionSetAssignment> botPermissionSetAssignments = [Select AssigneeId from PermissionSetAssignment where PermissionSetId =: botPermissionSets.get(0).id];

            if(!botPermissionSetAssignments.isEmpty() && [Select Id from PermissionSetAssignment where AssigneeId =: botPermissionSetAssignments.get(0).AssigneeId and PermissionSetId =: customBotPermissionSets.get(0).id].size() == 0) {
                PermissionSetAssignment botPermissionSetAssignment = new PermissionSetAssignment();
                botPermissionSetAssignment.PermissionSetId = customBotPermissionSets.get(0).id;
                botPermissionSetAssignment.AssigneeId = botPermissionSetAssignments.get(0).AssigneeId;
                insert botPermissionSetAssignment;
            }
        }

        //Assign SysAdminBotPermSet to current user
        if([Select id from PermissionSetAssignment where AssigneeId =: UserInfo.getUserId() and PermissionSet.name =: sysAdminBotPermissionSet].size() == 0){
            PermissionSetAssignment sysAdminBotPermSetAssignment = new PermissionSetAssignment();
            sysAdminBotPermSetAssignment.PermissionSetId = [Select Id from PermissionSet where name =: sysAdminBotPermissionSet].id;
            sysAdminBotPermSetAssignment.AssigneeId = UserInfo.getUserId();
            insert sysAdminBotPermSetAssignment;
        }

        //Assign Standard object and related fields access to bot PermissionSet
        FscBot_PermissionUtils.assignObjectAndFieldPermissions(permissionsAssignmentJson,customBotPermissionSets.get(0).id);
    }

    public void prePackageUnInstall() {
        List<PermissionSetAssignment> botPermissionSetAssignments = [Select Id from PermissionSetAssignment where PermissionSet.Name =: customBotPermissionSetName or PermissionSet.Name =: sysAdminBotPermissionSet];

        if(!botPermissionSetAssignments.isEmpty()) 
            delete botPermissionSetAssignments;

    }
    
    public String getSfdcURL() {
        return System.URL.getSalesforceBaseURL().toExternalform();
    }

    public void createLiveAgentSetup() {

        try {
            //create skill
            LA_Skill skill = new LA_Skill();
            String json = System.JSON.serialize(skill);
            HttpRequest request = buildRequest(LA_SKILL_URL, 'POST', 'application/json', json, 'application/json');
            HttpResponse httpRes = sendRequest(request);
            system.debug(httpRes.getBody());
            String jsonString = formatJsonString(httpRes.getBody());
            CallOutResponse r = (CallOutResponse) System.JSON.deserialize(jsonString,CallOutResponse.class);
            if(String.isNotBlank(r.errorCode)) {
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.fscbot_live_agent_setup_exist));
                return;
            }
            restRes = buildResponse('skill',httpRes);
            String skillId = r.Id;
            
                
            system.debug('restRes ' + httpRes.getStatusCode());
            system.debug('restRes ' +restRes);
            //create Live Chat Deployment
            LiveChatDeployment lcd = new LiveChatDeployment();
            json = System.JSON.serialize(lcd);
            request = buildRequest(LCD_URL, 'POST', 'application/json', json, 'application/json');
            httpRes = sendRequest(request);
            jsonString = formatJsonString(httpRes.getBody());
            r = (CallOutResponse) System.JSON.deserialize(jsonString,CallOutResponse.class);
            if(String.isNotBlank(r.errorCode)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.fscbot_live_agent_setup_exist));
                return;
            }
            restRes = buildResponse('live_chat_deployment',httpRes);
            system.debug('restRes ' +httpRes.getStatusCode());
            system.debug('restRes ' +restRes);

            //create Live Chat button
            LiveChatButton lcb = new LiveChatButton(skillId);
            json = System.JSON.serialize(lcb);
            request = buildRequest(LCB_URL, 'POST', 'application/json', json, 'application/json');
            httpRes = sendRequest(request);
            jsonString = formatJsonString(httpRes.getBody());
            r = (CallOutResponse) System.JSON.deserialize(jsonString,CallOutResponse.class);
            if(String.isNotBlank(r.errorCode)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.fscbot_live_agent_setup_exist));
                return;
            }
            restRes = buildResponse('live_chat_button',httpRes);
            String buttonId = r.Id;
            system.debug('restRes ' +httpRes.getStatusCode());
            system.debug('restRes ' +restRes);

            //create Live Chat User Config
            LiveChatUserConfig lcuc = new LiveChatUserConfig(skillId,buttonId);
            json = System.JSON.serialize(lcuc);
            request = buildRequest(LCUC_URL, 'POST', 'application/json', json, 'application/json');
            httpRes = sendRequest(request);
            jsonString = formatJsonString(httpRes.getBody());
            r = (CallOutResponse) System.JSON.deserialize(jsonString,CallOutResponse.class);
            if(String.isNotBlank(r.errorCode)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.fscbot_live_agent_setup_exist));
                return;
            }
            restRes = buildResponse('live_chat_userconfig',httpRes);
            system.debug('restRes ' +httpRes.getStatusCode());
            system.debug('restRes ' +restRes);
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.fscbot_live_agent_setup_complete));
            return;

        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            System.debug(ex.getMessage());
            restRes.exceptionMessage = ex.getMessage();
        }
    }
    
    private static String formatJsonString(String jsonString) {
        if(jsonString.startsWith('[') && jsonString.endsWith(']')) {
            jsonString = jsonString.substring(1, jsonString.length()-1);
        }
        return jsonString;
    }
    
    private static HttpRequest buildRequest(String path, String method, String responseFormat, String bodyContent, String bodyContentType) {
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + path);
        request.setMethod(method);
        
        if (bodyContent != null) {
            request.setBody(bodyContent);
            request.setHeader('Content-Type', bodyContentType); 
        }
        
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('ACCEPT', responseFormat);
        
        return request;
    }
      
    private static HttpResponse sendRequest(HttpRequest request) {    
        return new Http().send(request);
    }
    
    private static Response buildResponse(String response_type, HttpResponse httpRes) {
        if(String.isNotBlank(response_type) && response_type.equals('skill')) {
            restRes.create_la_skill_status = httpRes.getStatus();
            restRes.create_la_skill_code = httpRes.getStatusCode();
            restRes.create_la_skill_body = httpRes.getBody();
        }
        if(String.isNotBlank(response_type) && response_type.equals('live_chat_deployment')) {
            restRes.create_lcd_status = httpRes.getStatus();
            restRes.create_lcd_code = httpRes.getStatusCode();
            restRes.create_lcd_body = httpRes.getBody();
        }
        if(String.isNotBlank(response_type) && response_type.equals('live_chat_button')) {
            restRes.create_lcb_status = httpRes.getStatus();
            restRes.create_lcb_code = httpRes.getStatusCode();
            restRes.create_lcb_body = httpRes.getBody();
        }
        if(String.isNotBlank(response_type) && response_type.equals('live_chat_userconfig')) {
            restRes.create_lcuc_status = httpRes.getStatus();
            restRes.create_lcuc_code = httpRes.getStatusCode();
            restRes.create_lcuc_body = httpRes.getBody();
        }
        return restRes;
    }
    
    public class CallOutResponse {
        String id{get;set;}
        Boolean success{get;set;}
        String message{get;set;}
        String errorCode{get;set;}
        String[] errors{get;set;}
        String[] fields{get;set;}
    }
    public class LA_Skill {
        public String DeveloperName{get;set;}
        public String MasterLabel{get;set;}
        public String Language{get;set;}
        public String Description{get;set;}

        public LA_Skill() {
            this.DeveloperName = 'FscBot_Sample_Skill';
            this.MasterLabel = 'FSC Bot Sample Skill1';
            this.Language = 'en_US';
            this.Description = 'Sample skill used by FSC Bot';
        }
    }

    public class LiveChatDeployment {
        public String DeveloperName{get;set;}
        public String MasterLabel{get;set;}
        public String WindowTitle{get;set;}
        public Boolean HasTranscriptSave{get;set;}
        public Boolean OptionsHasPrechatApi{get;set;}
        public Integer ConnectionWarningDuration{get;set;}
        public Integer ConnectionTimeoutDuration{get;set;}

        public LiveChatDeployment() {
            this.DeveloperName = 'FscBot_LiveChatDeployment';
            this.MasterLabel = 'FSC Chat Bot';
            this.WindowTitle = 'FSC Chat Bot';
            this.HasTranscriptSave = true;
            this.OptionsHasPrechatApi = false;
            this.ConnectionWarningDuration = 300;
            this.ConnectionTimeoutDuration = 600;
        }
    }

    public class LiveChatButton {
        public String DeveloperName{get;set;}
        public String MasterLabel{get;set;}
        public String SkillId{get;set;}
        public String WindowLanguage{get;set;}
        public String Type{get;set;}
        public String RoutingType{get;set;}
        public Boolean IsAgentOnlineNeeded{get;set;}
        public Boolean HasQueue{get;set;}
        public Boolean IsActive{get;set;}
        public Boolean OptionsHasChasitorIdleTimeout{get;set;}
        public Boolean OptionsHasInviteAfterAccept{get;set;}
        public Boolean OptionsHasInviteAfterReject{get;set;}
        public Boolean OptionsHasRerouteDeclinedRequest{get;set;}
        public Boolean OptionsIsAutoAccept{get;set;}
        public Boolean OptionsIsInviteAutoRemove{get;set;}
        
        public LiveChatButton(String skillId) {
            this.DeveloperName = 'FscBot_ChatButton';
            this.MasterLabel = 'FSC Chat Button';
            this.SkillId = skillId;
            this.Type = 'Standard';
            this.RoutingType = 'Choice';
            this.WindowLanguage = 'en_US';
            this.IsAgentOnlineNeeded = false;
            this.IsActive = true;
            this.HasQueue = false;
            this.OptionsHasChasitorIdleTimeout = false;
            this.OptionsHasInviteAfterAccept = false;
            this.OptionsHasInviteAfterReject = false;
            this.OptionsHasRerouteDeclinedRequest = false;
            this.OptionsIsAutoAccept = false;
            this.OptionsIsInviteAutoRemove = false;
        }
    }

    public class LiveChatUserConfig {
        public String DeveloperName{get;set;}
        public String MasterLabel{get;set;}
        public Integer Capacity{get;set;}
        public String Language{get;set;}
        public Boolean OptionsHasAgentFileTransfer{get;set;}
        public Boolean OptionsHasAgentSneakPeek{get;set;}
        public Boolean OptionsHasAssistanceFlag{get;set;}
        public Boolean IsAutoAwayOnDecline{get;set;}
        public Boolean OptionsIsAutoAwayOnPushTimeout{get;set;}
        public Boolean OptionsHasChatConferencing{get;set;}
        public Boolean OptionsHasChatMonitoring{get;set;}
        public Boolean OptionsHasChatTransferToAgent{get;set;}
        public Boolean OptionsHasChatTransferToButton{get;set;}
        public Boolean OptionsHasChatTransferToSkill{get;set;}
        public Boolean HasLogoutSound{get;set;}
        public Boolean HasNotifications{get;set;}
        public Boolean HasRequestSound{get;set;}
        public Boolean HasSneakPeek{get;set;}
        public Boolean OptionsHasVisitorBlocking{get;set;}
        public Boolean OptionsHasWhisperMessage{get;set;}
        public String SupervisorDefaultSkillId{get;set;}
        public String SupervisorDefaultButtonId{get;set;}
        
        
        public LiveChatUserConfig(String skillId, String buttonId) {
            this.DeveloperName = 'FscBot_LiveAgentConfig';
            this.MasterLabel = 'FSC Bot Live Chat User Config';
            this.Capacity = 100;
            this.Language = 'en_US';
            this.OptionsHasAgentFileTransfer = true;
            this.OptionsHasAgentSneakPeek = false;
            this.OptionsHasAssistanceFlag = true;
            this.IsAutoAwayOnDecline = true;
            this.OptionsIsAutoAwayOnPushTimeout = true;
            this.OptionsHasChatConferencing = true;
            this.OptionsHasChatMonitoring = true;
            this.OptionsHasChatTransferToAgent = true;
            this.OptionsHasChatTransferToButton = true;
            this.OptionsHasChatTransferToSkill = true;
            this.HasLogoutSound = true;
            this.HasNotifications = true;
            this.HasRequestSound = true;
            this.HasSneakPeek = false;
            this.OptionsHasVisitorBlocking = true;
            this.OptionsHasWhisperMessage = true;
            this.SupervisorDefaultSkillId = skillId;
            this.SupervisorDefaultButtonId = buttonId;
        }

    }
 
    public class Response {
 
        @AuraEnabled
        public Integer create_la_skill_code { get; set; }
        @AuraEnabled
        public Integer create_lcd_code { get; set; }
        @AuraEnabled
        public Integer create_lcb_code { get; set; }
        @AuraEnabled
        public Integer create_lcuc_code { get; set; }
        
        @AuraEnabled
        public String create_la_skill_body { get; set; }
        @AuraEnabled
        public String create_lcd_body { get; set; }
        @AuraEnabled
        public String create_lcb_body { get; set; }
        @AuraEnabled
        public String create_lcuc_body { get; set; }

        @AuraEnabled
        public String create_la_skill_status { get; set; }
        @AuraEnabled
        public String create_lcd_status { get; set; }
        @AuraEnabled
        public String create_lcb_status { get; set; }
        @AuraEnabled
        public String create_lcuc_status { get; set; }

        @AuraEnabled
        public String exceptionMessage { get; set; }
    }
}