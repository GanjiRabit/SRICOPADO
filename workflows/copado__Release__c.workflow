<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CICD_NewReleaseCreated</fullName>
        <description>New Release Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>balaji.garapati@blue5green.com.partner</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mouli.bommareddy@blue5green.com.partner</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CICD/CICD_NewRelease</template>
    </alerts>
    <alerts>
        <fullName>CICD_ReleaseDateChanged</fullName>
        <description>Release Date Changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>balaji.garapati@blue5green.com.partner</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mouli.bommareddy@blue5green.com.partner</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CICD/CICD_ReleaseDateChange</template>
    </alerts>
    <alerts>
        <fullName>CICD_UserStoriesReadyForBackDeploy</fullName>
        <description>User Stories are ready for back deploy after release to Prod</description>
        <protected>false</protected>
        <recipients>
            <recipient>balaji.garapati@blue5green.com.partner</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mouli.bommareddy@blue5green.com.partner</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CICD/CICD_UserStoriesReadyForBackDeploy</template>
    </alerts>
    <rules>
        <fullName>CICD_NotifyNewReleaseCreated</fullName>
        <actions>
            <name>CICD_NewReleaseCreated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>1=1</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CICD_NotifyOnReleaseClosed</fullName>
        <actions>
            <name>CICD_UserStoriesReadyForBackDeploy</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifications when release is closed</description>
        <formula>CICD_Released__c = true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CICD_NotifyReleaseDateChange</fullName>
        <actions>
            <name>CICD_ReleaseDateChanged</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( copado__Planned_Date__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
