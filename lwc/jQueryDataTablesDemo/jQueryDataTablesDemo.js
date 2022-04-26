import {
    LightningElement
} from 'lwc';
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
// import toast message event .

// import apex class and it's methods.
import getAccounts from '@salesforce/apex/LWCExampleController.getAccounts';

export default class JqueryDataTableLWCDemo extends LightningElement {
    accounts = [];
    error;

    async connectedCallback() {
        await this.fetchAccoutns();

        Promise.all([
            loadScript(this, JqueryResource),
            //loadScript(this, dataTableModifiedForLWCResource),
            loadScript(this, dataTableResource + '/DataTables-1.10.18/media/js/jquery.dataTables.min.js'),
            loadStyle(this, dataTableResource + '/DataTables-1.10.18/media/css/jquery.dataTables.min.css'),
        ]).then(() => {
            console.log('script loaded sucessfully');

            const table = this.template.querySelector('.tableClass');
            const columnNames = ['Name', 'Industry', 'Type', 'Phone', 'Rating'];
            let tableHeaders = '<thead> <tr>';
            columnNames.forEach(header => {
                tableHeaders += '<th>' + header + '</th>';
            });
            tableHeaders += '</tr></thead>';
            table.innerHTML = tableHeaders;

            let jqTable = $(table).DataTable();
            $('div.dataTables_filter input').addClass('slds-input');
            $('div.dataTables_filter input').css("marginBottom", "10px");
            let i=10000000;
            this.accounts.forEach(rec => {
                let tableRows = [];
                tableRows.push('<a href="/lightning/r/Account/' + rec.Id + '/view">' + rec.Name + '</a>');
                tableRows.push(rec.Industry != undefined ? rec.Industry : '');
                tableRows.push(rec.Type != undefined ? rec.Type : '');
                //tableRows.push(rec.Phone != undefined ? rec.Phone : '');
                tableRows.push('<div class="tooltip">'+rec.Phone +' <span class="tooltiptext">'+i+'</span> </div>');
                tableRows.push(rec.Rating != undefined ? rec.Rating : '');
                jqTable.row.add(tableRows);
                i=i+11;
            });
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

    async fetchAccoutns() {
        await getAccounts()
            .then(data => {
                if (data) {
                    this.accounts = data;
                }
            })
            .catch(error => {
                this.error = error;
                this.accounts = undefined;
                this.error = 'Unknown error';
                if (Array.isArray(error.body)) {
                    this.error = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.error = error.body.message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: error,
                        variant: 'error',
                    }),
                );
            });
    }
}