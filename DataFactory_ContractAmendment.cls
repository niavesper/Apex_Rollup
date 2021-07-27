@isTest
public with sharing class DataFactory_ContractAmendment {

    /***** Method that returns Contract Amendments *****/
    public static List<Contract_Amendment__c> returnContractAmendments() {

        // Generate and insert a parent Funding Application (parent is needed because we'll be testing rollup summaries)
        Grant__Funding_Application__c fa = new Grant__Funding_Application__c(Grant__Application_Title__c = 'TestFundingApp');
    
        insert fa;
    
        // Create test Contract Amendments and add them to a list
        List<Contract_Amendment__c> contractAmendments = new List<Contract_Amendment__c>();
        for (Integer i=0; i < 5; i++) {
            Contract_Amendment__c ca = new Contract_Amendment__c();
            ca.Amendment_Amount__c = 1000;
            ca.Funding_Application__c = fa.id;
            contractAmendments.add(ca);
        }
    
        return contractAmendments;
    }

    /***** Method that inserts and returns Contract Amendments *****/
    public static List<Contract_Amendment__c> insertAndReturnContractAmendments() {

        // Generate Contract Amendments by invoking the method "returnContractAmendments" and assign them to a list
        List<Contract_Amendment__c> contractAmendments = returnContractAmendments();
    
        insert contractAmendments;
        return contractAmendments;
    }

    /***** Method that deletes Contract Amendments *****/
    public static List < Contract_Amendment__c > deleteContractAmendments() {

        // Generate and insert Contract Amendments by invoking the method "insertAndReturnContractAmendments" and assign them to a list
        List<Contract_Amendment__c> contractAmendments = insertAndReturnContractAmendments();
        
        delete contractAmendments;
        return contractAmendments;
    }
}
