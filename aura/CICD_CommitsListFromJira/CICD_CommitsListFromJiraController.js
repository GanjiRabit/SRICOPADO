({
    toggleSelection : function(component, event, helper) {
        let commits = component.get("v.commits");
        let isSelected = component.get("v.selectAllCommits");

        commits.forEach( commit => {

            commit.isSelected = isSelected;

        })

        component.set("v.commits" , commits);

        helper.recalculateCommitCount(component);
    },
    toggleSelectAll : function(component, event, helper) {

        component.set("v.selectAllCommits" , false );

        helper.recalculateCommitCount(component);

    },
    showCommitPreview: function(component, event, helper) {
        var commitIndex = event.target.getAttribute('data-rowId');
        component.set("v.commitSelectedToPreview" , component.get("v.commits")[commitIndex] );
        component.set("v.showFilesInCommit" , true );

    },
    closeCommitPreview: function(component, event, helper) {
        component.set("v.commitSelectedToPreview" , {} );
        component.set("v.showFilesInCommit" , false );

    }

})