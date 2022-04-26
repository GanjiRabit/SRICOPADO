import { LightningElement, track } from 'lwc';

export default class GetMyIp extends LightningElement {
    @track myIp;

    getIP() {
       const calloutURI = 'https://b5gpartner--copadosiv3.lightning.force.com//services/data/v53.0/sobjects/Account/0011F00000hKUFDQA4';
        fetch(calloutURI, {
            method: "GET",
            mode: 'cors',
            credentials: "include",
            headers: {
                contentType: "application/json",
                'origin': 'x-requested-with',
                CORS_ALLOW_ORIGIN :'*',
                "Access-Control-Allow-Origin":'*',
                redirect: 'follow',
                referrerPolicy: 'no-referrer',
                credentials: 'same-origin', 
                "Access-Control-Allow-Methods": "DELETE, POST, GET, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With",
                "Access-Control-Allow-Credentials":true
            }
        }).then((response)=>
        {
            console.log('response:',JSON.stringify(response));      
        }
        
        
        /* 
              => response.json()) 
            .then(repos => {
                console.log(repos)
                this.myIp = repos.ip;
                console.log(this.myIp);
            }*/
            );
    }
}