/**
 * author            : Debanjan Mukherjee
 * last modified   : 11-20-2021 Debanjan Mukherjee
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   11-20-2021   Debanjan Mukherjee   Initial Version
**/

import { LightningElement, api, wire, track } from 'lwc';

import getDataSetsFromUsCommits from '@salesforce/apex/clsRetrieveDataSetContent.getDataSetsFromUsCommits';
import getTemplateFromDataSet from '@salesforce/apex/clsRetrieveDataSetContent.getTemplateFromDataSet';
import getContentVersionFromDocument from '@salesforce/apex/clsRetrieveDataSetContent.getContentVersionFromDocument';
import dataTableResource from '@salesforce/resourceUrl/DataTableDemo';
import JqueryResource from '@salesforce/resourceUrl/Jquery331';
//import dataTableModifiedForLWCResource from '@salesforce/resourceUrl/dataTablesForLwc';
import {
    loadScript,
    loadStyle
} from 'lightning/platformResourceLoader';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import getContentVersionData from '@salesforce/apex/clsRetrieveDataSetContent.getContentVersionData';
let i=0;

export default class DisplayContact extends LightningElement {
     /** Id of record to display. */
    @api recordId; //this captures AccountId which is passed from Parent Component
    @track error;   //this holds errors
    searchKey='';
    /////////////////////////////Select Data Set//////////////////////////////////////////////
    @track dataSetItems = []; //this holds the array for records with value & label

    @track value;  //this displays selected value of combo box    
    @track dataTemplateNames;
    selctedSourceContDocFile;
    selctedTargetContDocFile;
    srcContentDocumentVersions;
    selectedSourceFileVersion;
    
    trgContentDocumentVersions;    
    selectedTargetFileVersion;
    summary='';
    selectedSourceFileVersionData;  //this displays selected value of combo box
    selectedSourceFileVersionColumns;
    contentSourceColumns; 
    selectedTargetFileVersionData;  //this displays selected value of combo box
    selectedTargetFileVersionColumns;
    contentTargetColumns; 

    @wire(getDataSetsFromUsCommits, { userStoryId: 'a2V1F000003IKJXUA4'})    
    wiredDataSets({ error, data }) {
        if (data) {
            
            console.log(data );
            for (let key in data) {
                //console.log(key);
                //console.log(data[key]);
                //this.items.push({value:key, label:data[key]});
                this.dataSetItems = [...this.dataSetItems ,{value: key , label: data[key]}];    
             }
             /*
            for(i=0; i<data.length; i++) {
                console.log('id=' + data[i]);
                this.items = [...this.items ,{value: data[i] , label: data[i]}];                                   
            }  */
            //console.log('hi');
            //console.log('items'+this.items);              
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.dataSetItems = undefined;
        }
    }
   
    //getter property from statusOptions which return the items array
    get dataSetNames() {
        console.log(this.dataSetItems);
        return this.dataSetItems;
    }

    handleDataSetChange(event) { 
        this.searchKey = event.target.value;        
        this.loadTemplates();
    }
    /////////////////////////////End of Select Data Set and event trigger///////////////////////////
    ////////////////////////////getTemplateFromDataSet//////////////////////////////////////////////
    loadTemplates()
    {
        this.dataTemplateNames=[];
        getTemplateFromDataSet({ dataSetId: this.searchKey })
            .then((result) => {
                for (let key in result) {
                    this.dataTemplateNames = [...this.dataTemplateNames ,{value: key , label: result[key]}];    
                 }                 
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.dataTemplateItems = undefined;
                console.log('error:', error);
            });
    }
    //property to bind UI control
    get dataTemplateNames() {
        //console.log(this.dataTemplateItems);
        return this.dataTemplateNames;
    }
    //onClick Event
    handleDataTemplateChange(event) {    
        console.log('handleDataTemplateChange'+event.target.value);    
        this.selctedSourceContDocFile = event.target.value;
        console.log(this.selctedSourceContDocFile);
        this.loadSourceContentVerions();
        this.selctedTargetContDocFile=event.target.value;
        this.loadTargetContentVerions();
    }
    //to bind in the value property of combobox and display selection
    get selctedSourceContDocFile()
    {
        return this.selctedSourceContDocFile;
    }
    get selctedtargetContDocFile()
    {
        return this.selctedtargetContDocFile;
    }
    ////////////////////////////End of getTemplateFromDataSet//////////////////////////////////////////////
    ////////////////////////////get versions of content / file ////////////////////////////////////////////
       
