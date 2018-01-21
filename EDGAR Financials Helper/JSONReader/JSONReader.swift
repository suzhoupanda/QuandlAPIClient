//
//  JSONReader.swift
//  EDGAR Financials Helper
//
//  Created by Aleksander Makedonski on 12/15/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation
import CoreData
import UIKit



class JSONReader{
    
    
    typealias JSONResponseDict = Dictionary<String,Any>
    typealias BalanceSheetDict = Dictionary<String,Double>
    typealias IncomeStatementDict = Dictionary<String,Double>
    typealias CashFlowsDict = Dictionary<String,Double>
    
    var coreDataStack: CoreDataStack!
    var modelName: String?
    
    lazy var dateFormatter: DateFormatter = {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter
        
    }()
    
    init(){
        self.coreDataStack = CoreDataStack(withModelName: "EDGAR_Financials_Helper")
    }
    
    init(withCoreDataStack stack: CoreDataStack){
        self.coreDataStack = stack
    }
    
    init(withModelName name: String){
        self.modelName = name
        self.coreDataStack = CoreDataStack(withModelName: name)
    }
    
     var managedContext: NSManagedObjectContext{
        
        return self.coreDataStack.managedContext
    }
    
    var stockQuotePeriodEntDesc: NSEntityDescription?{
        
        return NSEntityDescription.entity(forEntityName: "StockQuotePeriod", in: self.managedContext)
        
        
    }
    
    func saveQuandlData(forCompanyName companyName: String, forJSONResponseDict jsonResponseDict: JSONResponseDict){
        
        DispatchQueue.main.async {
            
            
            print("Saving data from JSON response...")
            
            guard let dataDict = jsonResponseDict["dataset_data"] as? [String: Any] else {
                print("Error: unable to save data due to inability to extract data dictionary  from JSON response")
                return
            }
            
            let stockQuotePeriod = StockQuotePeriod(context: self.managedContext)
            
            let startDateStr = dataDict["start_date"] as! String
            let endDateStr = dataDict["end_date"] as! String
            
            stockQuotePeriod.startDate = self.dateFormatter.date(from: startDateStr)!
            stockQuotePeriod.endDate = self.dateFormatter.date(from: endDateStr)!
            
            stockQuotePeriod.companyName = companyName
            
            self.coreDataStack.saveContext()
            
            guard let dailyQuotes = dataDict["data"] as? [[Any]] else {
                print("Error: unable to retrieve daily quotes from JSON data")
                return
            }
            
        
            dailyQuotes.forEach({
                
                dailyQuote in
              
                self.saveDailyQuote(forStockQuotePeriod: stockQuotePeriod, dailyQuote: dailyQuote)
            
            })
            
            self.coreDataStack.saveContext()
            
        }
    }
    
    func saveDailyQuote(forStockQuotePeriod stockQuotePeriod: StockQuotePeriod, dailyQuote: [Any]){
        
        let dailyQuoteSummary = DailyQuoteSummary(context: self.managedContext)
        
        if let dateStr = (dailyQuote[0] as? String), let date = dateFormatter.date(from: dateStr){
            dailyQuoteSummary.date = date
        }
    
        let open = (dailyQuote[1] as! NSNumber).floatValue
        dailyQuoteSummary.open = open
        
        
        let high = (dailyQuote[2] as! NSNumber).floatValue
        dailyQuoteSummary.high = high
        
        
        let low = (dailyQuote[3] as! NSNumber).floatValue
        dailyQuoteSummary.low = low
        
        
        let close = (dailyQuote[4] as! NSNumber).floatValue
        dailyQuoteSummary.close = close
        
        
        let volume = (dailyQuote[5] as! NSNumber).int64Value
        dailyQuoteSummary.volume = volume
        
        let exDividend = (dailyQuote[6] as! NSNumber).int64Value
        dailyQuoteSummary.exDividend = exDividend
        
        let splitRatio = (dailyQuote[7] as! NSNumber).floatValue
        dailyQuoteSummary.splitRatio = splitRatio
        
        let adjOpen = (dailyQuote[8] as! NSNumber).floatValue
        dailyQuoteSummary.adjustedOpen = adjOpen
        
        let adjHigh = (dailyQuote[9] as! NSNumber).floatValue
        dailyQuoteSummary.adjustedHigh = adjHigh
        
        let adjLow = (dailyQuote[10] as! NSNumber).floatValue
        dailyQuoteSummary.adjustedLow = adjLow
        
        let adjClose = (dailyQuote[11] as! NSNumber).floatValue
        dailyQuoteSummary.adjustedClose = adjClose
        
        let adjVolume = (dailyQuote[12] as! NSNumber).int64Value
        dailyQuoteSummary.adjustedVolume = adjVolume
        
        stockQuotePeriod.addToDailyQuoteSummary(dailyQuoteSummary)
    }

