({
    doInit : function(component, event, helper) {
        helper.checkCurRunJobIsSampleFinal(component, event, helper);
        var action1 = component.get("c.getlatestDataLoad");
        action1.setCallback(this, function(response) {
            var state = response.getState();
            //alert('inisde sample doinit'+state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // console.log("storeResponse"+storeResponse);
                //component.set("v.displaybuttons",storeResponse);
                component.set("v.dLR",storeResponse);

                if(storeResponse != undefined && storeResponse.Migration_Util__Data_Load_Type__c==='Sample Data Load' && 
                  (storeResponse.Migration_Util__Status__c==='Partial Complete' || storeResponse.Migration_Util__Status__c==='Completed')){
                   component.set("v.batchSuccess",true);
                }
                //alert('value of storeResponse'+response.getReturnValue());
               // alert('value of storeResponse'+storeResponse);
                }
        });
        $A.enqueueAction(action1);
       
        var action2 = component.get("c.getOrgAssetData");
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResp = response.getReturnValue();
                var plValues = [];
                for (var i = 0; i < storeResp.length; i++) {
                    plValues.push({
                        label: storeResp[i],
                        value: storeResp[i]
                    });
                }
                component.set("v.listOfAssetRecords",plValues);
                component.set("v.allAssetRecords",plValues);
            }
        });
        $A.enqueueAction(action2);
        
        /*var channel = "/event/Migration_Util__Sustain_SampleLoadEvent__e";
        var replayId = -1;
        const empApi = component.find("empApi");
        var callback = function (message) {
            var msg = message.data.payload;
            component.set("v.batchSuccess",msg.Migration_Util__Sustain_BatchStatus__c);
        };
        empApi.subscribe(channel, replayId, callback).then(function(newSubscription) {
        }); */      
        
    },
    
    keyPressController : function(component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.searchKeyword");
        if(getInputkeyWord.length > 0){ 
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }else if(getInputkeyWord.length === 0){
            component.set("v.listOfAssetRecords",component.get("v.allAssetRecords"));
        }
        
    },
    
    // function for clear the Record Selection 
    clear :function(component,event,helper){
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.lstSelectedRecords"); 
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].Id === selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.lstSelectedRecords", AllPillsList);
            }  
        }
        component.set("v.searchKeyword",null);
        component.set("v.listOfSearchRecords", null );      
    },
    
    handleAssetChange: function (component, event, helper) {
        //Get the Selected values   
        var selectedValues = event.getParam("value");
         
        //Update the Selected Values  
        component.set("v.resultCmp", selectedValues);
    },
    
    startLoad : function(component,event,helper){
        if(!$A.util.isEmpty(component.get("v.resultCmp"))){
            component.set("v.startClicked",true);
            component.set("v.skipClicked",false); 
            component.set("v.deleteClicked",false);
            //alert(component.get("v.resultCmp"));
            var action = component.get("c.createDataLoadReq");
            action.setParams({
                "orgAssetData": component.get("v.resultCmp")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    var compEvent = component.getEvent("handleRefreshEvent");
                    compEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
        else{            
        	var toastEvent = $A.get("e.force:showToast");                    
                            toastEvent.setParams({
                                title : 'Error',
                                message: $A.get("$Label.c.Sustain_StartSampleLoadText2"),
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();    
        }
    },
    
    skipLoad : function(component,event,helper){
        component.set("v.skipClicked",true);
        component.set("v.startClicked",false);
        
    },
   deleteLoad : function(component,event,helper){
        component.set("v.startClicked",false);
        component.set("v.skipClicked",false);
        component.set("v.deleteClicked",true);
        component.set("v.batchSuccess",false);
        var action = component.get("c.deleteDataLoadReq");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                //alert(storeResponse);
				component.set("v.displaybuttons",storeResponse);
                var compEvent = component.getEvent("handleRefreshEvent");
                compEvent.fire();
                       /* if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                            var toastEvent = $A.get("e.force:showToast");                    
                            toastEvent.setParams({
                                title : 'Success',
                                message: 'Delete migrated data job has been initiated, we will notify you once its done.',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }  else {
                            var toastEvent = $A.get("e.force:showToast");                    
                            toastEvent.setParams({
                                title : 'Error',
                                message: 'There is a problem. Please contact System Admin.',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }*/
            }
        });
        $A.enqueueAction(action);
    },
    
    onCheck  : function(component,event,helper){
        if(component.get("v.checkboxChecked") === true)
            component.set("v.checkboxChecked",false);
        else
            component.set("v.checkboxChecked",true); 
        
    },
    
    openModel : function(component,event,helper){
        component.set("v.showmodalpopup" , true) ;
        if(component.get("v.resultCmp")!==''){
            component.set("v.selAssetRec",true);
        }
        //var selectedAsset = component.get("v.resultCmp");
        var action = component.get("c.getOrgAssetData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                //component.set("v.listOfAssetRecords",storeResponse);
                component.set("v.allAssetRecords",storeResponse);
                
                var selectedAsset = component.get("v.resultCmp");
                var asset = [];
                if($A.util.isEmpty(selectedAsset)){
                    for(var i=0; i<storeResponse.length; i++ ){
                        asset.push({value:storeResponse[i], status:false});
                    }
                }
                else{
                    for(var j=0; j<component.get("v.listOfAssetRecords").length; j++ ){
                        if(selectedAsset.includes(storeResponse[j])) 
                            asset.push({value:storeResponse[j], status:true});
                        else
                            asset.push({value:storeResponse[j], status:false});
                    }
                }
                component.set("v.listOfAssetRecords",asset);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleCloseModal : function(component,event,helper){
       // debugger;
        var selectRecords = [];
        var checkAsset = component.find("checkboxs");
        if(checkAsset !== undefined){
            if (!Array.isArray(checkAsset)) {
                if(checkAsset.get("v.checked") === true){ // (checkAsset.get("v.value") === true){ 
                    selectRecords.push(checkAsset.get("v.value"));
                }
            }
            else{
                for(var i=0; i<checkAsset.length; i++){
                    if (checkAsset[i].get("v.checked") === true) {
                        selectRecords.push(checkAsset[i].get("v.value"));
                    }
                }
            }
        }
        //component.set("v.resultCmp",selectRecords);
        var tempResult = component.get("v.resultCmp");
        tempResult.push(selectRecords);
        component.set("v.resultCmp",tempResult);
        component.set("v.showmodalpopup" , false) ;
        component.set("v.skipClicked" , false) ;
    },
    
    /*getSelectedAsset : function(component, event,helper) { 
        var selectedId='';
        //when using <ui:inputCheckbox> instead html checkbox
        //selectedId=event.getSource().get("v.text");                
        selectedId = event.target.getAttribute('id');
        if(document.getElementById(selectedId).checked && component.get("v.SelectedAsset").indexOf(selectedId) < 0)
            component.get('v.SelectedAsset').push(selectedId);
        else{
            var index = component.get("v.SelectedAsset").indexOf(selectedId);
            if (index > -1) {
                component.get("v.SelectedAsset").splice(index, 1); 
            }
        }
        component.set("v.resultCmp",component.get("v.SelectedAsset"));
    },*/
    
    handleCheckTask : function(component,event,helper){
        var selectRefRecords = [];
        var checkCmp = component.find("checkboxs");
        var resultcheckCmp = component.get("v.resultCmp");
        if(checkCmp !== undefined){
            if (!Array.isArray(checkCmp)) {
                if (checkCmp.get("v.value") === true) {
                    if(component.get("v.resultCmp")!==''){
                        var selText = checkCmp.get("v.text");
                        if(resultcheckCmp.includes(selText)){
                        }else
                            resultcheckCmp.push(selText); 
                        component.set("v.resultCmp",resultcheckCmp);
                    }
                    selectRefRecords.push(checkCmp.get("v.text"));
                    component.set("v.resultCmp",selectRefRecords);
                } }else{
                    for(var i=0; i<checkCmp.length; i++){
                        if (checkCmp[i].get("v.value") === true) {
                            if(component.get("v.resultCmp")!=='' && component.get("v.selAssetRec")===true){
                                var selText = checkCmp[i].get("v.text");
                                if(resultcheckCmp.includes(selText)){
                                }else
                                    resultcheckCmp.push(selText);
                                component.set("v.resultCmp",resultcheckCmp);
                            }else{
                                if(component.get("v.resultCmp")!==''){
                                    var selText = checkCmp[i].get("v.text");
                                    if(resultcheckCmp.includes(selText)){
                                    }else
                                        resultcheckCmp.push(selText);
                                    component.set("v.resultCmp",resultcheckCmp);
                                }else{
                                    selectRefRecords.push(checkCmp[i].get("v.text")); 
                                    component.set("v.resultCmp",selectRefRecords);
                                }
                            }
                        }
                    }
                }
        }
        // component.set("v.resultCmp",selectRefRecords);
    },
    
    
    clear : function(component,event,helper){
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.resultCmp");
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i] === selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.resultCmp", AllPillsList);
            }  
        }
    },
    
    handleProceed : function(component,event,helper){
        component.set("v.showmodalpopup" , false) ;
        component.set("v.skipClicked" , false) ;
        var componentEvent=component.getEvent("handleProceedEvent");
        componentEvent.fire();
    }
    
    
    
})