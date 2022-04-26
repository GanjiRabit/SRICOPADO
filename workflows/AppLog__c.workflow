<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CICD_NotifyOnError</fullName>
        <description>CICD Notify On Error</description>
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
        <template>CICD/CICD_NotifyOnError</template>
    </alerts>
    <rules>
        <fullName>CICD_NotifyOnError</fullName>
        <actions>
            <name>CICD_NotifyOnError</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Release Managers on CICD error</description>
        <formula>LEFT(AppCat__c, 4) = &apos;CICD&apos;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
