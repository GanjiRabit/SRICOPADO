import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { reduceErrors } from 'c/ldsUtils';
import {
    subscribe,
    MessageContext
} from 'lightning/messageService';
import ADD_MSG_CHANNEL from '@salesforce/messageChannel/addedMessageChannel__c';
import {
    loadScript,
    loadStyle
} from 'lightning/platformResourceLoader';
import dataTableResource from '@salesforce/resourceUrl/DataTableDemo';
import JqueryResource from '@salesforce/resourceUrl/Jquery331';

export default class drawAddTable_v1 extends LightningElement {
    
    loaded = true;
    scriptLoaded = false;
    
    @wire(MessageContext)
    messageAddContext;

    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        //////console.log('subscribeToMessageChannel:');
        this.subscription = subscribe(
            this.messageAddContext,
            ADD_MSG_CHANNEL,
            (message) => this.handleAddMessage(message)
        );
    }

    // Handler for message received by component
    handleAddMessage(message) {
        const d0 = new Date();
        let time0 = d0.getSeconds();
        const defaultPageSize = [100];
        
        
        const addTable = this.template.querySelector('.tableAddClass');
        try {   
            if (message.rows.length > 0) {
                setTimeout(() => {
                    this.drawAddTable(message.columns, message.rows, [],addTable, defaultPageSize);
                    
                }, 0); 
            } 
            
        } catch (error) {
            this.showNotification(error);
        }
        finally {
        }

    }
    connectedCallback() {
        try {
            this.subscribeToMessageChannel();
            
            if (!this.scriptLoaded) {
                Promise.all([
                    loadScript(this, JqueryResource),
                    loadScript(this, dataTableResource + '/DataTables-1.10.18/media/js/jquery.dataTables.min.js'),
                    loadStyle(this, dataTableResource + '/DataTables-1.10.18/media/css/jquery.dataTables.min.css'),
                ]).then((values) => {
                    this.scriptLoaded = true;
                    //this.intializeModTable();                
                }).catch((exception) => {
                    this.showNotification(exception);
                    this.scriptLoaded = false;
                });
            }

        } catch (error) {
            this.showNotification(error);
        }

    }

    showNotification(error) {
        //////console.log('this.error:', this.error);
        try {
            const evt = new ShowToastEvent({
                title: 'Unexpected Error' + error.stack,
                message: error,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            console.log('drawJqTable:', error.stack, error.message, error);
        } catch (error) {
            console.log('error:', error);
        }

    }
    drawAddTable(columns, rows, modifiedDataMap, table, defaultPageSize) {//making columns with default values so that be optional while called for reDraw
        ////console.log('drawJQTable: drawAddTable - modifiedDataMap', modifiedDataMap);
        ////console.log('drawJQTable: drawAddTable - table', table);
        ////console.log('drawJQTable: drawAddTable - finalDiffTable', rows);
        const d2 = new Date();
        let time2 = d2.getSeconds();
        let jqTable;
        //////console.log('finalDiffTable:', finalDiffTable.length);
        try {
            //initialize - configurations options and header 
            jqTable = this.intializeAddTable(table, columns, defaultPageSize);
            //draw dataTable of the jQueryTable i.e. tBody with  Data Rows to populate
            jqTable.rows.add(rows);
            jqTable.draw();
            //this.template.querySelector('.dataTables_filter').style.display = 'none';
            this.loaded = true;
            //setTimeout(() => {
                //this.bindRowClick(jqTable,modifiedDataMap);
            //}, 0);
            this.loaded = true;
        } catch (error) {
            this.showNotification(error);
        } finally {
            this.loaded = true;
            let time3 = new Date().getSeconds();
            if (time3 < time2) time3 = time3 + 60;
            console.log('drawJQTable drawAddTable - time taken to Draw:', time3 - time2);

        };
    }
    intializeAddTable(table, columns, defaultPageSize) {
        //const table = this.template.querySelector('.tableClass');
        let jqDataTable;
        //DataTable Definition block        
        if ($.fn.dataTable.isDataTable($(table))) { //target version hanged
            ////console.log('datatable exists:',jqTable?.rows?.length);                
            jqDataTable = $(table).DataTable();
            jqDataTable.clear();//jqTable becomes all the records of the JQuery data table - a 2D array and not a Html object to apply $ to operate                
        }
        else { //very firdt time load 
            //populate headers with incoming columns 
            //this.table = this.template.querySelector('.tableClass');
            if (columns && Array.isArray(columns) && columns.length > 0) {
                let tableHeaders = '<thead> <tr>';
                columns.forEach(header => {
                    tableHeaders += '<th>' + header + '</th>';
                });
                tableHeaders += '</tr></thead>';
                table.innerHTML = tableHeaders;
            } else {
                //throw new Error('No Header Available to Initialize Data Table- Headers are mandetory while firstTime load');
            }

            jqDataTable = $(table).DataTable(
                {
                    "lengthMenu": [defaultPageSize],
                    "bLengthChange": false,
                    "searching": false,
                    "retrieve": true,
                    "deferRender": true,
                    //"responsive": true,                                                
                }
            );
        }
        return jqDataTable;
    }
}