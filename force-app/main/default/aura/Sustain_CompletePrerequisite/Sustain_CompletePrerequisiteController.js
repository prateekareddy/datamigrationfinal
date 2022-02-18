({
    doInit: function(component, event, helper) {
        helper.getFactorList(component, event, helper);
    },
	closeModal : function(component, event, helper) {
		component.set("v.showModal",false);
	},
    openModal: function(component, event, helper) {
        component.set("v.showModal",true);
    },
    openHelpPage : function(component,event, helper) {        
        window.open($A.get("$Label.c.Sustain_helpPageURL"));
    },
    saveData : function(component, event, helper) {
        var elecId=component.find("ElectricityEmssnFctrId").get("v.value");
        var othId=component.find("OtherEmssnFctrId").get("v.value");
        var airId=component.find("AirTravelEmssnFctrId").get("v.value");
        var grndId=component.find("GroundTravelEmssnFctrId").get("v.value");
        var frgtId=component.find("FrgtHaulingEmssnFctrId").get("v.value");
        var htlId=component.find("HotelStayEmssnFctrId").get("v.value");
        var refrId=component.find("RefrigerantEmssnFctrId").get("v.value");
        var rntlId=component.find("RentalCarEmssnFctrId").get("v.value");
        var fctrMap = {
            "ElectricityEmssnFctrId" : elecId,
            "OtherEmssnFctrId": othId,
            "AirTravelEmssnFctrId": airId,
            "GroundTravelEmssnFctrId": grndId,
            "FrgtHaulingEmssnFctrId": frgtId,
            "HotelStayEmssnFctrId" :htlId,
            "RefrigerantEmssnFctrId":refrId,
            "RentalCarEmssnFctrId":rntlId,
        };
        component.set("v.fctrMap",fctrMap);
        helper.createSettingRecords(component, event, helper);
    },
    
})