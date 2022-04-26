<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>sfcma__BillingReminder_Customer_Notification</fullName>
        <description>Billing Reminder Customer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>sfcma__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>sfcma__notifications/sfcma__AutoRenewal_Customer_Notification</template>
    </alerts>
    <alerts>
        <fullName>sfcma__CancellationProcessed_Customer_Notification</fullName>
        <description>Cancellation Processed Customer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>sfcma__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>sfcma__notifications/sfcma__Cancel_Confirm_Customer_Notification</template>
    </alerts>
    <alerts>
        <fullName>sfcma__CancellationRefund_Customer_Notification</fullName>
        <description>Cancellation Refund Customer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>sfcma__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>sfcma__notifications/sfcma__Refund_Customer_Notification</template>
    </alerts>
    <alerts>
        <fullName>sfcma__FreeTrialEnding_Customer_Notification</fullName>
        <description>Free Trial Ending Customer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>sfcma__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>sfcma__notifications/sfcma__FreeTrialEnding_Customer_Notification</template>
    </alerts>
    <alerts>
        <fullName>sfcma__FreeTrialEnding_Partner_Notification</fullName>
        <description>Free Trial Ending Partner Notification</description>
        <protected>false</protected>
        <recipients>
            <field>sfcma__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>sfcma__notifications/sfcma__FreeTrialEnding_Partner_Notification</template>
    </alerts>
    <alerts>
        <fullName>sfcma__FreeTrialSignup_Customer_Notification</fullName>
        <description>Free Trial Signup Customer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>sfcma__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>sfcma__notifications/sfcma__Free_Trial_Sign_up_Customer_Notification</template>
    </alerts>
    <alerts>
        <fullName>sfcma__LicenseCountChanged_Customer_Notification</fullName>
        <description>License Count Changed Customer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>sfcma__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>sfcma__notifications/sfcma__License_Changes_Customer_Notification</template>
    </alerts>
    <alerts>
        <fullName>sfcma__PaymentDeclined_Customer_Notification</fullName>
        <description>Payment Declined Customer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>sfcma__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>sfcma__notifications/sfcma__Payment_Declined_Customer_Notification</template>
    </alerts>
    <alerts>
        <fullName>sfcma__PaymentProcessed_Customer_Notification</fullName>
        <description>Payment Processed Customer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>sfcma__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>sfcma__notifications/sfcma__Payment_Confirm_Customer_Notification</template>
    </alerts>
    <alerts>
        <fullName>sfcma__PurchaseConfirmation_Customer_Notification</fullName>
        <description>Purchase Confirmation Customer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>sfcma__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>sfcma__notifications/sfcma__Purchase_Confirm_Customer_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>sfcma__PopulateLicenseAccountName</fullName>
        <description>Populate the License Account Name on the License&apos;s subscription.</description>
        <field>sfcma__LicenseAccountName__c</field>
        <formula>sfcma__License__r.sfLma__Lead__r.Company</formula>
        <name>Populate License Account Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>true</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>sfcma__Populate_Customer_Account_Name</fullName>
        <field>sfcma__Customer__c</field>
        <formula>sfcma__License__r.sfLma__Lead__r.Company</formula>
        <name>Populate Customer Account Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>true</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>sfcma__Customer__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>sfcma__Populate License Fields</fullName>
        <actions>
            <name>sfcma__PopulateLicenseAccountName</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>sfcma__Populate_Customer_Account_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(sfcma__License__c), NOT(ISNULL(sfcma__License__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
