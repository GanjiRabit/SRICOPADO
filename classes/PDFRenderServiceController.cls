public with sharing class PDFRenderServiceController {
    public string htmlContent { get; set; }
    public List<integer> loops { get; set; }
    public string dynamicContent {get;set;}
    public PDFRenderServiceController() {
        this.htmlContent = '<div> <b>This is new content from content </b></div>';
        this.loops = new List<integer>();
        for(integer i =0 ; i < 10; i ++){
            this.loops.add(i);
        }

        this.dynamicContent = [select Language__c from Template__c limit 1].Language__c;
    }

    public Component.c.dynamicPDFComponent getDynamicComponent(){
        return new Component.c.dynamicPDFComponent();
    }
}