     func saveData(forJSONResponseDict jsonResponseDict: JSONResponseDict){
        
        DispatchQueue.main.async {
            
            
        
        print("Saving data from JSON response...")
            
            
        guard let statementName = jsonResponseDict[JSONReader.kStatementName] as? String else {
                print("Error: unable to save data due to inability to extract balance sheet data from JSON response")
                return
            }
            
            switch(statementName){
                case "Balance Sheet":
                    self.saveBalanceSheetDataFrom(jsonResponseDict: jsonResponseDict)
                    break
                case "Income Statement":
                    self.saveIncomeStatementDataFrom(jsonResponseDict: jsonResponseDict)
                    break
                case "Cash Flows Statement":
                    break
            default:
                break
            }
            
        }

    }
    

    
}

extension JSONReader{
    
    
    
    static let SampleJSON = ["Data": [
        "AccountsPayableCurrent": 49049000000,
        "AccruedLiabilitiesCurrent": 25744000000,
        "AccumulatedOtherComprehensiveIncomeLossNetOfTax":-150000000,
        "Assets": 375319000000,
        "AssetsCurrent": 128645000000,
        "AvailableForSaleSecuritiesCurrent": 53892000000,
        "CashAndCashEquivalentsAtCarryingValue": 20289000000,
       "CommercialPaper": 11977000000,
        "NontradeReceivablesCurrent":  17799000000,
        "OtherAssetsCurrent": 13936000000,
        "AccountsReceivableNetCurrent": 17874000000,
        "AvailableForSaleSecuritiesNoncurrent": 194714000000,
        "OtherAssetsNoncurrent": 10162000000,
        "PropertyPlantAndEquipmentNet": 33783000000,
        "Goodwill": 5717000000,
        "IntangibleAssetsNetExcludingGoodwill": 2298000000,
        "InventoryNet": 4855000000,
        "Liabilities" : 241272000000,
        "LiabilitiesAndStockholdersEquity" : 375319000000,
        "LiabilitiesCurrent" : 100814000000,
        "LongTermDebtCurrent" : 6496000000,
        "LongTermDebtNoncurrent" : 97207000000,
        "DeferredRevenueCurrent": 7548000000,
        "DeferredRevenueNoncurrent" : 2836000000,
        "OtherLiabilitiesNoncurrent": 40415000000,
        "CommonStocksIncludingAdditionalPaidInCapital": 35867,
        "RetainedEarningsAccumulatedDeficit": 98330000000,
        "StockholdersEquity": 134047000000
    
        ]
    ]
    
