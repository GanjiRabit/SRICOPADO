<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_users_when_ReadyToPromote_is_checked_automatically_after_a_PR_is_approved</fullName>
        <description>Notify users when ReadyToPromote is checked automatically after a PR is approved</description>
        <protected>false</protected>
        <recipients>
            <recipient>saivenkatesh.ayyagari@blue5green.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>srujana@blue5green.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Auto_Check_ReadytoPromote</template>
    </alerts>
    <rules>
        <fullName>Verify for Approved PRs</fullName>
        <active>false</active>
        <criteriaItems>
            <field>copado__Pull_Request_Review__c.copado__Review_Action__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
