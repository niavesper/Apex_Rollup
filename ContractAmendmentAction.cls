public class ContractAmendmentAction {
  // contractAmendments = Trigger.new or Trigger.old, depending on the trigger context variables (see trigger "ContractAmendmentAction"). oldContractAmendmentsMap = Trigger.oldMap
  public static void calculateTotalAmount(
    List<Contract_Amendment__c> contractAmendments,
    Map<Id, Contract_Amendment__c> oldContractAmendmentsMap
  ) {
    // Create an empty set to store IDs of Funding Applications
    Set<Id> fundingApplicationIds = new Set<Id>();

    // Loop through the list of Contract Amendments from the trigger
    for (Contract_Amendment__c ca : contractAmendments) {
      // If the Contract Amendment is releated to a Funding Application ...
      if (ca.Funding_Application__c != null) {
        // ... add the parent's Id to the set "fundingApplicationIds"
        fundingApplicationIds.add(ca.Funding_Application__c);
      }

      // If there are records in Trigger.oldMap (i.e., if a Contract Amendment was edited)...
      if (oldContractAmendmentsMap != null) {
        // ... find the ID of the current Contract Amendment ("ca") in Trigger.oldMap
        // and assign the record with this ID to the variable "oldContractAmendment"
        Contract_Amendment__c oldContractAmendment = oldContractAmendmentsMap.get(
          ca.Id
        );

        // If the Contract Amendment was reparented to another Funding Application ...
        if (
          oldContractAmendment.Funding_Application__c !=
          ca.Funding_Application__c
        ) {
          // ... add the Id of the original Funding Application to the set "fundingApplicationIds"
          fundingApplicationIds.add(
            oldContractAmendment.Funding_Application__c
          );
        }
      }
    }

    // Create an empty list to store Funding Applications that will be updated
    List<Grant__Funding_Application__c> fundingApplicationsToUpdate = new List<Grant__Funding_Application__c>();

    // Run an aggregate query on Contract Amendments, summarizing Amendment_Amount__c and grouping by Funding Application
    // This aggregate query will return null when a Contract Amendment gets deleted because it's impossible to query records from
    // Trigger.old in AFTER_DELETE. This means that the logic in the traditional FOR loop below is skipped when trigger context variable is AFTER_DELETE

    List<AggregateResult> aggregateResult = [
      SELECT Funding_Application__c, SUM(Amendment_Amount__c) totalValue
      FROM Contract_Amendment__c
      WHERE Funding_Application__c IN :fundingApplicationIds
      GROUP BY Funding_Application__c
    ];

    // Assign the numeric value of the aggregate query's size to the integer aggregateResultSize
    Integer aggregateResultSize = aggregateResult.size();
    // Inside a traditional FOR loop ...
    for (Integer i = 0; i < aggregateResultSize; i++) {
      // Grab a member of the aggregate query and assign it to an AggregateResult variable
      AggregateResult agr = aggregateResult.get(i);
      // Grab the ID of the Funding Application from the member of the aggregate query and assign it to an ID variable
      Id fundingApplicationId = (Id) agr.get('Funding_Application__c');
      // Grab the sum of Amendement_Amount__c from the member of the aggregate query and assign it to a Decimal variable
      Decimal totalAmendmentAmts = (Decimal) agr.get('totalValue');
      // Update Sum_of_All_Amendment_Amounts_Currency__c of the Funding Application (the current member of the aggregare query) with the sum of Amendement_Amount__c
      Grant__Funding_Application__c fa = new Grant__Funding_Application__c(
        Id = fundingApplicationId,
        Sum_of_All_Amendment_Amounts_Currency__c = totalAmendmentAmts
      );
      // Add the updated Funding Application to the earlier created empty list
      fundingApplicationsToUpdate.add(fa);
      // If the set of Funding Application IDs already contains the ID of the Funding Application from the aggregare query, remove it.
      if (fundingApplicationIds.contains(fundingApplicationId)) {
        fundingApplicationIds.remove(fundingApplicationId);
      }
    }

    // Loop through the remaining IDs in the set of Funding Application IDs.
    for (Id fundingApplicationId : fundingApplicationIds) {
      // Update Sum_of_All_Amendment_Amounts_Currency__c of the Funding Application (the current member of the loop) with zero
      Grant__Funding_Application__c fa = new Grant__Funding_Application__c(
        Id = fundingApplicationId,
        Sum_of_All_Amendment_Amounts_Currency__c = 0
      );
      // Add the updated Funding Application to the earlier created empty list
      fundingApplicationsToUpdate.add(fa);
    }

    update fundingApplicationsToUpdate;
  }
}
