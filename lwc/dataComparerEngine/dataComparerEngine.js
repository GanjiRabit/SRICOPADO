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
import { publish, MessageContext } from 'lightning/messageService';
import RECORD_SELECTED_CHANNEL from '@salesforce/messageChannel/dataComparerMsgChannel__c';
export default class DataComparerEngine extends LightningElement {
    //decorating with @api to get accessed by the parent to feed source and arget csv data to this engine to compute difference 
    @api titlesLabel;
    @api sourceData;
    sourceColumns;
    @api targetData;
    targetColumns;    
    keyFieldOptions;
    seletedKey;
    mainObject;
    get mainObject()
    {
        return this.mainObject;
    }
    get listIsNotEmpty() {
        return this.keyFieldOptions && Array.isArray(this.keyFieldOptions) && this.keyFieldOptions.length > 0;
    }
    
    get seletedKey()
    {
        return this.seletedKey;
    }
    
    
    @api
    loadCompareEngine()
    {    
        this.keyFieldOptions=[]; this.seletedKey=''; 
        console.log('compareEngine : loadCompareEngine');    
        
        this.sourceColumns= this.sourceData?this.sourceData[0]:undefined;
        this.targetColumns= this.targetData?this.targetData[0]:undefined;
        if(this.sourceColumns?.length>0 && this.targetColumns?.length>0)
            this.loadKeyOptionsWithCommonKeys();
        else
        {
            this.error= 'Please verify whether selected source and target data has any field in header row';
            
            this.showNotification();
            return;
        }
    }
    loadKeyOptionsWithCommonKeys()
    {
          
        for (let key in this.sourceColumns) {
            if(this.targetColumns.indexOf(this.sourceColumns[key])>-1)
            {
                this.keyFieldOptions = [...this.keyFieldOptions ,{value: key , label: this.sourceColumns[key]}];    
            }
        }
        
        console.log('handleTargetVersionSelection : this.keyFieldOptions - '+this.keyFieldOptions);
        if(this.keyFieldOptions?.length<=0)
        {
            this.error= 'At least one matcing column should be there in selected source and target data sets';
            
            this.showNotification();            
            return;
        }
        else{
            
        }
    }
    handleKeyChange(event) {
        console.log('dataCompareEngine: handleKeyChange - event.detail'+JSON.stringify(event.detail)); 
        // Get the string of the "value" attribute on the selected option
        this.seletedKey= event.detail.value;  
        
        //console.log('seletedKey Index: ', this.seletedKey);      
    }
    showNotification() {
        const evt = new ShowToastEvent({
            title: 'No Match column',
            message: this.error,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }
    get keyFieldOptions() {
        return this.keyFieldOptions;
    }    
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
    
    handleCompare(event) {        
        
        //let targetCont = JSON.parse(event.target.dataset.targetversioncontent);
        let targetCont = [...this.targetData];
        //console.log('targetCont.length:', targetCont);
        let targetCols =  [...this.targetData[0]];//JSON.parse(event.target.dataset.targetversioncolumns);
        //console.log(targetCols);
        //console.log(event.target.dataset.sourceversioncontent);
        //let sourceCont = JSON.parse(event.target.dataset.sourceversioncontent);
        let sourceCont = [...this.sourceData];
        console.log('sourceCont.length:', sourceCont.length);
        
        let sourceCols = [...sourceCont[0]];//JSON.parse(event.target.dataset.sourceversioncolumns);
        this.mainObject = targetCont[1][targetCols.length-1];
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
        
        
        console.log('--------------After Sorting Source ------------');
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
        console.log('--------------After Sorting Target ------------');
        //console.log(targetCont);
        const equals = (a, b) => JSON.stringify(a) === JSON.stringify(b);
        let sourceRow;
        let sourceRowIndex;
         //removing headers from source - As not required to be searched and compared 
        sourceContSorted.splice(0,1);
        
        console.log('--------------removed header row ------------');
        let idCell;
        let statusCell; 
        let currentTargetRow ;
        
         for(var i=1;i<targetContSorted.length;i++)
         {
            idCell='';
            statusCell=''; 
            currentTargetRow = [...targetContSorted[i]];
            console.log('--------------currentTargetRow ------------');
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
            console.log('--------------sourceRowIndex>-1 ------------');
            if(sourceRowIndex>-1)
            {
                
                sourceRow = [...sourceContSorted[sourceRowIndex]];
                
                if(equals(sourceRow,currentTargetRow))
                {
                    statusCell==this.constants.Status.NoChange;
                    console.log('--------------this.constants.Status.NoChange ------------');
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
                    console.log('--------------this.changes.modified ------------');
                }
                sourceContSorted.splice(sourceRowIndex, 1);
                console.log('--------------sourceContSorted.splice ------------');
            }
            else{
                statusCell=this.constants.Status.Added;
                this.changes.added = this.changes.added +1;
                console.log('this.changes.added:');
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
                    console.log('this.changes.deleted:');
                    this.finalDiffTable.push(sourceRowDeleted);
                    console.log('finalDiffTable.push(sourceRowDeleted):');
              }  
         }
         targetCols.unshift('Name');
         console.log('unshift(Name)');
         targetCols.unshift('Status');
         console.log(this.finalDiffTable); 
         this.summary = 'Summary of Changes -  Number of Rows Added: '+this.changes.added+',  Number of  Rows Modified:'+this.changes.modified+',  Number of Rows Deleted '+this.changes.deleted+'  Please hover highlighted cells or click on modified row to compare';
         this.publishDiffData(targetCols , this.finalDiffTable,this.changes);
         //this.drawJQTable(targetCols , this.finalDiffTable);
         
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

    //LMS to broadcast compare results
    @wire(MessageContext)
    messageContext;
    
    // Respond to UI event by publishing message
    publishDiffData(cols , records, changes) {
        console.log('dataComparerEngine : publishDataDiff  In' );
        const payload = { columns: cols,rows:records,changes:changes };
        console.log('dataComparerEngine : publishDataDiff publishing' );
        publish(this.messageContext, RECORD_SELECTED_CHANNEL, payload);
    }
}