<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Lead_to_Review_PR_and_approve_destructive_changes_manually</fullName>
        <description>Notify Lead to Review PR and approve destructive changes manually</description>
        <protected>false</protected>
        <recipients>
            <recipient>bina.das@blue5green.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>saivenkatesh.ayyagari@blue5green.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>srujana@blue5green.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Manual_Approval_for_Destructive_Changes</template>
    </alerts>
    <rules>
        <fullName>Manual Approval for Destructive Changes</fullName>
        <actions>
            <name>Notify_Lead_to_Review_PR_and_approve_destructive_changes_manually</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>copado__Quality_Gate__c.copado__Type__c</field>
            <operation>equals</operation>
            <value>Pull Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>copado__Quality_Gate__c.copado__Type__c</field>
            <operation>equals</operation>
            <value>Manual Approval</value>
        </criteriaItems>
        <description>Requires Lead Review and Manual Approval of Destructive Changes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
