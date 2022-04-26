({
    recalculateCommitCount : function(component) {
        let commits = component.get("v.commits");
        let count = 0;

        commits.forEach( commit => {

            if(commit.isSelected) count++;

        });

        component.set("v.commitsToPromote" , count);
    }
})