    func saveCashFlowsDataFrom(jsonResponseDict: JSONResponseDict){

        let newCashFlowStatement = CashFlowsStatement(context: self.managedContext)
        
        if let dictValue = jsonResponseDict[JSONReader.kSource] as? String{
            newCashFlowStatement.statementInfo?.source = dictValue
        }
        
        if let dictValue = jsonResponseDict[JSONReader.kCompany] as? String{
            newCashFlowStatement.statementInfo?.companyName = dictValue
        }
        
        if let dictValue = jsonResponseDict[JSONReader.kAccessionNumber] as? String{
            newCashFlowStatement.statementInfo?.accessionNumber = dictValue
            
        }
        
        if let dictValue = jsonResponseDict[JSONReader.kCIK] as? Int64{
            newCashFlowStatement.statementInfo?.cik = dictValue
            
        }
        
        if let dictValue = jsonResponseDict[JSONReader.kFilingDate] as? String{
            newCashFlowStatement.statementInfo?.filingDate = dictValue
            
        }
        
        guard let cashFlowStatementDict = jsonResponseDict[JSONReader.kData] as? CashFlowsDict else {
            fatalError("Error: failed to retreive balance sheet data from JSON response")
        }
        
        if let dictValue = cashFlowStatementDict[JSONReader.CashFlowStatementKeys.kCashAndCashEquivalentsAtCarryingValue]{
            
            newCashFlowStatement.cashAndCashEquivalentsAtCarryingValue = dictValue
        }

        //TODO: update properites of managed object models
        
        
        self.coreDataStack.saveContext()
        
    }
    