    loadSourceContentVerions()
    {    
        this.srcContentDocumentVersions=[];    
        getContentVersionFromDocument({ contentDocId:this.selctedSourceContDocFile})
            .then((result) => {
                for (let key in result) {
                    this.srcContentDocumentVersions = [...this.srcContentDocumentVersions ,{value: key , label: result[key]}];    
                 }               
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.srcContentDocumentVersions = undefined;
                console.log('error:', error);
            });
    }
    get srcContentDocumentVersions() {
        return this.srcContentDocumentVersions;
    } 
    //Bind onChange Event
    handleContDocVersionChangeSrc(event) {
        this.selectedSourceFileVersion = event.target.value;
        console.log('handleContentDocumentChangeSrc- this.selectedSourceFileVersion'+this.selectedSourceFileVersion);
        this.loadContentVerionDataSrc();
    }
    get selectedSourceFileVersion()
    {
        return this.selectedSourceFileVersion;
    }
    
    //////////////////////////////////end of loading  versions of source document /////////////////
    ///////////////////////////////////////////////////start of populate Sorce File Version Data///////////////
    loadContentVerionDataSrc()
    {
        
        this.contentSourceColumns=[];
        getContentVersionData({ contentVersionId:this.selectedSourceFileVersion})
            .then((data) => {
                this.selectedSourceFileVersionData= JSON.stringify(data);
                this.selectedSourceFileVersionColumns= JSON.stringify(data[0]);
                for (let key in data[0]) {
                    this.contentSourceColumns = [...this.contentSourceColumns ,{value: key, label: data[0][key]}];    
                 }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.contentSourceColumns = undefined;
                console.log('error:', error);
            });
    }
    //getter property from statusOptions which return the items array
    get selectedSourceFileVersionData() {
        //console.log(this.contentDocumentItems);
        return this.selectedSourceFileVersionData;
    }
    get selectedSourceFileVersionColumns(){
        return this.selectedSourceFileVersionColumns;
    }
    
    get contentSourceColumns() {
        //console.log(this.contentDocumentItems);
        return this.contentSourceColumns;
    }
    //end of target data and target columns
    handleSourceKeyChange(event) {
        // Get the string of the "value" attribute on the selected option
        const seletedSourceKey = event.detail.value;        
    }
    ///////////////////////////////////////////////////End of populate Sorce File Version Data///////////////
    ////////////////////////////////// loading  versions of Target document /////////////////
    
    loadTargetContentVerions()
    {    
        this.trgContentDocumentVersions=[];    
        getContentVersionFromDocument({ contentDocId: this.selctedTargetContDocFile })
            .then((result) => {
                for (let key in result) {
                    this.trgContentDocumentVersions = [...this.trgContentDocumentVersions ,{value: key , label: result[key]}];    
                 }               
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.trgContentDocumentVersions = undefined;
                console.log('error:', error);
            });
    }
    get trgContentDocumentVersions() {
        return this.trgContentDocumentVersions;
    }
    handleContDocVersionChangeTrg(event) {
        this.selectedTargetFileVersion = event.target.value;
        console.log('this.selectedTargetFileVersion'+this.selectedTargetFileVersion);
        this.loadContentVerionDataTrg();    
    }
    //to bind in the value property of combobox and display selection
    get selectedTargetFileVersion()
    {
        return this.selectedTargetFileVersion;
    }
   ////////////////////////////////// End of loading  versions of Target document /////////////////
   ///////////////////////////Start of loading Data of selected Target Verion//////////////////////////////
       
