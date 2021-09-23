trigger MaintenanceRequest on Case (before update, after update) {
    // ToDo: Call MaintenanceRequestHelper.updateWorkOrders

    //si el trigger es actualizado y despues de actualizado

    if(Trigger.isUpdate && Trigger.isAfter){

        //entonces el request helper actualiza los IDs del mapeado de las versiones anteriores a una nueva lista de los IDs
        MaintenanceRequestHelper.updateWorkOrders(Trigger.new, Trigger.oldMap);

    }

}