    func saveIncomeStatementDataFrom(jsonResponseDict: JSONResponseDict){
        
        let newIncomeStatement = IncomeStatement(context: self.managedContext)
        
        if let dictValue = jsonResponseDict[JSONReader.kSource] as? String{
            newIncomeStatement.statementInfo?.source = dictValue
            
        }
        
        
        if let dictValue = jsonResponseDict[JSONReader.kCompany] as? String{
            newIncomeStatement.statementInfo?.companyName = dictValue
        }
        
        if let dictValue = jsonResponseDict[JSONReader.kAccessionNumber] as? String{
            newIncomeStatement.statementInfo?.accessionNumber = dictValue
            
        }
        
        if let dictValue = jsonResponseDict[JSONReader.kCIK] as? Int64{
            newIncomeStatement.statementInfo?.cik = dictValue
            
        }
        
        if let dictValue = jsonResponseDict[JSONReader.kFilingDate] as? String{
            newIncomeStatement.statementInfo?.filingDate = dictValue
            
        }
        
        guard let incomeStatementDict = jsonResponseDict[JSONReader.kData] as? IncomeStatementDict else {
            fatalError("Error: failed to retreive balance sheet data from JSON response")
        }
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kSalesRevenueNet]{
            newIncomeStatement.salesRevenueNet = dictValue
        }
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kCostOfRevenue]{
            newIncomeStatement.costOfRevenue = dictValue
        }
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kGrossProfit]{
            newIncomeStatement.grossProfit = dictValue
        }
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kResearchAndDevelopmentExpense]{
            newIncomeStatement.researchAndDevelopmentExpense = dictValue
        }
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kGeneralAndAdministrativeExpense]{
            newIncomeStatement.generalAndAdministrativeExpense = dictValue
        }
        
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kSellingAndMarketingExpense]{
            newIncomeStatement.sellingAndMarketingExpense = dictValue
        }
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kGoodwillImpairmentLoss]{
            newIncomeStatement.goodWillImpairmentLoss = dictValue
        }
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kBusinessCombinationIntegrationRelatedCosts]{
            newIncomeStatement.businessCombinationIntegrationRelatedCosts = dictValue
        }
        
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kIncomeTaxExpenseBenefit]{
            newIncomeStatement.incomeTaxExpenseBenefit = dictValue
        }
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kOperatingIncomeLoss]{
            newIncomeStatement.operatingIncomeLoss = dictValue
        }
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kNetIncomeLoss]{
            newIncomeStatement.netIncomeLoss = dictValue
        }
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kNonoperatingIncomeExpense]{
            newIncomeStatement.nonOperatingIncomeExpense = dictValue
        }
        
        if let dictValue = incomeStatementDict[JSONReader.IncomeStatementKeys.kIncomeLossFromContinuingOperationsBeforeIncomeTaxesMinorityInterestAndIncomeLossFromEquityMethodInvestments]{
            newIncomeStatement.incomeLossFromContinuingOperationsBeforeIncomeTaxesMinorityInterestAndIncomeLossFromEquityMethodInvestments = dictValue
        }
        
        self.coreDataStack.saveContext()

        
    }
    
    func saveBalanceSheetDataFrom(jsonResponseDict: JSONResponseDict){
        
        let newBalanceSheet = BalanceSheet(context: self.managedContext)
        
        if let dictValue = jsonResponseDict[JSONReader.kSource] as? String{
            newBalanceSheet.statementInfo?.source = dictValue
        
        }
        
        
        if let dictValue = jsonResponseDict[JSONReader.kCompany] as? String{
            newBalanceSheet.statementInfo?.companyName = dictValue
        }
        
        if let dictValue = jsonResponseDict[JSONReader.kAccessionNumber] as? String{
            newBalanceSheet.statementInfo?.accessionNumber = dictValue
            
        }
        
        if let dictValue = jsonResponseDict[JSONReader.kCIK] as? Int64{
            newBalanceSheet.statementInfo?.cik = dictValue
            
        }
        
        if let dictValue = jsonResponseDict[JSONReader.kFilingDate] as? String{
            newBalanceSheet.statementInfo?.filingDate = dictValue
            
        }
        
        guard let balanceSheetDict = jsonResponseDict[JSONReader.kData] as? BalanceSheetDict else {
            fatalError("Error: failed to retreive balance sheet data from JSON response")
        }
        
        let balanceSheetSummary = BalanceSheetSummary(context: self.managedContext)
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kAssets]{
            
            balanceSheetSummary.totalAssets = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kAssetsCurrent]{
            
            balanceSheetSummary.totalCurrentAssets = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kLiabilities]{
            
            balanceSheetSummary.totalLiabilities = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kLiabilitiesCurrent]{
            
            balanceSheetSummary.totalCurrentLiabilities = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kStockholdersEquity]{
            
            balanceSheetSummary.totalStockHoldersEquity = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kLiabilitiesAndStockholdersEquity]{
            
            balanceSheetSummary.totalLiabilitiesAndStockHoldersEquity = dictValue
        }
        
        
        
        
        let currentAssets = CurrentAssets(context: self.managedContext)
        
        /** Set all the current assets  **/
        
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kAccountsReceivableNetCurrent]{
            
            currentAssets.accountsReceivableNetCurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kAvailableForSaleSecuritiesCurrent]{
            currentAssets.availableForSaleSecuritiesCurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kInventoryNet]{
            currentAssets.inventoryNet = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kOtherAssetsCurrent]{
            currentAssets.otherAssetsCurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kDeferredTaxAssetsLiabilitiesNetCurrent]{
            currentAssets.deferredTaxAssetsLiabilitiesNetCurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kCashCashEquivalentsAndShortTermInvestments]{
            currentAssets.cashCashEquivalentsAndShortTermInvestments = dictValue
        }
        
        /** Set all the noncurrent assets  **/
        
        let noncurrentAssets = NoncurrentAssets(context: self.managedContext)
        
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kFiniteLivedIntangibleAssetsNet]{
            noncurrentAssets.finiteLivedIntangibleAssetsNet = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kGoodwill]{
            noncurrentAssets.goodwill = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kLongTermInvestments]{
            noncurrentAssets.longTermInvestments = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kOtherAssetsCurrent]{
            noncurrentAssets.otherAssetsNoncurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kPropertyPlantAndEquipmentNet]{
            noncurrentAssets.propertyPlantAndEquipmentNet = dictValue
        }
        
        
        /** Set all the current liabilities  **/
        
        let currentLiabilities = CurrentLiabilities(context: self.managedContext)
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kAccountsPayableCurrent]{
            currentLiabilities.accountsPayableCurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kAccruedIncomeTaxesCurrent]{
            currentLiabilities.accruedIncomeTaxesCurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kDeferredRevenueCurrent]{
            currentLiabilities.deferredRevenueCurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kDepositsReceivedForSecuritiesLoanedAtCarryingValue]{
            currentLiabilities.depositsReceivedForSecuritiesLoanedAtCarryingValue = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kEmployeeRelatedLiabilitiesCurrent]{
            currentLiabilities.employeeRelatedLiabilitiesCurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kLongTermDebtCurrent]{
            currentLiabilities.longTermDebtCurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kOtherLiabilitiesCurrent]{
            currentLiabilities.otherLiabilitiesCurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kShortTermBorrowings]{
            currentLiabilities.shortTermBorrowings = dictValue
        }
        
        
        
        /** Set all the noncurrent liabilities  **/
        
        let noncurrentLiabilities = NoncurrentLiabilities(context: self.managedContext)
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kDeferredRevenueNoncurrent]{
            noncurrentLiabilities.deferredRevenueNoncurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kDeferredTaxLiabilitiesNoncurrent]{
            noncurrentLiabilities.deferredTaxLiabilitiesNoncurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kLongTermDebtNoncurrent]{
            noncurrentLiabilities.longTermDebtNoncurrent = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kOtherLiabilitiesNoncurrent]{
            noncurrentLiabilities.otherLiabilitiesNoncurrent = dictValue
        }
        
        
        
        
        let stockholdersEquity = StockHoldersEquity(context: self.managedContext)
        
        /** Set the stockholder's equity liabilities  **/
        
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kAccumulatedOtherComprehensiveIncomeLossNetOfTax]{
            stockholdersEquity.accumulatedOtherComprehensiveIncomeLossNetOfTax = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kCommonStocksIncludingAdditionalPaidInCapital]{
            stockholdersEquity.commonStocksIncludingAdditionalPaidInCapital = dictValue
        }
        
        if let dictValue = balanceSheetDict[JSONReader.BalanceSheetKeys.kRetainedEarningsAccumulatedDeficit]{
            stockholdersEquity.retainedEarningsAccumulatedDeficit = dictValue
        }
        
        newBalanceSheet.currentAssets = currentAssets
        newBalanceSheet.noncurrentAssets = noncurrentAssets
        newBalanceSheet.currentLiabilities = currentLiabilities
        newBalanceSheet.noncurrentLiabilities = noncurrentLiabilities
        newBalanceSheet.stockHoldersEquity = stockholdersEquity
        
        self.coreDataStack.saveContext()
    }
}


