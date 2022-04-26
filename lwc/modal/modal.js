import { LightningElement, api } from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader'
import COLORS from '@salesforce/resourceUrl/colors'
const CSS_CLASS = 'modal-hidden';


export default class Modal extends LightningElement {
    showModal = false;
    @api
    set header(value) {
        this.hasHeaderString = value !== '';
        this._headerPrivate = value;
    }
    get header() {
        return this._headerPrivate;
    }

    hasHeaderString = false;
    _headerPrivate;
    isCssLoaded = false;	
    @api show() {
        this.showModal = true;
        if(this.content)
        {
           
            const modalcontentEvent = new CustomEvent('modalcontent', {
                bubbles    : true,
                composed   : true,
                cancelable : true,
                detail: {  
                    data : this.content
                }
            });
            console.log('selectedEvent:', modalcontentEvent);
            this.dispatchEvent(modalcontentEvent);
            console.log('this.content dispatched from modal:', this.content);
            this.content=[];
                        
        }   
        this.content=undefined;
    }

    @api hide() {
        this.showModal = false;
        this.content=undefined;
    }
    @api content;
    handleDialogClose(event) {
        event.event.stopPropagation();
        //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
        this.content=undefined;
        /* below is required only if you need to do any operation in parent on close and listen close from here 
        const closedialog = new CustomEvent('closedialog');
        this.dispatchEvent(closedialog);
        */
        this.hide();
    }

    handleSlotTaglineChange() {
        // Only needed in "show" state. If hiding, we're removing from DOM anyway
        // Added to address Issue #344 where querySelector would intermittently return null element on hide
        if (this.showModal === false) {
            return;
        }
        const taglineEl = this.template.querySelector('p');
        taglineEl.classList.remove(CSS_CLASS);
    }
    handleSlotContentChange()
    {
        console.log('slotContentchange:', slotContentchange);
    }
    handleSlotFooterChange() {
        // Only needed in "show" state. If hiding, we're removing from DOM anyway
        // Added to address Issue #344 where querySelector would intermittently return null element on hide
        if (this.showModal === false) {
            return;
        }
        const footerEl = this.template.querySelector('footer');
        footerEl.classList.remove(CSS_CLASS);
    }
    connectedCallback()
    {
        
    }
    renderedCallback()
    {
        if(this.isCssLoaded) return;
        this.isCssLoaded = true;
        loadStyle(this, COLORS).then(()=>{
            console.log("Loaded Successfully");
        }).catch(error=>{ 
            console.error("Error in loading the colors");
        });
    }
}