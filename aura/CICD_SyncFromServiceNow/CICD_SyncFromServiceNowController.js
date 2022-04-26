({
	initiateSync : function(component, event, helper) {
		  _fireServerSideAction( component , 'getIncidentsFromSNow' ,  { recordId : component.get("v.recordId")} )
          .then(result =>{
              helper.showToast("success" , "Success" , "Sync From Servicenow Complete");
            location.reload();

          })
              .catch(error => {
              helper.showToast("error" , "Issue Syncing From Servicenow" , error);
              helper.closeModal(component);
          });
              
                           

          
	}
})