//MARK: ******** JSON Data Keys

extension JSONReader{
    
    
    //MARK: JSON Response Dictionary Keys
    
    static let kData = "Data"
    
    
    /** Company and Statement Attributes **/
    
    static let kCompany = "Company"
    static let kCIK = "CIK"
    static let kAccessionNumber = "AccessionNumber"
    static let kFilingDate = "FilingDate"
    static let kHTMLContent = "Content"
    static let kSource = "Source"
    static let kStatementName = "Name"
    
    
    /** Cash Flows Statement Summary Stats **/

    class CashFlowStatementKeys{
        static let kNetIncomeLoss = "NetIncomeLoss"
        static let kGoodwillImpairmentLoss = "GoodwillImpairmentLoss"
        static let kExcessTaxBenefitFromShareBasedCompensationOperatingActivities = "ExcessTaxBenefitFromShareBasedCompensationOperatingActivities"
        static let kDeferredIncomeTaxExpenseBenefit = "DeferredIncomeTaxExpenseBenefit"
        static let kIncreaseDecreaseInDeferredRevenue = "IncreaseDecreaseInDeferredRevenue"
        static let kRecognitionOfDeferredRevenue = "RecognitionOfDeferredRevenue"
        static let kIncreaseDecreaseInAccountsReceivable = "IncreaseDecreaseInAccountsReceivable"
        static let kIncreaseDecreaseInInventories = "IncreaseDecreaseInInventories"
        static let kIncreaseDecreaseInOtherCurrentAssets = "IncreaseDecreaseInOtherCurrentAssets"
        static let kIncreaseDecreaseInOtherNoncurrentAssets = "IncreaseDecreaseInOtherNoncurrentAssets"
        static let kIncreaseDecreaseInAccountsPayable = "IncreaseDecreaseInAccountsPayable"
        static let kIncreaseDecreaseInOtherCurrentLiabilities = "IncreaseDecreaseInOtherCurrentLiabilities"
        static let kIncreaseDecreaseInOtherNoncurrentLiabilities = "IncreaseDecreaseInOtherNoncurrentLiabilities"
        static let kNetCashProvidedByUsedInOperatingActivitiesContinuingOperations = "NetCashProvidedByUsedInOperatingActivitiesContinuingOperations"
        static let kProceedsFromRepaymentsOfShortTermDebtMaturingInThreeMonthsOrLess = "ProceedsFromRepaymentsOfShortTermDebtMaturingInThreeMonthsOrLess"
        static let kProceedsFromDebtMaturingInMoreThanThreeMonths = "ProceedsFromDebtMaturingInMoreThanThreeMonths"
        static let kRepaymentsOfDebtMaturingInMoreThanThreeMonths = "RepaymentsOfDebtMaturingInMoreThanThreeMonths"
        static let kProceedsFromIssuanceOfCommonStock = "ProceedsFromIssuanceOfCommonStock"
        static let kPaymentsForRepurchaseOfCommonStock = "PaymentsForRepurchaseOfCommonStock"
        static let kPaymentsOfDividendsCommonStock = "PaymentsOfDividendsCommonStock"
        static let kExcessTaxBenefitFromShareBasedCompensationFinancingActivities = "ExcessTaxBenefitFromShareBasedCompensationFinancingActivities"
        static let kProceedsFromPaymentsForOtherFinancingActivities = "ProceedsFromPaymentsForOtherFinancingActivities"
        static let kNetCashProvidedByUsedInFinancingActivitiesContinuingOperations = "NetCashProvidedByUsedInFinancingActivitiesContinuingOperations"
        static let kPaymentsToAcquirePropertyPlantAndEquipment = "PaymentsToAcquirePropertyPlantAndEquipment"
        static let kPaymentsToAcquireInvestments = "PaymentsToAcquireInvestments"
        static let kProceedsFromMaturitiesPrepaymentsAndCallsOfAvailableForSaleSecurities = "ProceedsFromMaturitiesPrepaymentsAndCallsOfAvailableForSaleSecurities"
        static let kProceedsFromSaleOfAvailableForSaleSecurities = "ProceedsFromSaleOfAvailableForSaleSecurities"
        static let kIncreaseDecreaseInCollateralHeldUnderSecuritiesLending = "IncreaseDecreaseInCollateralHeldUnderSecuritiesLending"
        static let kNetCashProvidedByUsedInInvestingActivitiesContinuingOperations = "NetCashProvidedByUsedInInvestingActivitiesContinuingOperations"
        static let kEffectOfExchangeRateOnCashAndCashEquivalents = "EffectOfExchangeRateOnCashAndCashEquivalents"
        static let kCashAndCashEquivalentsPeriodIncreaseDecrease = "CashAndCashEquivalentsPeriodIncreaseDecrease"
        static let kCashAndCashEquivalentsAtCarryingValue = "CashAndCashEquivalentsAtCarryingValue"
    
    }
    /** Income Statement Summary Stats **/
    
