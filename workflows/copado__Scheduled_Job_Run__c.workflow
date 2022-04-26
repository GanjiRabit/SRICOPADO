<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_the_email_alert</fullName>
        <description>Send the email alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>bina.das@blue5green.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Inquiry</template>
    </alerts>
    <alerts>
        <fullName>Send_the_job_alert</fullName>
        <description>Send the job alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>bina.das@blue5green.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Inquiry</template>
    </alerts>
    <rules>
        <fullName>Send an email alert when job is sucess</fullName>
        <actions>
            <name>Send_the_job_alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>TEXT(copado__Status__c)== &apos;Success&apos;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send email alert-Job fails</fullName>
        <actions>
            <name>Send_the_email_alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>TEXT(copado__Status__c) == &apos;Failure&apos;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
