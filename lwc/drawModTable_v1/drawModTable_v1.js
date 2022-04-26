import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { reduceErrors } from 'c/ldsUtils';
import {
    subscribe,
    MessageContext
} from 'lightning/messageService';
//import RECORD_SELECTED_CHANNEL from '@salesforce/messageChannel/dataComparerMsgChannel__c';
import MOD_MSG_CHANNEL from '@salesforce/messageChannel/modifiedMessageChannel__c';
import {
    loadScript,
    loadStyle
} from 'lightning/platformResourceLoader';
import dataTableResource from '@salesforce/resourceUrl/DataTableDemo';
import JqueryResource from '@salesforce/resourceUrl/Jquery331';

export default class drawModTable_v1 extends LightningElement {
    
    loaded = true;
    scriptLoaded = false;
    
    @wire(MessageContext)
    messageModContext;

    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        //////console.log('subscribeToMessageChannel:');
        this.subscription = subscribe(
            this.messageModContext,
            MOD_MSG_CHANNEL,
            (message) => this.handleModMessage(message)
        );
    }

    // Handler for message received by component
    handleModMessage(message) {
        const d0 = new Date();
        let time0 = d0.getSeconds();
        const defaultPageSize = [100];       
        
        const modTable = this.template.querySelector('.tableModClass');
 
        try {   
            if (message.rows.length > 0) { 
                //console.log('drawModTable : handleMessage - ',message.modRows);  
                setTimeout(() => {
                    this.drawModTable(message.columns, message.rows, message.modDetails, modTable, defaultPageSize);  
                }, 0);             
            }
            
        } catch (error) {
            this.showNotification(error);
        }
        finally {
        }

    }


    connectedCallback() {
        //////console.log('connectedCallback :subscribeToMessageChannel:handleMessage');
        try {
            this.subscribeToMessageChannel();
            //All one time work 
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
            console.log('drawJqTable: drawModTable', error.stack, error.message, error);
        } catch (error) {
            console.log('error:', error);
        }

    }
    
    drawModTable(columns, finalDiffTable, modifiedDataMap, table, defaultPageSize) {//making columns with default values so that be optional while called for reDraw
        ////console.log('drawJQTable: drawJQTable - modifiedDataMap', modifiedDataMap);
        const d2 = new Date();
        let time2 = d2.getSeconds();
        let jqTable;
        //////console.log('finalDiffTable:', finalDiffTable.length);
        try {
            //initialize - configurations options and header 
            jqTable = this.intializeModTable(table, columns, defaultPageSize);
            //draw dataTable of the jQueryTable i.e. tBody with  Data Rows to populate
            jqTable.rows.add(finalDiffTable);
            jqTable.draw();
            //this.template.querySelector('.dataTables_filter').style.display = 'none';
            this.loaded = true;
            setTimeout(() => {
                this.bindModDetailRowClick(jqTable, modifiedDataMap);
            }, 0);
            this.loaded = true;
        } catch (error) {
            this.showNotification(error);
        } finally {
            this.loaded = true;
            let time3 = new Date().getSeconds();
            if (time3 < time2) time3 = time3 + 60;
            console.log('drawJQTable drawModTable time taken to Draw:', time3 - time2);

        };
    }
    intializeModTable(table, columns, defaultPageSize) {
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
                    "bInfo":true
                    //"responsive": true,                                                
                }
            );
        }
        return jqDataTable;
    }
    
    bindModDetailRowClick(jqTable, modifiedDataMap) {
        try {
            ////console.log('drawJQTable: bindRowClick - modifiedDataMap', modifiedDataMap);
            var popup = this.template.querySelector('.popuptext');
            let jqModDataTab = this.intializeModDetailsTable(this.template.querySelector('.modTabModDetail'), ['Field', 'New Value', 'Old Value']); //the moment new data comes it return the instance (existing ./ new if not existing) after clearing all data 
            jqModDataTab.draw();//we need to draw the empty table if we load new data to flush of old drawing of last data
            const tbodyOfTable = this.template.querySelector('.tableModClass  > tbody')
            $(tbodyOfTable).off('click');//clear any ther event bounded previously - as we are not destrying rather retriving the same instance this is necessary else old events like the states -i.e. search , selected page remains even while drawing with new data
            $(tbodyOfTable).on('click', 'tr', { modDetails: modifiedDataMap }, function (event) {//if you want to bind only with row having td  with a modified class then apply tr:has(.Modified) selector instead tr
                ////console.log('event.data.modDetails:', event.data.modDetails);
                let targetRowTemp = jqTable.row(this).data();//this gives the index of the row clicked in DataTable
                let dataId = $(targetRowTemp[0]).data("rowkey");
                ////console.log('dataId:', dataId);
                let modRowDetails = dataId ? event.data.modDetails.filter(value => dataId.includes(value[0]))[0][1] : [];//blank array if no dataId as we biund data id only to modified rows                                 
                jqModDataTab.clear().rows.add(modRowDetails).draw(); //here we need to clear again as only this portion will be applicable for onclick so clearing when new data comes does not apply here and if not there the row will doubled in second click event                
                
                //console.log('popup:', $('.popuptext1').html());
                popup.classList.toggle('show');
                event.preventDefault();
                event.stopPropagation();
            });
        }
        catch (error) {
            ////console.log('error:', error);
        }

    }
    intializeModDetailsTable(table, headers) {
        try {
            //let modTab = this.template.querySelector('.modTableClass');
            let modJqDataTable;
            if ($.fn.dataTable.isDataTable($(table))) { //target version hanged
                ////console.log('datatable exists:',jqTable?.rows?.length);                
                modJqDataTable = $(table).DataTable();
                //modJqTable.clear();//jqTable becomes all the records of the JQuery data table - a 2D array and not a Html object to apply $ to operate                
            } else {
                //const defaultPageSize = [10, 20, 30, 40, 50, 100];
                let headerHtm = '<thead><tr><th>#ths#</th></tr></thead>';

                const headersReducer = (previousValue, currentValue) => previousValue + '<th>' + currentValue + '</th>';
                ////console.log(headers.reduce(headersReducer));
                //table.innerHTML = headerHtm.replace('#ths#', headers.reduce(headersReducer));//the last element will left alone for which th tag is already there in headerHtm
                ////console.log('table.innerHTML:', table.innerHTML);
                table.innerHTML = '<thead><tr><th>Field</th><th>New</th><th>Old</th></tr></thead>';        
                modJqDataTable = $(table).DataTable(
                    {
                        //"lengthMenu": defaultPageSize,
                        "bLengthChange": false,
                        "searching": false,
                        "retrieve": true,
                        "deferRender": true,
                        "bInfo":true,
                        "paging":false
                    });
            }
            return modJqDataTable.clear();
        } catch (error) {
            //console.log('error:', error);
        }
    }
}