    class IncomeStatementKeys{
        static let kSalesRevenueNet = "SalesRevenueNet"
        static let kCostOfRevenue = "CostOfRevenue"
        static let kGrossProfit = "GrossProfit"
        static let kResearchAndDevelopmentExpense = "ResearchAndDevelopmentExpense"
        static let kSellingAndMarketingExpense = "SellingAndMarketingExpense"
        static let kGeneralAndAdministrativeExpense = "GeneralAndAdministrativeExpense"
        static let kGoodwillImpairmentLoss = "GoodwillImpairmentLoss"
        static let kBusinessCombinationIntegrationRelatedCosts = "BusinessCombinationIntegrationRelatedCosts"
        static let kOperatingIncomeLoss = "OperatingIncomeLoss"
        static let kNonoperatingIncomeExpense = "NonoperatingIncomeExpense"
        static let kIncomeLossFromContinuingOperationsBeforeIncomeTaxesMinorityInterestAndIncomeLossFromEquityMethodInvestments = "IncomeLossFromContinuingOperationsBeforeIncomeTaxesMinorityInterestAndIncomeLossFromEquityMethodInvestments"
        static let kIncomeTaxExpenseBenefit = "IncomeTaxExpenseBenefit"
        static let kNetIncomeLoss = "NetIncomeLoss"
        static let kEarningsPerShareBasic = "EarningsPerShareBasic"
        static let kEarningsPerShareDiluted = "EarningsPerShareDiluted"
        static let kWeightedAverageNumberOfSharesOutstandingBasic = "WeightedAverageNumberOfSharesOutstandingBasic"
        static let kWeightedAverageNumberOfDilutedSharesOutstanding = "WeightedAverageNumberOfDilutedSharesOutstanding"
        static let kCommonStockDividendsPerShareDeclared = "CommonStockDividendsPerShareDeclared"
    }
    /** Balance Sheet Summary Stats **/

