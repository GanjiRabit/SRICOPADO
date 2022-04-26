import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { reduceErrors } from 'c/ldsUtils';
import {  subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext } from 'lightning/messageService';
import RECORD_SELECTED_CHANNEL from '@salesforce/messageChannel/dataComparerMsgChannel__c';
import {
    loadScript,
    loadStyle
} from 'lightning/platformResourceLoader';
import dataTableResource from '@salesforce/resourceUrl/DataTableDemo';
import JqueryResource from '@salesforce/resourceUrl/Jquery331';
export default class DrawJqTable extends LightningElement {
    changes={
        added:0,
        modified:0,
        deleted:0
    };
    get added() {
        return this.changes.added;
    }
    get modified() {
        return this.changes.modified;
   }
    get deleted() {
        return this.changes.deleted;
    }
     // By using the MessageContext @wire adapter, unsubscribe will be called
    // implicitly during the component descruction lifecycle.
    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        console.log('subscribeToMessageChannel:');
        this.subscription = subscribe(
            this.messageContext,
            RECORD_SELECTED_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    // Handler for message received by component
    handleMessage(message) {
        console.log('subscribeToMessageChannel:handleMessage');
        this.drawJQTable(message.columns , message.rows);
        console.log('handleMessage:'+message.columns);
        console.log('handleMessage:'+message.rows);
        this.changes.added= message.changes.added;
        this.changes.modified= message.changes.modified;
        this.changes.deleted= message.changes.deleted;
    }

    // Standard lifecycle hooks used to sub/unsub to message channel
    connectedCallback() {
        console.log('connectedCallback :subscribeToMessageChannel:handleMessage');
        this.subscribeToMessageChannel();
    }

    // Helper
    dispatchToast(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading contact',
                message: error,//reduceErrors(error).join(', '),
                variant: 'error'
            })
        );
    }

    
    drawJQTable(columns , finalDiffTable)
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
            console.log('drawJQTable : columnNames');
            let tableHeaders = '<thead> <tr>';
            columnNames.forEach(header => {
                tableHeaders += '<th>' + header + '</th>';
            });
            console.log('drawJQTable : tableHeaders');
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
            jqTable.rows.add([...finalDiffTable]);
            console.log('drawJQTable : jqTable.rows.add done');
            jqTable.draw();
            console.log('drawJQTable : jqTable.draw');
            /*
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
            */
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