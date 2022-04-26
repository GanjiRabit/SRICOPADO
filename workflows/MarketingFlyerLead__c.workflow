<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Lead_Notification</fullName>
        <description>New Lead Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>balaji.garapati@blue5green.com.partner</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dan@blue5green.com.partner</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Inquiry</template>
    </alerts>
    <rules>
        <fullName>New Inquriey</fullName>
        <actions>
            <name>New_Lead_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Id != null</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
