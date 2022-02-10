 function runTaskList(){
    var tasklist = document.querySelector("#task-pane").shadowRoot.querySelector("div.client-task-pane > div");
    var ntasks = tasklist.childElementCount + 1;
    for (var i = 1; i < ntasks; i++) {
        let str1 = "div.client-task-pane > div > div:nth-child(";
        let str2 = i;
        let str3 = ") > ee-button";
        let res = str1.concat(str2, str3);
        document.querySelector("#task-pane").shadowRoot.querySelector(res).click();
    } 
    return(ntasks)
 }

 function confirmAll(ntasks) {
   
    var gonext = true;
    var i = ntasks+20;
    let str1 = "body > ee-table-config-dialog:nth-child(";
    let str3 = ")";
    
    while (gonext) {
        let str2 = i;
        let res = str1.concat(str2, str3);
        
        if(document.querySelector(res)==null){
            console.log("no run btn found!")
            i--;
        }else{
            console.log(res)
            document.querySelector(res).shadowRoot.querySelector("ee-dialog").shadowRoot.querySelector("paper-dialog > div.buttons > ee-button.ok-button").shadowRoot.querySelector("paper-button").click();
            i--;
        }
        if(i<0) gonext = false;
    } 
}

// run the following function to start all tasks in google earth engine console
var ntasks = runTaskList();

// wait until confirmation windows are shown to run the following the confirm all tasks
confirmAll(ntasks);