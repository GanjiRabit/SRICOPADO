<aura:application extends="force:slds">
    <!--c:restFromLWC/>
    <c:getDataSetsFromUsCommits/>
    <c:getTemplateFromDataSet/>
    <c:getContentVersionFromDocument/>
    <c:getContentVersionData/>
    <c:jQueryDataTablesDemo/-->
    <!-- all above combined as tightly coupled in below -->
    <!--c:dataSetDiffChecker/--> 
    <!--component to register base componnet search look up for selecting a data set and then ultimately let select a file version-->
    <!--c:searchComponent/>
    <c:retrieveContentData/-->
    <!--final component registering retreiveContentData and component for data Set compare results - loosely coupled-->
    <!--c:compareDataSet/-->
    <c:compareDataSet_v1/>
   
</aura:application>