    loadContentVerionDataTrg()
    {        
        this.contentTargetColumns=[];
        getContentVersionData({ contentVersionId: this.selectedTargetFileVersion })
            .then((data) => {
                this.selectedTargetFileVersionData = JSON.stringify(data);
                this.selectedTargetFileVersionColumns = JSON.stringify(data[0]);
                for (let key in data[0]) {
                    this.contentTargetColumns = [...this.contentTargetColumns ,{value: key, label: data[0][key]}];    
                }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.contentTargetColumns = undefined;
                console.log('error:', error);
            });
    }
    get selectedTargetFileVersionData() {
        //console.log(this.contentDocumentItems);
        return this.selectedTargetFileVersionData;
    }
    get contentTargetColumns() {
        //console.log(this.contentDocumentItems);
        return this.contentTargetColumns;
    }
    ///////////////////////////End of loading Data of selected Target Verion//////////////////////////////
   /////////////////////////// compare//////////////////////////////////////////////
    
   @api finalDiffTable =[];
   @api constants = {
    Status: {
      Added: "Added",
      Modified: "Modified",
      Deleted: "Deleted",
      NoChange:"NoChange"
    },
    systemKey: "Id",
    systemKeyDisplay: "Name",
    sObjectName:"sObjectName",
    systemBaseURL:'//b5gpartner--dev1.lightning.force.com',
    systemRelativeURL: '<a href="/lightning/r/${sObjectName}/${systemKeyVal}/view">${systemKeyDisplay}</a>'
  };
  
    
    @track summary='';
    @track changes={
        added:0,
        modified:0,
        deleted:0
    };
    
    
    ///Compare buttion click
    
