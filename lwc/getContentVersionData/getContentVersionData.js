import { LightningElement, api, wire, track } from 'lwc';
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
export default class DisplayContact extends LightningElement {
    /** Id of record to display. */
   @api recordId; //this captures AccountId which is passed from Parent Component
   @track error;   //this holds errors

   
   @track selectedSourceFileVersionData='';  //this displays selected value of combo box
   @track selectedSourceFileVersionColumns='';
   @track contentSourceColumns = []; 
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
/* Load contentDocuments related to User Stories */
    //@wire(getContentDocumentsFromUsCommits, { userStoryId: '$recordId'})
    @wire(getContentVersionData, { contentVersionId: '0681F000001LI29QAG'})    
    
    wiredSourceContentVersionData({ error, data }) {
        if (data) {
            //console.log(data);
            //this.selectedSourceFileVersionData = [...this.selectedSourceFileVersionData,data.split("---n")];  
            this.selectedSourceFileVersionData= JSON.stringify(data);
            //this.selectedSourceFileVersionData = data;
            //console.log(data[0]);
            //console.log(JSON.stringify(data[0]));
            this.selectedSourceFileVersionColumns= JSON.stringify(data[0]);
            for (let key in data[0]) {
                this.contentSourceColumns = [...this.contentSourceColumns ,{value: key, label: data[0][key]}];    
             }
            //for(var i=0; i<data[0].length; i++) {
                //console.log('id=' + data[0][i]);
            //}
            /*
            for (let key in data) {
                console.log(key);
                console.log(data[key]);
                //this.items.push({value:key, label:data[key]});
                //this.contentDocumentItems = [...this.contentDocumentItems ,{value: key , label: data[key]}];    
             }
             
            for(i=0; i<data.length; i++) {
                console.log('id=' + data[i]);
                this.items = [...this.items ,{value: data[i] , label: data[i]}];                                   
            }  */
            
                         
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.selectedSourceFileVersionData = undefined;
        }
    }
   
    //getter property from statusOptions which return the items array
    get selectedSourceFileVersionData() {
        //console.log(this.contentDocumentItems);
        return this.selectedSourceFileVersionData;
    }
    //getter property from statusOptions which return the items array
    get contentSourceColumns() {
        //console.log(this.contentDocumentItems);
        return this.contentSourceColumns;
    }
    /////populate Target cerion Data /////////////////////
    @track selectedTargetFileVersionData ='';  //this displays selected value of combo box
    @track selectedTargetFileVersionColumns='';
    @track contentTargetColumns = [];
/* Load contentDocuments related to User Stories */
    //@wire(getContentDocumentsFromUsCommits, { userStoryId: '$recordId'})
    @wire(getContentVersionData, { contentVersionId: '0681F000001LP7CQAW'})    
    wiredTargetContentVaersionData({ error, data }) {
        if (data) {
            console.log(data);
            this.selectedTargetFileVersionData = JSON.stringify(data);
            this.selectedTargetFileVersionColumns = JSON.stringify(data[0]);
            for (let key in data[0]) {
                this.contentTargetColumns = [...this.contentTargetColumns ,{value: key, label: data[0][key]}];    
             }

            //this.selectedTargetFileVersionData = [...this.selectedTargetFileVersionData ,data]; 
            //console.log( this.selectedTargetFileVersionData);
            //console.log(data );
			 /*
            for (let key in data) {
                console.log(key);
                console.log(data[key]);
                //this.items.push({value:key, label:data[key]});
                //this.contentDocumentItems = [...this.contentDocumentItems ,{value: key , label: data[key]}];    
             }
            
            for(i=0; i<data.length; i++) {
                console.log('id=' + data[i]);
                this.items = [...this.items ,{value: data[i] , label: data[i]}];                                   
            }  */
            
                        
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.selectedTargetFileVersionData = undefined;
        }
    }
   
    //getter property from statusOptions which return the items array
    get selectedTargetFileVersionData() {
        //console.log(this.contentDocumentItems);
        return this.selectedTargetFileVersionData;
    }
    get contentTargetColumns() {
        //console.log(this.contentDocumentItems);
        return this.contentTargetColumns;
    }
    //end of target data and target columns
    handleSourceKeyChange(event) {
        // Get the string of the "value" attribute on the selected option
        const seletedSourceKey = event.detail.value;
        console.log('selectedOption=' + seletedSourceKey);

        //This is for event propagation
        
        const sourceKeyChangeEvent = new CustomEvent('sourceKeyChangeEvent', {
            detail: { seletedSourceKey },
        });

        
        // Fire the custom event
        this.dispatchEvent(sourceKeyChangeEvent);
    }
    handleTargetKeyChange(event) {
        // Get the string of the "value" attribute on the selected option
        const seletedTargetKey = event.detail.value;
        console.log('selectedOption=' + seletedTargetKey);

        //This is for event propagation
        
        const targetKeyChangeEvent = new CustomEvent('targetKeyChangeEvent', {
            detail: { seletedTargetKey },
        });

        
        // Fire the custom event
        this.dispatchEvent(targetKeyChangeEvent);
    }
    ///Compare buttion click
    
    findDiff(event) {
        //this.clickedButtonLabel = event.target.label;
        //console.log(event.target.label);
        //console.log( event.target.dataset.targetversioncontent);
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
                           
                    statusCell=this.constants.Status.Modified; 
                }
                sourceContSorted.splice(sourceRowIndex, 1);
            }
            else{
                statusCell=this.constants.Status.Added
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
                    this.finalDiffTable.push(sourceRowDeleted);
              }  
         }
         targetCols.unshift('Name');
         targetCols.unshift('Status');
         console.log(this.finalDiffTable); 
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

            let jqTable = $(table).DataTable();
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
}