    class BalanceSheetKeys{
        static let kAssets = "Assets"
        static let kAssetsCurrent = "AssetsCurrent"
        static let kLiabilitiesCurrent = "LiabilitiesCurrent"
        static let kLiabilities = "Liabilities"
        static let kLiabilitiesAndStockholdersEquity = "LiabilitiesAndStockholdersEquity"
        static let kStockholdersEquity = "StockholdersEquity"
    
        /** Current Assets **/
    
        static let kAvailableForSaleSecuritiesCurrent = "AvailableForSaleSecuritiesCurrent"
        static let kCashCashEquivalentsAndShortTermInvestments = "CashCashEquivalentsAndShortTermInvestments"
        static let kAccountsReceivableNetCurrent = "AccountsReceivableNetCurrent"
        static let kInventoryNet = "InventoryNet"
        static let kDeferredTaxAssetsLiabilitiesNetCurrent = "DeferredTaxAssetsLiabilitiesNetCurrent"
        static let kOtherAssetsCurrent = "OtherAssetsCurrent"
    
        /** Long-Term Assets **/
    
        static let kPropertyPlantAndEquipmentNet = "PropertyPlantAndEquipmentNet"
        static let kLongTermInvestments = "LongTermInvestments"
        static let kGoodwill = "Goodwill"
        static let kFiniteLivedIntangibleAssetsNet = "FiniteLivedIntangibleAssetsNet"
        static let kOtherAssetsNoncurrent = "OtherAssetsNoncurrent"
    
        /** Current Liabilities  **/
    
        static let kAccountsPayableCurrent = "AccountsPayableCurrent"
        static let kShortTermBorrowings = "ShortTermBorrowings"
        static let kLongTermDebtCurrent = "LongTermDebtCurrent"
        static let kEmployeeRelatedLiabilitiesCurrent = "EmployeeRelatedLiabilitiesCurrent"
        static let kAccruedIncomeTaxesCurrent = "AccruedIncomeTaxesCurrent"
        static let kDeferredRevenueCurrent = "DeferredRevenueCurrent"
        static let kDepositsReceivedForSecuritiesLoanedAtCarryingValue = "DepositsReceivedForSecuritiesLoanedAtCarryingValue"
        static let kOtherLiabilitiesCurrent = "OtherLiabilitiesCurrent"
    
    
        /** Long-term Liabilities  **/
        static let kLongTermDebtNoncurrent = "LongTermDebtNoncurrent"
        static let kDeferredRevenueNoncurrent = "DeferredRevenueNoncurrent"
        static let kDeferredTaxLiabilitiesNoncurrent = "DeferredTaxLiabilitiesNoncurrent"
        static let kOtherLiabilitiesNoncurrent = "OtherLiabilitiesNoncurrent"
    
    
        /** Stockholder's Equity  **/
    
        static let kCommonStocksIncludingAdditionalPaidInCapital = "CommonStocksIncludingAdditionalPaidInCapital"
        static let kRetainedEarningsAccumulatedDeficit = "RetainedEarningsAccumulatedDeficit"
        static let kAccumulatedOtherComprehensiveIncomeLossNetOfTax = "AccumulatedOtherComprehensiveIncomeLossNetOfTax"
    
    }

}