    findDiff(event) {        
        
        let targetCont = JSON.parse(event.target.dataset.targetversioncontent);
        //console.log(targetCont);
        let targetCols = JSON.parse(event.target.dataset.targetversioncolumns);
        //console.log(targetCols);
        //console.log(event.target.dataset.sourceversioncontent);
        let sourceCont = JSON.parse(event.target.dataset.sourceversioncontent);
        //console.log('sourceCont.length:', sourceCont.length);
        
        let sourceCols = JSON.parse(event.target.dataset.sourceversioncolumns);
        //console.log(sourceCols);
        let selectedSourceKey = this.template.querySelector('.clsContentSourceKey').value;
        console.log(selectedSourceKey);
        //let selectedTargetKey = this.template.querySelector('.clsContentTargetKey').value;
        console.log(sourceCols[selectedSourceKey]);
        let selectedTargetKey =targetCols.indexOf(sourceCols[selectedSourceKey]);
        console.log(selectedTargetKey);
        // sort on selected column
        //let sourceContSorted = [...
        let sourceContSorted=sourceCont.sort((a, b) => a[selectedSourceKey] - b[selectedSourceKey]);
        
        
        //console.log('--------------After Sorting Source ------------');
        //console.log(sourceCont);
        //let targetContSorted = [...
        let targetContSorted = targetCont.sort((a, b) => a[selectedTargetKey] - b[selectedTargetKey]);
        this.sourceContSortedTemp = [...sourceContSorted];
        /* use below instead above line if you are using Javascrippt < ES6
        targetCont.sort(function (element_c, element_d) {
             return element_c[selectedTargetKey] - element_d[selectedTargetKey]; 
            }
        );
        */
        //console.log('--------------After Sorting Target ------------');
        //console.log(targetCont);
        const equals = (a, b) => JSON.stringify(a) === JSON.stringify(b);
        let sourceRow;
        let sourceRowIndex;
         //removing headers from source - As not required to be searched and compared 
        sourceContSorted.splice(0,1);
        let idCell;
        let statusCell; 
        let currentTargetRow ;
        
         for(var i=1;i<targetContSorted.length;i++)
         {
            idCell='';
            statusCell=''; 
            currentTargetRow = [...targetContSorted[i]];
            
             //Design URL column : fail safe code if the id or name column has not been selected in any of the version - or template changed later
             if(targetCols.indexOf('Id')>-1)
             {              
                
                 if(targetCols.indexOf('Name')>-1)
                    idCell='<a href="/lightning/r/Account/' + currentTargetRow[targetCols.indexOf('Id')] + '/view">' + currentTargetRow[targetCols.indexOf('Name')]+ '</a>';
                 else
                    idCell='<a href="/lightning/r/Account/' + currentTargetRow[targetCols.indexOf('Id')] + '/view">' + currentTargetRow[targetCols.indexOf('Id')]+ '</a>';
             }   
                //if template changed to exclude name column or Id column in either of the version then keep blank for those rows
             else if(sourceCols.indexOf('Id')>-1)
             {                
                idCell=''
                
             } 
             
            sourceRowIndex  = sourceContSorted.indexOf(sourceContSorted.find(arr => arr.includes(currentTargetRow[selectedTargetKey])));
            
            if(sourceRowIndex>-1)
            {
                
                sourceRow = [...sourceContSorted[sourceRowIndex]];
                
                if(equals(sourceRow,currentTargetRow))
                {
                    statusCell==this.constants.Status.NoChange;
                    
                }
                else{
                    let targetColIndex ;
                    for(var k=0;k<currentTargetRow.length;k++)
                    {
                        targetColIndex = targetCols.indexOf(sourceCols[k]);
                        if(currentTargetRow[targetColIndex] != sourceRow[k])
                        {
                            currentTargetRow[targetColIndex] = '<div class="tooltip" style="background-color:tomato;">'+currentTargetRow[targetColIndex] +' <span class="tooltiptext">'+sourceRow[k]+'</span> </div>';
                            if(sourceCols.indexOf('Name')==k && sourceRow[k]!=currentTargetRow[targetColIndex])
                            {
                                idCell= '<div class="tooltip" style="background-color:tomato;">'+idCell +' <span class="tooltiptext">'+sourceRow[k]+'</span> </div>';
                            }
                        }
                        
                    }   
                           
                    statusCell= '<span class="modified" data-sourceRow = '+sourceRow+'>' +this.constants.Status.Modified+'</span>'; 
                    this.changes.modified = this.changes.modified+1;
                }
                sourceContSorted.splice(sourceRowIndex, 1);
            }
            else{
                statusCell=this.constants.Status.Added;
                this.changes.added = this.changes.added +1;
                //console.log('this.changes.modified:', this.changes.modified);
            }
            currentTargetRow.unshift(idCell);
            currentTargetRow.unshift(statusCell);
            this.finalDiffTable.push(currentTargetRow);
         }
         if(sourceContSorted.length>0)
         {
            let sourceRowDeleted;
            //this.finalDiffTable = [...targetContSorted];
             //console.log('sourceIterator:', sourceIterator);
              for(var j=0;j<sourceContSorted.length;j++)
              {
                    //console.log(sourceContSorted[j]);
                    sourceRowDeleted = [...sourceContSorted[j]];
                
                    //console.log(sorceRowDeleted);
                    //console.log('sorceRowDeleted with status added');
                    
                    //console.log(sorceRowDeleted);
                    //targetContSorted = [...targetContSorted ,sorceRowDeleted]; 
                    //fail safe code if the id or name column has not been selected in any of the version - or template changed later
                    if(sourceCols.indexOf('Id')>-1)
                    {
                        if(sourceCols.indexOf('Name'))
                            sourceRowDeleted.unshift('<a href="/lightning/r/Account/' + sourceRowDeleted[sourceCols.indexOf('Id')] + '/view">' + sourceRowDeleted[sourceCols.indexOf('Name')]+ '</a>');
                        else
                            sourceRowDeleted.unshift('<a href="/lightning/r/Account/' + sourceRowDeleted[sourceCols.indexOf('Id')] + '/view">' + sourceRowDeleted[sourceCols.indexOf('Id')]+ '</a>');
                    }
                    else if(targetCols.indexOf('Id')>-1)
                    {
                        sourceRowDeleted.unshift('');       
                    } 
                    sourceRowDeleted.unshift(this.constants.Status.Deleted);
                    this.changes.deleted = this.changes.deleted+1;
                    this.finalDiffTable.push(sourceRowDeleted);
              }  
         }
         targetCols.unshift('Name');
         targetCols.unshift('Status');
         console.log(this.finalDiffTable); 
         this.summary = 'Summary of Changes -  Number of Rows Added: '+this.changes.added+',  Number of  Rows Modified:'+this.changes.modified+',  Number of Rows Deleted '+this.changes.deleted+'  Please hover highlighted cells or click on modified row to compare';
         this.drawJQTable(targetCols , this.finalDiffTable);
          
    }
    drawJQTable(columns , rows)
    {
        Promise.all([
            loadScript(this, JqueryResource),
            //loadScript(this, dataTableModifiedForLWCResource),
            loadScript(this, dataTableResource + '/DataTables-1.10.18/media/js/jquery.dataTables.min.js'),
            loadStyle(this, dataTableResource + '/DataTables-1.10.18/media/css/jquery.dataTables.min.css'),
        ]).then(() => {
            console.log('script loaded sucessfully');

            const table = this.template.querySelector('.tableClass');
            const columnNames = [...columns];
            let tableHeaders = '<thead> <tr>';
            columnNames.forEach(header => {
                tableHeaders += '<th>' + header + '</th>';
            });
            tableHeaders += '</tr></thead>';
            table.innerHTML = tableHeaders;

            let jqTable = $(table).DataTable(
            );
            $('div.dataTables_filter input').addClass('slds-input');
            $('div.dataTables_filter input').css("marginBottom", "10px");
            
            /*
            this.finalDiffTable.forEach(rec => {
                let tableRows = [];
                for(var i=0;i<rec.length;i++)
                {
                    tableRows.push(rec[i]);
                }
                
                jqTable.row.add(tableRows);
              
            });
            */
            jqTable.rows.add(this.finalDiffTable);
            //jqTable.row.add(rows);
            jqTable.draw();
            //const tbody = this.template.querySelector('.tableClass  > tbody');
            const tbodyOfTable = this.template.querySelector('.tableClass  > tbody');
            $(tbodyOfTable).on('click', 'tr', function () {
                //let htmlRow = jqTable.row(this);
                let row1 = [...jqTable.row(this).data()];
                console.log('row:', row1);
                console.log(row1[0]);
                //console.log('htmlRow:', htmlRow);
               /// console.log([...jqTable.row(this)]);
               //console.log($('#row1.cells[0] .modified').dataset.sourceRow);  
               // console.log($([...jqTable.row(this)] .modified).dataset.sourceRow);
                //console.log(JSON.stringify(this));
                //let currRowIndex = this['_DT_RowIndex'];
                //sourceRowIndex  = sourceContSorted.indexOf(sourceContSorted.find(arr => arr.includes(currentTargetRow[selectedTargetKey])));
                //console.log(json.stringify(this.sourceContSortedTemp));//( 'You clicked on '+data[0]+'\'s row' );
            } );
        }).catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );
        });
       
    }
  ///////////////////////////End of  grtVersionData from selected File versions and compare//////////////////////////////////////////////
  
   get summary() {
        return this.summary;
   }
    get added() {
        return this.changes.added;
    }
    get modified() {
        return this.changes.modified;
   }
    get deleted() {
        return this.changes.deleted;
    }
}