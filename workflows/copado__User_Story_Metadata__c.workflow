<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Potential_Conflicts</fullName>
        <description>Potential Conflicts</description>
        <protected>false</protected>
        <recipients>
            <recipient>saivenkatesh.ayyagari@blue5green.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/PotentialConflicts</template>
    </alerts>
    <rules>
        <fullName>PotentialConflicts</fullName>
        <actions>
            <name>Potential_Conflicts</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>copado__User_Story_Metadata__c.copado__Status__c</field>
            <operation>equals</operation>
            <value>Potential Conflict</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
