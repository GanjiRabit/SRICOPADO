/**
 * author            : Debanjan Mukherjee
 * last modified   : 11-20-2021 Debanjan Mukherjee
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   11-20-2021   Debanjan Mukherjee   Initial Version
**/

import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Import message service features required for publishing and the message channel
import {
    publish, subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';

import STATUS_CHANGED_CHANNEL from '@salesforce/messageChannel/filterStatusChangeChannel__c';//publish this
import SOURCE_DATA_CHANGED_CHANNEL from '@salesforce/messageChannel/sourceDataChangeChannel__c';//subscribes this to listen both to source and target data changes 
import TARGET_DATA_CHANGED_CHANNEL from '@salesforce/messageChannel/targetDataChangeChannel__c';//subscribes this to listen both to source and target data changes 

import ALL_MSG_CHANNEL from '@salesforce/messageChannel/dataComparerMsgChannel__c';//publish this
import MOD_MSG_CHANNEL from '@salesforce/messageChannel/modifiedMessageChannel__c';
import ADD_MSG_CHANNEL from '@salesforce/messageChannel/addedMessageChannel__c';
import DEL_MSG_CHANNEL from '@salesforce/messageChannel/deletedMessageChannel__c';

export default class dataComparerEngine_v1 extends LightningElement {
    //decorating with @api to get accessed by the parent to feed source and arget csv data to this engine to compute difference 
    @api titlesLabel;
    sourceVersionId;
    sourceData;
    sourceColumns;
    sourceKeyIndex;
    sourceIndexColumnData;
    sourceKeyIndex;
    sourceIndexName;

    targetVersionId;
    targetData;
    targetColumns;
    targetKeyIndex;
    targetIndexColumnData;
    targetKeyIndex;
    targetIndexName;

    keyFieldOptions;
    selectedKey;
    mainObject;
    idColExistsInSource;

    loaded = true;    
    added=0;modified=0;deleted=0;
    get mainObject() {
        return this.mainObject;
    }
    get listIsNotEmpty() {
        return this.keyFieldOptions && Array.isArray(this.keyFieldOptions) && this.keyFieldOptions.length > 0;
    }

    get selectedKey() {
        return this.selectedKey;
    }
    loadKeyOptionsWithCommonKeys() {
        try {
            let commonColumns = this.sourceColumns.filter(value => (this.targetColumns.includes(value)));
            //console.log('------------this.keyFieldOptions--------------:', commonColumns);
            if(commonColumns?.length>0)
            {
                for (let key in commonColumns) {
                    this.keyFieldOptions = [...this.keyFieldOptions ,{value: key , label:commonColumns[key]}]; 
                }
            }else{
                throw new Error('At least one matcing column should be there in selected source and target data sets');
            }
        } catch (error) {
            this.showNotification(error);
        }
        
        //this.loaded = true;
    }
    handleKeyChange(event) {
        //console.log('dataCompareEngine: handleKeyChange - event.detail'+JSON.stringify(event.detail)); 
        // Get the string of the "value" attribute on the selected option
        if(event.detail.value!= this.selectedKey)
        {
            this.selectedKey = event.detail.value;
            this.sourceKeyIndex = this.sourceColumns.indexOf(this.selectedKey);
            this.targetKeyIndex = this.targetColumns.indexOf(this.selectedKey);
            this.targetData = target.sort((a, b) => a[this.targetKeyIndex] - b[this.targetKeyIndex]);                 
            this.targetIndexColumnData = this.getCol(this.targetData,this.targetKeyIndex);
            this.sourceData = source.sort((a, b) => a[this.sourceKeyIndex] - b[this.sourceKeyIndex]);                 
            this.sourceIndexColumnData = this.getCol(this.sourceData,this.sourceKeyIndex);
        }
        //console.log('selectedKey Index: ', this.selectedKey);      
    }
    
    get keyFieldOptions() {
        return this.keyFieldOptions;
    }
    /////////////////////////// compare//////////////////////////////////////////////

    finalDiffTable;
    constants = {
        Status: {
            Added: "Added",
            Modified: "Modified",
            Deleted: "Deleted",
            NoChange: "NoChange"
        },
        systemKey: "Id",
        systemKeyDisplay: "Name",
        sObjectName: "sObjectName",
        systemBaseURL: '//b5gpartner--dev1.lightning.force.com',
        systemRelativeURL: '<a href="/lightning/r/${sObjectName}/${systemKeyVal}/view">${systemKeyDisplay}</a>'
    };

    compareUtil(){
        try {
            //console.log('started compareUtil:');
            this.loaded = false;
            const d0 = new Date();
            let time0 = d0.getSeconds();
            //let sourceData = [...this.sourceData];//This doesn’t safely copy multi-dimensional arrays. Array/object values are copied by reference instead of by value.
            let sourceData = JSON.parse(JSON.stringify(this.sourceData));//This one safely copies deeply nested objects/arrays!
            //same sourceData to be used even if we change the compareTo i.e. target version - so we will take a local clone and splice to not  get this.sourceData modified 
            let sourceIndexColumnData = [...this.sourceIndexColumnData];//this is also getting spliced to be synched with the current sourceData after each splice
            //console.log('dataCompareEngine : compareUtil - this.sourceData:', this.sourceData);
            //console.log('dataCompareEngine : compareUtil - this.targetData:', this.targetData);           
            
            
            this.finalDiffTable = []; this.modified = 0; this.added = 0; this.deleted = 0;        
            const equals = (a, b) => JSON.stringify(a) === JSON.stringify(b);
            let sourceRow;
            let sourceRowIndex;
            let idCell='';
            let statusCell='';
            let statusStr = '#recStatus#';
            let otherStatus = '<span class="#recStatus#">#recStatus#</span>';
            let modStatus = '<span class="#recStatus#" data-rowKey="#rowKey#">#recStatus#</span>';
            let currentTargetRow;
            let isModified = false;
            let sourceCurrIndex;                      
            let modifiedRowDetails=[];
            //let modifiedDetailsMap = new Map();// it is not iterable after receieving in drawJqTable component
            let modifiedDetailsMap =[];let addRows=[];let modRows=[];let delRows=[];
            for (var i = 1; i < this.targetIndexColumnData.length; i++) {
                idCell = '';
                statusCell = '';
                currentTargetRow = [...this.targetData[i]];
                modifiedRowDetails =[];
                //console.log('dataCompareEngine : compareUtil - currentTargetRow:', currentTargetRow);
                if (this.idColExistsInSource) {                   
                    idCell = '<a href="/lightning/r/Account/' + currentTargetRow[this.targetKeyIndex] + '/view">' + currentTargetRow[this.targetIndexName] + '</a>';                    
                }
                //if template changed to exclude name column or Id column in either of the version then keep blank for those rows           
                
                sourceRowIndex = sourceIndexColumnData.indexOf(this.targetIndexColumnData[i]);
                //console.log('--------------sourceRowIndex>-1 ------------',sourceRowIndex);
                if (sourceRowIndex > -1) {//match found - eiter a noChange or a Modified Case 
                    isModified = false;
                    sourceRow = sourceData.splice(sourceRowIndex, 1).flat(); 
                    //console.log('dataCompareEngine : compareUtil - sourceRow:', sourceRow);
                    //will do a initial level of row check of json string-it will also yield false if column order changed - will be handled in else section
                    if (equals(sourceRow, currentTargetRow)) {
                        statusCell = this.constants.Status.NoChange;
                        currentTargetRow.unshift(idCell);
                        currentTargetRow.unshift(statusCell);
                        //console.log('--------------this.constants.Status.NoChange ------------');
                    }
                    else {                    
                        for (var k = 0; k < currentTargetRow.length; k++) {
                            sourceCurrIndex = this.sourceColumns.indexOf(this.targetColumns[k]);
                            if (currentTargetRow[k] !== sourceRow[sourceCurrIndex]) {
                                currentTargetRow[k] = '<span class="tooltip"><span>' + currentTargetRow[k] + '</span> <span class="tooltiptext">' + sourceRow[sourceCurrIndex] + '</span> </span>';
                                //currentTargetRow[k] = '<span class="tooltip">' + currentTargetRow[k] + '</span>';
                                //if (this.sourceIndexName == k && sourceRow[k] != currentTargetRow[targetColIndex]) {
                                //    idCell = '<span class="tooltip" data-oldValue=' + sourceRow[k] + '><span>' + idCell + '</span> <span class="tooltiptext">' + sourceRow[k] + '</span> </span>';
                                //}
                                isModified = true;//further check whether a change in a column of a row is identified , else No Change - helpful in column addition in template case
                            }
                            modifiedRowDetails.push([this.targetColumns[k],currentTargetRow[k],sourceRow[sourceCurrIndex]]);
                        }
                        if (isModified) {
                            //statusCell = '<span class="modified" data-id='+currentTargetRow[this.targetKeyIndex]+'>' + this.constants.Status.Modified + '</span>';
                            statusCell = modStatus.replaceAll(statusStr,this.constants.Status.Modified).replace('#rowKey#',this.targetIndexColumnData[i]);
                            
                            this.modified = this.modified + 1;
                            //modifiedDetailsMap.set(this.targetIndexColumnData[i],modifiedDetails]);
                            modifiedDetailsMap.push([this.targetIndexColumnData[i],modifiedRowDetails]);
                            currentTargetRow.unshift(idCell);
                            currentTargetRow.unshift(statusCell);
                            modRows.push(currentTargetRow);
                        }
                        else
                        {
                            statusCell = this.constants.Status.NoChange;
                            currentTargetRow.unshift(idCell);
                            currentTargetRow.unshift(statusCell);
                        }
                    }
                    sourceIndexColumnData.splice(sourceRowIndex, 1);
                }
                else {
                    statusCell = otherStatus.replaceAll(statusStr,this.constants.Status.Added);
                    //statusCell = '<span class="added">' + this.constants.Status.Added + '</span>';
                    this.added = this.added + 1;
                    currentTargetRow.unshift(idCell);
                    currentTargetRow.unshift(statusCell);
                    addRows.push(currentTargetRow);

                    //console.log('this.added:');
                }
                
                this.finalDiffTable.push(currentTargetRow);
            }
            if (sourceIndexColumnData.length > 0) {
                let sourceRowDeleted;
                //this.finalDiffTable = [...targetContSorted];
                
                for (var j = 0; j < sourceData.length; j++) {
                    sourceRowDeleted = JSON.parse(JSON.stringify(sourceData[j]));
                    //console.log('sourceRowDeleted[this.sourceIndexName:', sourceRowDeleted,this.sourceIndexName);
                    if (this.idColExistsInSource) {
                            sourceRowDeleted.unshift('<a href="/lightning/r/Account/' + sourceRowDeleted[this.sourceKeyIndex] + '/view">' + sourceRowDeleted[this.sourceIndexName] + '</a>');
                        }
                    else{
                        sourceRowDeleted.unshift('');
                    }
                    sourceRowDeleted.unshift(otherStatus.replaceAll(statusStr,this.constants.Status.Deleted));
                    //sourceRowDeleted.unshift('<span class="deleted">' + this.constants.Status.Deleted + '</span>');
                    this.deleted = this.deleted + 1;
                    //console.log('this.deleted:');
                    this.finalDiffTable.push(sourceRowDeleted);  
                    delRows.push(sourceRowDeleted);
                }
            }
            this.targetColumns.unshift('Name'); 
            this.targetColumns.unshift('Status');
            const d1 = new Date();
            
            //console.log('Time now before sending the data:',time1);
            //console.log('dataCompareEngine : compareUtil -this.finalDiffTable:', this.finalDiffTable);
            //console.log('dataCompareEngine : compareUtil -modifiedDetailsMap:', modifiedDetailsMap);
            //setTimeout(() => {this.publishAllData(this.targetColumns, this.finalDiffTable,modifiedDetailsMap,addRows,modRows,delRows);}, 0);  
            this.publishAllData(this.targetColumns, this.finalDiffTable,modifiedDetailsMap,addRows,modRows,delRows);           
            setTimeout(() => {this.publishDelData(this.targetColumns, delRows);}, 0);            
            setTimeout(() => {this.publishAddData(this.targetColumns, addRows);}, 0);            
            this.publishModData(this.targetColumns, modRows,modifiedDetailsMap);
            //setTimeout(() => { if I do this then UI does not render ????? however after receiving if I apply setTimeOut then tab reders asyncg
            
            //this.publishDelData(this.targetColumns, delRows);
            //this.publishAddData(this.targetColumns, addRows);
            let time1 = d1.getSeconds();
            if(time1<time0)time1=time1+60;
            console.log('Time taken to compare time1-time0:', time1-time0);
            this.finalDiffTable=[];   
            modifiedRowDetails=[];
            modifiedDetailsMap=[];             
            this.loaded = true;               
        } catch (error) {
            this.showNotification(error);
        }finally
        {
            
        }
        
        //this.sourceData=[];this.targetData=[];this.sourceColumns=[];this.targetColumns=[];this.sourceIndexColumnData=[];this.targetIndexColumnData=[];
    }
    @wire(MessageContext)
    allMessageContext;  
    // Respond to UI event by publishing message
    publishAllData(cols , records,modifiedDetailsMap,addRows,modRows,delRows) {
        //console.log('dataComparerEngine : publishDataDiff  In' );
        try {
            const payload = { columns: cols,rows:records,modDetails:modifiedDetailsMap,addRows:addRows,modRows:modRows,delRows:delRows};
            //console.log('dataComparerEngine : publishDataDiff publishing' );
            
            publish(this.allMessageContext, ALL_MSG_CHANNEL, payload);
        } catch (error) {
            this.showNotification(error);
        }
        
    }
    @wire(MessageContext)
    modMessageContext;  
    // Respond to UI event by publishing message
    publishModData(cols ,records, modifiedDetailsMap) {
        //console.log('dataComparerEngine : publishDataDiff  In' );
        try {
            const payload = { columns: cols,rows:records,modDetails:modifiedDetailsMap};
            //console.log('dataComparerEngine : publishDataDiff publishing' );
            
            publish(this.modMessageContext, MOD_MSG_CHANNEL, payload);
        } catch (error) {
            this.showNotification(error);
        }
        
    }
    @wire(MessageContext)
    addMessageContext;  
    // Respond to UI event by publishing message
    publishAddData(cols ,records, modifiedDetailsMap) {
        //console.log('dataComparerEngine : publishDataDiff  In' );
        try {
            const payload = { columns: cols,rows:records};
            //console.log('dataComparerEngine : publishDataDiff publishing' );
            
            publish(this.addMessageContext, ADD_MSG_CHANNEL, payload);
        } catch (error) {
            this.showNotification(error);
        }
        
    }
    @wire(MessageContext)
    delMessageContext;  
    // Respond to UI event by publishing message
    publishDelData(cols ,records, modifiedDetailsMap) {
        //console.log('dataComparerEngine : publishDataDiff  In' );
        try {
            const payload = { columns: cols,rows:records};
            //console.log('dataComparerEngine : publishDataDiff publishing' );
            
            publish(this.delMessageContext, DEL_MSG_CHANNEL, payload);
        } catch (error) {
            this.showNotification(error);
        }
        
    }
    ///////////////////////////End of  grtVersionData from selected File versions and compare//////////////////////////////////////////////

    
    @wire(MessageContext)
    sourceDataContext;
    @wire(MessageContext)
    targetDataContext; 
    @wire(MessageContext)
    statusMessageContext;   
    // Encapsulate logic for LMS subscribe.
    subscribeToSourceDataChannel() {
        this.subscription = subscribe(
            this.sourceDataContext,
            SOURCE_DATA_CHANGED_CHANNEL,
            (message) => this.handleSourceDataChanged(message)
        );
    }
    subscribeToTargetDataChannel() {
        //console.log('subscribeToMessageChannel:');
        this.subscription = subscribe(
            this.targetDataContext,
            TARGET_DATA_CHANGED_CHANNEL,
            (message) => this.handleTargetDataChanged(message)
        );
    }
    
    // Handler for message received by component
    handleSourceDataChanged(message) {
        let source;
        try {
            if(this.sourceVersionId!=message.versionId)
            {                           
                //console.log('DataCompareEngine : handleSourceDataChanged : message.versionId:', message.versionId,message.selectedData);                
                
                    source = this.processData(this.b64DecodeUnicode(message.selectedData));
                    if (source && Array.isArray(source) && source.length > 1) {
                        this.sourceColumns = source.splice(0, 1).flat();
                        //console.log('dataComplareEngine : handleSourceDataChanged- this.sourceColumns:', this.sourceColumns);
                        //console.log('DataCompareEngine : handleSourceDataChanged : this.sourceColumns:', this.sourceColumns);
                        //this.mainObject = source[0][this.sourceColumns.length - 1];//as we have removed the header columns in above line - now object present in last columnof 0th row
                        //In most of the cases the salesforce id will be present (i.e. selected in the data templates to extract this column data too)
                        //Considering a common scenario will do pre processing and data ready in parallel while user will choose the Target coumn - Later the option will be there for user to choose external id to compare if present in both source file and target file 
                        this.sourceKeyIndex = this.sourceColumns.indexOf('Id');
                        if(this.sourceKeyIndex>-1)
                        {       
                            this.sourceData = source.sort((a, b) => a[this.sourceKeyIndex] - b[this.sourceKeyIndex]);                                             
                            this.sourceIndexColumnData = this.getCol(this.sourceData,this.sourceKeyIndex); 
                            this.sourceIndexName = this.sourceColumns.indexOf('Name')===-1?this.sourceKeyIndex:this.sourceColumns.indexOf('Name');
                        }else{
                            this.sourceData = source; //If no Id then will be sorted once the target chosen - commpon keys are populated and selected one key by user
                            this.sourceIndexColumnData =[];
                            this.idColExistsInSource=false;
                        }                     
                    } else {
                        this.sourceData = undefined;
                        throw new Error('Latest Source Version does not have any data or the format is corrupted');                        
                    }
                                
            }
        }catch (error) {
            this.showNotification(error);
            return;
        }finally
        {
            source = undefined;
        }
    }
    // Handler for message received by component
    handleTargetDataChanged(message) {
        //console.log('DataCompareEngine : handleTargetDataChanged : message.versionId:', message.versionId,message.selectedData);
        this.loaded = false;
        let target;
        try {
            if(this.targetVersionId!=message.versionId)
            {                
                target = this.processData(this.b64DecodeUnicode(message.selectedData));
                if (target && Array.isArray(target) && target.length > 1) {
                    this.targetColumns = target.splice(0, 1).flat();
                    //console.log('DataCompareEngine : handleTargetDataChanged : this.targetColumns:', this.targetColumns);

                    this.targetKeyIndex = this.targetColumns.indexOf('Id');
                    if(this.targetKeyIndex>-1)
                    {       
                        this.targetData = target.sort((a, b) => a[this.targetKeyIndex] - b[this.targetKeyIndex]);                 
                        this.targetIndexColumnData = this.getCol(this.targetData,this.targetKeyIndex); 
                        this.targetIndexName = this.targetColumns.indexOf('Name')===-1?this.targetKeyIndex:this.targetColumns.indexOf('Name');
                        this.selectedKey = 0;                                        
                    }else{//if Id cloumn is not there in Target then it can not be a common key - all common fields to be loaded by this.loadKeyOptionsWithCommonKeys()
                        this.targetData = target; //If no Id then will be sorted once the target chosen - commpon keys are populated and selected one key by user
                        this.targetIndexColumnData =[];
                        this.keyFieldOptions=[];// common columns will be loaded fresh , removing added Id field in onload 
                        this.selectedKey = undefined;//- user wil choose an key field to compare                            
                    }
                    this.loadKeyOptionsWithCommonKeys();
                } else {
                    this.targetData = undefined;
                    throw new Error('Selected Target Version does not have any data or the format is corrupted');
                }                
            }
            this.loaded = true;
        } catch (error) {
            this.showNotification(error);
            return;
        }finally
        {
            target = undefined;
            //this.loaded = true;
        }
        
    }
    publishStatus(event) {
        this.loaded = false;
        //console.log('dataCompareEngine : publishStatus:',event.target.dataset.status);
        let status = event.target.dataset.status;
        if (status === 'Compare') {
            //console.log('dataCompareEngine : call compare:',status);
            //setTimeout(() => {
                this.compareUtil();
            //}, 0);
        }
        event.preventDefault();
        event.stopPropagation();
        
        const payload = { Status: status };
        //console.log('dataComparerEngine : publishStatus publishing',status );
        publish(this.statusMessageContext, STATUS_CHANGED_CHANNEL, payload);
        this.loaded = true;
    }
    getCol(matrix, col) {
        var column = [];
        for (var i = 0; i < matrix.length; i++) {
            column.push(matrix[i][col]);
        }
        return column;
    }
    showNotification(error) {
            const evt = new ShowToastEvent({
            title: 'Unexpected Error',
            message: error.message,
            variant: 'error',
        });
        this.dispatchEvent(evt);
        console.log('error.stack:', error.stack,error);
    }
    b64DecodeUnicode(str) {
        try {
            // Going backwards: from bytestream, to percent-encoding, to original string.
            return decodeURIComponent(atob(str).split('').map(function(c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));
        } catch (error) {
            //console.log('dataComparerEngine : b64DecodeUnicode - error:', error);
        }
        
    }
    processData(csv) {
        //console.log('dataComparerEngine : processData:',csv);
        try {
            //var allTextLines = csv.split(/\r\n|\n/);
            var allTextLines = csv.split('"\n');
            var lines = [];let data=[];
            for (var i=0; i<allTextLines.length-1; i++) {
                //var data = allTextLines[i].replaceAll(/[,](?![,"])/g).split(',');//will split by comma however  ignore the comma for a compund field i.e. address = "1123,US"
                 data = allTextLines[i].split(/[,](?=[,"])/g);//will split by comma however  ignore the comma for a compund field i.e. address = "1123,US"
                    var tarr = [];
                    for (var j=0; j<data.length-1; j++) {
                        tarr.push(data[j].replaceAll('"',''));
                    }
                    lines.push(tarr);
            }
            this.mainObject = data[data.length-1];//special case for this - as last column always keep the object name - removing the same from the 2D array by looping till data.length-1
            //console.log(lines);
        } catch (error) {
            //console.log('dataComparerEngine : processData error:', error);
        }        
        return lines;
    }
    
    // Standard lifecycle hooks used to sub/unsub to message channel
    connectedCallback() {
        //console.log('connectedCallback :subscribeToMessageChannel:handleMessage');
        this.subscribeToSourceDataChannel();
        this.subscribeToTargetDataChannel();
        this.keyFieldOptions=[];
        this.keyFieldOptions = [...this.keyFieldOptions ,{value: 0 , label: 'Id'}];  
        this.selectedKey = 0;
        this.idColExistsInSource=true;
        
    }
}