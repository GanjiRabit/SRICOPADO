import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { reduceErrors } from 'c/ldsUtils';
import {
    subscribe,
    MessageContext
} from 'lightning/messageService';
//import RECORD_SELECTED_CHANNEL from '@salesforce/messageChannel/dataComparerMsgChannel__c';
import STATUS_CHANGED_CHANNEL from '@salesforce/messageChannel/filterStatusChangeChannel__c';

import {
    loadScript,
    loadStyle
} from 'lightning/platformResourceLoader';
import dataTableResource from '@salesforce/resourceUrl/DataTableDemo';
import JqueryResource from '@salesforce/resourceUrl/Jquery331';

export default class DrawJqTable_v1 extends LightningElement {
    loaded = true;
    scriptLoaded = false;
    @wire(MessageContext)
    statusMessageContext;
    // Encapsulate logic for LMS subscribe.
    subscribeToStatusChangedChannel() {
        //console.log('subscribeToStatusChangedChannel:');
        this.subscription = subscribe(
            this.statusMessageContext,
            STATUS_CHANGED_CHANNEL,
            (message) => this.handleSatusChanged(message)
        );
    }
    // Handler for message received by component
    handleSatusChanged(message) {
        
        
        //const table = this.template.querySelector('.tableClass');
        //console.log('drawJqtable : handleSatusChanged - message.Status:', message.Status);
        try {            
            const allContainer = this.template.querySelector('.allContainer');//
            const addContainer = this.template.querySelector('.addContainer');//.style.visibility = 'visible'
            const delContainer = this.template.querySelector('.delContainer');
            const modContainer = this.template.querySelector('.modContainer');
            switch (message.Status){
                case  'Compare': {		// when block 1
                    this.loaded = false;
                    allContainer.style.display='block';
                    addContainer.style.display='none';
                    delContainer.style.display='none';
                    modContainer.style.display='none';
                    break;
                }	
                
                case 'Added':{		// when block 2
                    allContainer.style.display='none';
                    addContainer.style.display='block';
                    delContainer.style.display='none';
                    modContainer.style.display='none';
                    break;
                }
                case 'Deleted':{		// when block 3
                    allContainer.style.display='none';
                    addContainer.style.display='none';
                    delContainer.style.display='block';
                    modContainer.style.display='none';
                    break;
                }
                case 'Modified':{		// when block 3
                    allContainer.style.display='none';
                    addContainer.style.display='none';
                    delContainer.style.display='none';
                    modContainer.style.display='block';
                    break;
                }	
                default:{		  // default block, optional
                    allContainer.style.display='block';
                    addContainer.style.display='none';
                    delContainer.style.display='none';
                    modContainer.style.display='none';
                    break;
                }
            }
            //$(table).DataTable().columns(0).search(message.Status).draw();
            
        } catch (error) {
            this.showNotification(error);
            console.log('drawJqTable : error:', error);
            console.log('drawJqTable : error stack:', error.stack);
            console.log('drawJqTable : error stack:', error.message);
        } finally {
            this.loaded = true;

        }

    }
    // Standard lifecycle hooks used to sub/unsub to message channel
    connectedCallback() {
        //console.log('connectedCallback :subscribeToMessageChannel:handleMessage');
        try {
            //this.subscribeToMessageChannel();
            this.subscribeToStatusChangedChannel();
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
        //console.log('this.error:', this.error);
        try {
            const evt = new ShowToastEvent({
                title: 'Unexpected Error' + error.stack,
                message: error,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            //console.log('drawJqTable:', error.stack, error.message, error);
        } catch (error) {
            console.log('error:', error);
        }

    }
    /*
    bindOnClick(columns,jqTable,table)
    {
        let targetRowTemp = []; let content=[]; let newValColor='';

        try {
            //bind onclick event on each row of the jQuery DataTable
            const tbodyOfTable = this.template.querySelector('.tableClass  > tbody');
            //const tbodyOfTable =$(table>'tbody');
            const modal = this.template.querySelector('c-modal');
            $(tbodyOfTable).on('click', 'tr', function () {
                targetRowTemp = [...jqTable.row(this).data()];
                if (targetRowTemp.length > 0 && $(targetRowTemp[0]).text() === 'Modified') {
                    content = [];
                    for (var i = 2; i < targetRowTemp.length; i++) {
                        let newVal = $(targetRowTemp[i]).children().first().text();
                        //let newVal = $(targetRowTemp[i]).children().first().prop("outerHTML");//.children().first().html();
                        let oldVal = $(targetRowTemp[i]).data("oldvalue").toString();
                        newValColor = '';
                        if (newVal != oldVal) {
                            //newValColor = "new";
                            newValColor = 'new';
                            //let newValue = item.AnnualRevenue <500000 ? "slds-text-color_error":"slds-text-color_success"
                        }
                        //newValueColor=newVal!=oldVal?"newValue":"";
                        let fieldDetail = {
                            field: columns[i],
                            new: newVal,
                            old: oldVal,
                            newValColor: newValColor,
                        };
                        content.push(fieldDetail);
                    }
                    modal.content = content;
                    //console.log('content:', content);

                    modal.show();
                }
            });
        } catch (error) {
            this.showNotification(error);
        }

        
    }
    drawModifiedTable(columns, finalDiffTable, table1) {//making columns with default values so that be optional while called for reDraw
        const d2 = new Date();
        let time2 = d2.getSeconds();
        //console.log('drawJQTable start time2.0:', time2);
        //console.log('columns:', columns);
        const table = this.template.querySelector('.tableModifiedClass');

        const defaultPageSize = 100;
        //const table = this.template.querySelector('.tableClass');
        let jqTable;
        //console.log('finalDiffTable:', finalDiffTable.length);
        try {            
            
            //DataTable Definition block 
            if ($.fn.dataTable.isDataTable($(table))) { //target version hanged
                //console.log('datatable exists:');                
                //jqTable =  $(table).DataTable();
                $(table).DataTable().clear();//jqTable becomes all the records of the JQuery data table - a 2D array and not a Html object to apply $ to operate
                
            }
            else { //very firdt time load 
                //populate headers with incoming columns 
                //this.table = this.template.querySelector('.tableClass');
                if(columns && Array.isArray(columns) && columns.length>0)
                {
                    let tableHeaders = '<thead> <tr>';
                    columns.forEach(header => {
                        tableHeaders += '<th>' + header + '</th>';
                    });
                    tableHeaders += '</tr></thead>';
                    table.innerHTML = tableHeaders;
                }else{
                    //throw new Error('No Header Available to Initialize Data Table- Headers are mandetory while firstTime load');
                }
                
                jqTable = $(table).DataTable(
                    {
                        "lengthMenu": [defaultPageSize],
                        "bLengthChange": false,
                        "searching": false,
                        //"paging": true,
                        //"bInfo": true,
                        //"bFilter": true,
                        //"bRetrieve": true,
                        "retrieve": true,
                        "deferRender": true,
                        //"responsive": true,
                                                
                    }
                );
            }
            //End of DataTable Definition block 
            
            //populate rows with incoming dataRows 
            $(table).DataTable().rows.add(finalDiffTable);
            $(table).DataTable().draw();
            ////this.template.querySelector('.dataTables_filter').style.display = 'none';
            this.loaded = true;
            //setTimeout(() => {
                
                //this.bindRowClick(columns,this.template.querySelectorAll('.modified'));
            //},0);
            //console.log('this.template.querySelectorAll():', this.template.querySelectorAll('.modified'));
            // $('div.dataTables_filter input').addClass('slds-input');
            // $('div.dataTables_filter input').css("marginBottom", "10px");


            
            
            
        } catch (error) {            
            this.showNotification(error);
        } finally {
            this.loaded = true;
            let time3 = new Date().getSeconds();            
            //console.log('drawJQTable handleMessage start time3:', time3);4
            if(time3<time2)time3=time3+60;
            
        };
    }
    bindOnModClick(columns,jqTable,table)
    {
        let targetRowTemp = []; let content=[]; let newValColor='';

        try {
            //bind onclick event on each row of the jQuery DataTable
            const tbodyOfTable = this.template.querySelector('.tableModifiedClass  > tbody');
            //const tbodyOfTable =$(table>'tbody');
            const modal = this.template.querySelector('c-modal');
            $(tbodyOfTable).on('click', 'tr', function () {
                targetRowTemp = [...jqTable.row(this).data()];
                if (targetRowTemp.length > 0) {
                    content = [];
                    for (var i = 2; i < targetRowTemp.length; i++) {
                        let newVal = $(targetRowTemp[i]).children().first().text();
                        //let newVal = $(targetRowTemp[i]).children().first().prop("outerHTML");//.children().first().html();
                        let oldVal = $(targetRowTemp[i]).data("oldvalue").toString();
                        newValColor = '';
                        if (newVal != oldVal) {
                            //newValColor = "new";
                            newValColor = 'new';
                            //let newValue = item.AnnualRevenue <500000 ? "slds-text-color_error":"slds-text-color_success"
                        }
                        //newValueColor=newVal!=oldVal?"newValue":"";
                        let fieldDetail = {
                            field: columns[i],
                            new: newVal,
                            old: oldVal,
                            newValColor: newValColor,
                        };
                        content.push(fieldDetail);
                    }
                    modal.content = content;
                    //console.log('content:', content);

                    modal.show();
                }
            });
        } catch (error) {
            this.showNotification(error);
        }
    }
    
    */

    /*////////////////////Prepare Modal Content with LWC Modal ///////////////////
    
    header = 'Details';activeAddTab = false;myHeight=0;
    columns = [
        { label: 'Field', fieldName: 'field' },
        {
            label: 'New Value', fieldName: 'new', cellAttributes: {
                class: { fieldName: 'newValColor' }
            }
        },
        { label: 'Old Value', fieldName: 'old' },
    ]
    content = []; displayDetails = false;
    get displayDetails() {
        return this.displayDetails;
    }
    handelModalContent(event) {
        //this.loaded = false;
        event.stopPropagation();
        this.content = [];
        //console.log('event.detail.data:', event.detail.data);
        if (event.detail.data)
            this.content = [...event.detail.data];
    }

    /////////////////////Modal start ///////////////////////
    handleShowModal() {
        const modal = this.template.querySelector('c-modal');
        modal.show();
        //console.log('handleShowModal:');
        //this.loaded = false;

    }

    handleCancelModal() {
        //console.log('handleCancelModal:');
        const modal = this.template.querySelector('c-modal');
        modal.hide();
        //console.log('handleCancelModal:');
    }

    handleCloseModal() {
        //console.log('handleCloseModal start parent:');
        const modal = this.template.querySelector('c-modal');
        modal.hide();
        //console.log('handleCloseModal: end parent');
    }
    ////////////////////Modal End//////////////////////////*/
    /* //Alternate filter Logic if we use JQuery Search off and filter with javascript filter and LDS maintained state of original data
    //note useing search : true as well as you can use a default column search while writing the definition in columnDef - read predefined search JQuery datatable
    //search returns the rows result directly to the jqTable.DataTable.rows - you just need to search.draw . where as filter api is just to get a particular data from the 2D arrau of data in JQTable -
    //its just the javascript Filter api exposed as the dataTable api- if you really need to use filter to filter rows then u have to jqDataTable.Clear().Rows.Add(filteredRows).draw again
    //but if you try to mactch something with column 0 it retruns the data matched of column 0 - not for all the rows and need extra complications to achieve that
                filteredRows = JSON.parse(JSON.stringify(this.finalDiffTable));
                
                if(message.Status!=='')//except the case for Status = All  
                {
                    filteredRows = filteredRows.filter(row => (row[0].includes(message.Status)));
                }
                
                this.drawJQTable(this.jqTableHeaders,filteredRows,table);
                
                
                filteredRows = $(this.table)
                .columns([0])
                .data()
                .filter( function ( value, index ) {
                    return value[0].includes(message.Status);
                } );
                */

    drawAddTable(columns, rows, modifiedDataMap, table, defaultPageSize) {//making columns with default values so that be optional while called for reDraw
        //console.log('drawJQTable: drawAddTable - modifiedDataMap', modifiedDataMap);
        //console.log('drawJQTable: drawAddTable - table', table);
        //console.log('drawJQTable: drawAddTable - finalDiffTable', rows);
        const d2 = new Date();
        let time2 = d2.getSeconds();
        let jqTable;
        //console.log('finalDiffTable:', finalDiffTable.length);
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
            //console.log('drawJQTable time taken to Draw:', time3 - time2);

        };
    }
    intializeAddTable(table, columns, defaultPageSize) {
        //const table = this.template.querySelector('.tableClass');
        let jqDataTable;
        //DataTable Definition block        
        if ($.fn.dataTable.isDataTable($(table))) { //target version hanged
            //console.log('datatable exists:',jqTable?.rows?.length);                
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

    drawDelTable(columns, finalDiffTable, modifiedDataMap, table, defaultPageSize) {//making columns with default values so that be optional while called for reDraw
        //console.log('drawJQTable: drawJQTable - modifiedDataMap', modifiedDataMap);
        const d2 = new Date();
        let time2 = d2.getSeconds();
        let jqTable;
        //console.log('finalDiffTable:', finalDiffTable.length);
        try {
            //initialize - configurations options and header 
            jqTable = this.intializeDelTable(table, columns, defaultPageSize);
            //draw dataTable of the jQueryTable i.e. tBody with  Data Rows to populate
            jqTable.rows.add(finalDiffTable);
            jqTable.draw();
            //this.template.querySelector('.dataTables_filter').style.display = 'none';
            this.loaded = true;
            setTimeout(() => {
                //this.bindRowClick(jqTable,modifiedDataMap);
            }, 0);
            this.loaded = true;
        } catch (error) {
            this.showNotification(error);
        } finally {
            this.loaded = true;
            let time3 = new Date().getSeconds();
            if (time3 < time2) time3 = time3 + 60;
            //console.log('drawJQTable time taken to Draw:', time3 - time2);

        };
    }
    intializeDelTable(table, columns, defaultPageSize) {
        //const table = this.template.querySelector('.tableClass');
        let jqDataTable;
        //DataTable Definition block 
        if ($.fn.dataTable.isDataTable($(table))) { //target version hanged
            //console.log('datatable exists:',jqTable?.rows?.length);                
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

    drawModTable(columns, finalDiffTable, modifiedDataMap, table, defaultPageSize) {//making columns with default values so that be optional while called for reDraw
        //console.log('drawJQTable: drawJQTable - modifiedDataMap', modifiedDataMap);
        const d2 = new Date();
        let time2 = d2.getSeconds();
        let jqTable;
        //console.log('finalDiffTable:', finalDiffTable.length);
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
            //console.log('drawJQTable time taken to Draw:', time3 - time2);

        };
    }
    intializeModTable(table, columns, defaultPageSize) {
        //const table = this.template.querySelector('.tableClass');
        let jqDataTable;
        //DataTable Definition block 
        if ($.fn.dataTable.isDataTable($(table))) { //target version hanged
            //console.log('datatable exists:',jqTable?.rows?.length);                
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
    bindModDetailRowClick(jqTable, modifiedDataMap) {
        try {
            //console.log('drawJQTable: bindRowClick - modifiedDataMap', modifiedDataMap);
            let jqModDataTab = this.intializeModDetailsTable(this.template.querySelector('.modTabModDetail'), ['Field', 'New Value', 'Old Value']); //the moment new data comes it return the instance (existing ./ new if not existing) after clearing all data 
            jqModDataTab.draw();//we need to draw the empty table if we load new data to flush of old drawing of last data
            const tbodyOfTable = this.template.querySelector('.tableModClass  > tbody')
            $(tbodyOfTable).off('click');//clear any ther event bounded previously - as we are not destrying rather retriving the same instance this is necessary else old events like the states -i.e. search , selected page remains even while drawing with new data
            $(tbodyOfTable).on('click', 'tr', { modDetails: modifiedDataMap }, function (event) {//if you want to bind only with row having td  with a modified class then apply tr:has(.Modified) selector instead tr
                //console.log('event.data.modDetails:', event.data.modDetails);
                let targetRowTemp = jqTable.row(this).data();//this gives the index of the row clicked in DataTable
                let dataId = $(targetRowTemp[0]).data("rowkey");
                //console.log('dataId:', dataId);
                let modRowDetails = dataId ? event.data.modDetails.filter(value => dataId.includes(value[0]))[0][1] : [];//blank array if no dataId as we biund data id only to modified rows                                 
                jqModDataTab.clear().rows.add(modRowDetails).draw(); //here we need to clear again as only this portion will be applicable for onclick so clearing when new data comes does not apply here and if not there the row will doubled in second click event                
                event.preventDefault();
                event.stopPropagation();
            });
        }
        catch (error) {
            //console.log('error:', error);
        }

    }
    intializeModDetailsTable(table, headers) {
        try {
            //let modTab = this.template.querySelector('.modTableClass');
            let modJqDataTable;
            if ($.fn.dataTable.isDataTable($(table))) { //target version hanged
                //console.log('datatable exists:',jqTable?.rows?.length);                
                modJqDataTable = $(table).DataTable();
                //modJqTable.clear();//jqTable becomes all the records of the JQuery data table - a 2D array and not a Html object to apply $ to operate                
            } else {
                const defaultPageSize = [10, 20, 30, 40, 50, 100];
                let headerHtm = '<thead><tr><th>#ths#</th></tr></thead>';

                const headersReducer = (previousValue, currentValue) => previousValue + '<th>' + currentValue + '</th>';
                //console.log(headers.reduce(headersReducer));
                //table.innerHTML = headerHtm.replace('#ths#', headers.reduce(headersReducer));//the last element will left alone for which th tag is already there in headerHtm
                //console.log('table.innerHTML:', table.innerHTML);
                table.innerHTML = '<thead><tr><th>Field</th><th>New</th><th>Old</th></tr></thead>';        
                modJqDataTable = $(table).DataTable(
                    {
                        //"lengthMenu": defaultPageSize,
                        "bLengthChange": false,
                        "searching": false,
                        "retrieve": true,
                        "deferRender": true,
                        "bInfo":false,
                        "pagination":false
                    });
            }
            return modJqDataTable.clear();
        } catch (error) {
            //console.log('error:', error);
        }


    }
}