({
    getUrlParams : function(component, event, helper){
		
		var key;
		var params = event.getParam('arguments');
		
		if (params) {
            key = params.key;           
        }

		if(!key){
			return undefined;
		}

		var searchStr = ''; 

		//special handling of url params in mobile
		if(!$A.get("$Browser.isDesktop")){
			var hash = window.location.hash;  
				if(hash){
					var questionMarkIndex = hash.indexOf('?');
					searchStr = hash.substr(questionMarkIndex);
				}else{
					searchStr = window.location.search;
				}
		}else{
				searchStr = window.location.search;
		}	 

		var sPageURL = decodeURIComponent(searchStr.substring(1)),
		 sURLVariables = sPageURL.split('&'),
		 sParameterName,
		 i;	 

		 for (i = 0; i < sURLVariables.length; i++) {
			sParameterName = sURLVariables[i].split('=');				 
			if (sParameterName[0] === key) {
				return sParameterName[1] === undefined ? true : sParameterName[1];
			}
		 }		 
	}, 
	 
	callApex : function(component, event, helper) {	 //PROMISE BASED
 
		component.set('v.recordError', []);

		var params = event.getParam('arguments');
        if (params) {    
			var method = params.method;
			var parameters = params.parameters;
			var cb = params.cb;
        }
		
		var promiseObj = new Promise(
			function(resolve, reject){  

				var action = component.get(method);
				if (parameters) {
					action.setParams(parameters);
				}

				if(params.isBackground) action.setBackground();

				action.setCallback(this,function(response) {
					var state = response.getState();	

					if (state === "SUCCESS") {
						var data = response.getReturnValue();			 
						if(cb){
							cb.call(this,data);
						}			
						resolve(data)				 
					} else if (state === "ERROR") {

						var recError = component.get('v.recordError');

						var errors = response.getError();
						console.log("%cAn Error occurred in: " + method, "color: red; font-size: medium;");
						console.log(errors); 

						var msg = '';
						for(var i = 0; i < errors.length; i++){
							for(var x = 0; x < errors[i].pageErrors.length; x++){
								msg += errors[i].pageErrors[x].message;
								recError.push(errors[i].pageErrors[x].message);
							}
						}					 		

						component.set('v.recordError', recError);
						// reject(msg);					 
					}							

				});

				$A.enqueueAction(action);


				 
			}		
		);
		return promiseObj;        
    }, 

	buildDeployText : function(component, event, helper){

		var params = event.getParam('arguments');
        if (params) {    
			var nm = params.nm;
			var title = params.title;
			var step = params.step;
        }

        var txt = ''; 
        txt += '<strong>'+nm+ ' - '+title+'</strong><pre>'+ step + '</pre>';
        return txt; 
    },

})