<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>ApexTestSuite</label>
    <protected>false</protected>
    <values>
        <field>CICD_ComponentNameExpression__c</field>
        <value xsi:type="xsd:string">[A-Za-z0-9_]*(?=\.testSuite)</value>
    </values>
    <values>
        <field>CICD_JoinString__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>CICD_ParentNameExpression__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>CICD_RestrictMetadataType__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>CICD_RestrictionMessage__c</field>
        <value xsi:nil="true"/>
    </values>
</CustomMetadata>
