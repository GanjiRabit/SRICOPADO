({
  closeDialog: function(component, event, helper) {
    setTimeout(
      $A.getCallback(function() {
        $A.get("e.force:refreshView").fire();
      }),
      100
    );
    $A.get("e.force:closeQuickAction").fire();
  }
});