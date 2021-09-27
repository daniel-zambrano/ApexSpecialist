public with sharing class MaintenanceRequestHelper {


    //metodo estatico vacio, se llama updateWorkOrders y recibe dos parametros, el primero una lista de casos nuevos, llamada 'NewMaintenanceRequestList'
    // y el segundo parametro es un mapeo de los ID de los Cases llamado 'MapOldRequest'
    public static void updateworkOrders(List<Case> updWorkOrders, Map<Id,Case> nonUpdCaseMap) {

        //Se utiliza el Set<ID> como una lista en donde los valores no se repiten, es decir una lista unica y con el validIds se guardan los cases validos
          //y que no estan repetidos
        Set<Id> validIds = new Set<Id>();

        //Se hace un loop en el case llamado 'newC' para la nueva lista llamada 'NewMaintenanceRequestList'
        For (Case c : updWorkOrders){

            //el mapeo de los Case llama los ID de la lista del set para el 'newC' y hace una comparacion en su estatus, en el cual el mapeo de los ID es diferente a 'Closed' 
            //y el estatus del nuevo objeto del Case es igual a 'Closed'
            if (nonUpdCaseMap.get(c.Id).Status != 'Closed' && c.Status == 'Closed'){

                //En base a lo anterior se hace un nuevo if, el cual compara el tipo del nuevo objeto del Case que sea igual a 'Repair' o si es igual a 'Routine Maintenance'
                if (c.Type == 'Repair' || c.Type == 'Routine Maintenance'){

                    //Si los tipos del nuevo objeto 'newC' son 'Repair' o 'Routine Maintenance' se agregar a la lista del Set 'validIds' 
                    validIds.add(c.Id);
                    
             
                }
            }
        }
        
        if (!validIds.isEmpty()){
            List<Case> newCases = new List<Case>();
            Map<Id,Case> closedCasesM = new Map<Id,Case>([SELECT Id, Vehicle__c, Equipment__c, Equipment__r.Maintenance_Cycle__c,(SELECT Id,Equipment__c,Quantity__c FROM Equipment_Maintenance_Items__r) 
                                                         FROM Case WHERE Id IN :validIds]);
            Map<Id,Decimal> maintenanceCycles = new Map<ID,Decimal>();
            AggregateResult[] results = [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)cycle FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :ValidIds GROUP BY Maintenance_Request__c];
        
        for (AggregateResult ar : results){ 
            maintenanceCycles.put((Id) ar.get('Maintenance_Request__c'), (Decimal) ar.get('cycle'));
        }
            
            for(Case cc : closedCasesM.values()){
                Case nc = new Case (
                    ParentId = cc.Id,
                Status = 'New',
                    Subject = 'Routine Maintenance',
                    Type = 'Routine Maintenance',
                    Vehicle__c = cc.Vehicle__c,
                    Equipment__c =cc.Equipment__c,
                    Origin = 'Web',
                    Date_Reported__c = Date.Today()
                    
                );
                
                If (maintenanceCycles.containskey(cc.Id)){
                    nc.Date_Due__c = Date.today().addDays((Integer) maintenanceCycles.get(cc.Id));
                }
                
                newCases.add(nc);
            }
            
           insert newCases;
            
           List<Equipment_Maintenance_Item__c> clonedWPs = new List<Equipment_Maintenance_Item__c>();
           for (Case nc : newCases){
                for (Equipment_Maintenance_Item__c wp : closedCasesM.get(nc.ParentId).Equipment_Maintenance_Items__r){
                    Equipment_Maintenance_Item__c wpClone = wp.clone();
                    wpClone.Maintenance_Request__c = nc.Id;
                    ClonedWPs.add(wpClone);
                    
                }
            }
            insert ClonedWPs;
        }
    }
}
