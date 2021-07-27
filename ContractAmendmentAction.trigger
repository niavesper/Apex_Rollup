// Date:      6/11/21
// Author:    Ksenia Choate
// Description:  Trigger created to acommodate rollup summaries between Grant__Funding_Application__c (parent)
// and Contract_Amendment__c (child) in a lookup relationship. Invokes the class "ContractAmendmentAction."
// History:    V.1

trigger ContractAmendmentAction on Contract_Amendment__c(
  after insert,
  after update,
  after delete,
  after undelete
) {
  // Create an empty list to hold Contract Amendments
  List<Contract_Amendment__c> contractAmendments;

  // Create an empty map to hold old Contract Amendments.
  // This is for scenarios when a contract amendment gets reparented to a different Funding Application
  Map<Id, Contract_Amendment__c> oldContractAmendmentsMap;

  switch on Trigger.operationType {
    // When after insert, update, and undelete:
    // assign the value of Trigger.new to "contractAmendments" and
    // assign the valie of Trigger.oldMap to "oldContractAmendmentsMap"
    when AFTER_INSERT, AFTER_UPDATE, AFTER_UNDELETE {
      contractAmendments = (List<Contract_Amendment__c>) Trigger.new;
      oldContractAmendmentsMap = (Map<Id, Contract_Amendment__c>) Trigger.oldMap;
    }
    // When after delete: assign the value of Trigger.old to "contractAmendments"
    when AFTER_DELETE {
      contractAmendments = (List<Contract_Amendment__c>) Trigger.old;
    }
  }

  // Pass the value of "contractAmendments" to the handler class
  ContractAmendmentAction.calculateTotalAmount(
    contractAmendments,
    oldContractAmendmentsMap
  );
}
