//
//  BalanceSheetStack.swift
//  EDGAR Financials Helper
//
//  Created by Aleksander Makedonski on 12/17/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation
import CoreData

class DataFetcher{
    
   
    var coreDataStack: CoreDataStack

    var managedContext: NSManagedObjectContext{
        return coreDataStack.managedContext
    }
    
    init(withModelName modelName: String){
        self.coreDataStack = CoreDataStack(withModelName: modelName)
    }
    
    init(){
        self.coreDataStack = CoreDataStack(withModelName: "EDGAR_Financials_Helper")
    }
    
    typealias MinMaxFloat = (Float?,Float?)
    typealias MinMaxInt64 = (Int64?,Int64?)
    typealias MinMaxInt = (Int?,Int?)
    typealias MinMaxDouble = (Double?,Double?)

    
    lazy var dateFormatter: DateFormatter = {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter
    }()
    
  
    
   
    
    enum FunctionType: String{
        case average = "average:"
        case maximum = "max:"
        case minimum = "min:"
    }
    
    enum StockQuoteKeyPath{
        case High
        case Low
        case Open
        case Close
        case Volume
        case Adjusted_Open
        case Adjusted_Close
        case Adjusted_High
        case Adjusted_Low
        case Adjusted_Volume
        case Ex_Dividend
        
        

 
        
        func attributeType() -> NSAttributeType{
            switch self {
            case .Volume,.Adjusted_Volume,.Ex_Dividend:
                return .integer64AttributeType
            default:
                return .floatAttributeType
            }
            
        
        }
        
        func keyPath() -> String{
            switch self {
            case .High:
                return #keyPath(DailyQuoteSummary.high)
            case .Low:
                return #keyPath(DailyQuoteSummary.low)
            case .Close:
                return #keyPath(DailyQuoteSummary.close)
            case .Open:
                return #keyPath(DailyQuoteSummary.open)
            case .Volume:
                return #keyPath(DailyQuoteSummary.volume)
            case .Adjusted_Close:
                return #keyPath(DailyQuoteSummary.adjustedClose)
            case .Adjusted_Open:
                return #keyPath(DailyQuoteSummary.adjustedOpen)
            case .Adjusted_High:
                return #keyPath(DailyQuoteSummary.adjustedHigh)
            case .Adjusted_Low:
                return #keyPath(DailyQuoteSummary.adjustedLow)
            case .Adjusted_Volume:
                return #keyPath(DailyQuoteSummary.adjustedVolume)
            case .Ex_Dividend:
                return #keyPath(DailyQuoteSummary.exDividend)
          
            }
        }
        
        
    
        
    }
    
    
    func fetchAllDailyQuoteSummaryData(forTicker tickerSymbol: TickerSymbol) -> [DailyQuoteSummary]?{
        
        let fetchRequest: NSFetchRequest<DailyQuoteSummary> = DailyQuoteSummary.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "%K LIKE %@", argumentArray: [#keyPath(DailyQuoteSummary.stockQuotePeriod.companyName),tickerSymbol.rawValue])
        
        do {
            
            let allSummaryData = try self.coreDataStack.managedContext.fetch(fetchRequest)
            
            return allSummaryData
            
        } catch let error as NSError {
            
            print("Error: unable to complete fetch request with error: \(error.localizedDescription)")
            return nil
            
        }
    }
    
    
    
    /** Fetches stock quote data for a ticker symbol beginning with a specified letter and for a given date range by taking in string values for the date input parameters **/
    
    func fetchDailyQuoteStatisticsDataFrom(beginsWithLetter letter: String, startDate: String?, to endDate: String?) -> [DailyQuoteSummary]?{
        

        var startDateStr: String = String()
        var endDateStr: String = String()
        
        if let date = startDate{
            startDateStr = date
        }
        
        if let date = endDate{
            endDateStr = date
        }
        
        let sDate = dateFormatter.date(from: startDateStr)
        let eDate = dateFormatter.date(from: endDateStr)
        
         return fetchDailyQuoteStatisticsDataFrom(beginsWithLetter: letter, startDate: sDate, to: eDate)
    }
    
    /** Fetches stock quotes for ticker symbols that begin with, end with, or contain the letter passed into the corresponding parameters **/
    
    func getStockQuotesForTickerSymbolThat(beginsWith: String?, endsWith: String?, contains: String?) -> [DailyQuoteSummary]?{
        
        
        var predicates = [NSPredicate]()
        
        if beginsWith != nil{
            let predicate = NSPredicate(format: "%K BEGINSWITH[cd] %@", #keyPath(DailyQuoteSummary.stockQuotePeriod.companyName),beginsWith!)
            predicates.append(predicate)
        }
        
        if endsWith != nil{
            let predicate = NSPredicate(format: "%K ENDSWITH[cd] %@", #keyPath(DailyQuoteSummary.stockQuotePeriod.companyName),endsWith!)
            predicates.append(predicate)
        }
        
        if contains != nil{
            let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(DailyQuoteSummary.stockQuotePeriod.companyName),contains!)
            predicates.append(predicate)
        }
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let fetchRequest: NSFetchRequest<DailyQuoteSummary> = DailyQuoteSummary.fetchRequest()
        fetchRequest.predicate = compoundPredicate
        
        do {
            
            let quoteData = try self.coreDataStack.managedContext.fetch(fetchRequest)
            
            return quoteData
        } catch let error as NSError {
            print("Error: \(error.localizedFailureReason), \(error.localizedDescription)")
            return nil
        }
    }
    
    /** Fetches all the daily stock quotes for a particular ticker symbol and within a date range defined by the starting and ending dates passed into the corresponding parameters **/
    
    func getStockQuotesWithinDateRangeFor(tickerSymbol: TickerSymbol, fromDate: Date, toDate: Date) -> [DailyQuoteSummary]?{
        
        let fetchRequest: NSFetchRequest<DailyQuoteSummary> = DailyQuoteSummary.fetchRequest()
        
        let startDate = fromDate as NSDate
        let endDate = toDate as NSDate
        
        fetchRequest.predicate = NSPredicate(format: "(%K LIKE %@) AND (%K > %@) AND (%K < %@)", #keyPath(DailyQuoteSummary.stockQuotePeriod.companyName),
             tickerSymbol.rawValue,
             #keyPath(DailyQuoteSummary.date),
            startDate,
            #keyPath(DailyQuoteSummary.date),
            endDate
            )
        
        
        do {
            let dailyQuoteSummaries = try self.coreDataStack.managedContext.fetch(fetchRequest)
            return dailyQuoteSummaries
            
        } catch let error as NSError {
            print("Error: unable to perform fetch request due to error \(String(describing: error.localizedFailureReason)),\(error.localizedDescription)")
            return nil
        }
    }
    
    func performTickerSymbolValidationFetch() -> Bool{
        
        let fetchRequest: NSFetchRequest<DailyQuoteSummary> = DailyQuoteSummary.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K IN %@", #keyPath(DailyQuoteSummary.stockQuotePeriod.companyName),TickerSymbol.allTickerSymbols)
        do {
            let numberOfResults = try self.coreDataStack.managedContext.count(for: fetchRequest)
           
            return numberOfResults > 0
            
        } catch let error as NSError {
            print("Error: error occurred while performing fetch request: \(error.localizedDescription),\(String(describing: error.localizedFailureReason))")
            return false
        }
    }
    
    /** Fetches the stock quote data for all ticker symbols beginning with a specified letter and from a given start date to a given end date, the beginning letter can be specificied for th ticker symbol as well **/
    
    func fetchDailyQuoteStatisticsDataFrom(beginsWithLetter letter: String, startDate: Date?, to endDate: Date?) -> [DailyQuoteSummary]?{
        
        if(letter.characters.count > 1){
            print("Error: could not perform fetch request, since only a single letter may be passed in for the letter parameter")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<DailyQuoteSummary> = DailyQuoteSummary.fetchRequest()
        
        let companyNameKeyPath = #keyPath(DailyQuoteSummary.stockQuotePeriod.companyName)
        let dateKeyPath = #keyPath(DailyQuoteSummary.date)
        
        var formatString = "(%K BEGINSWITH[cd] %@)"
        
        var args: [Any] = [
            companyNameKeyPath,
            letter
        ]
        
        
        if startDate != nil{
            formatString.append("AND (%K > %@)")

            args.append(contentsOf: [
                dateKeyPath,
                startDate!
                ])
        }
        
        if endDate != nil{
            formatString.append("AND (%K < %@)")
           
            args.append(contentsOf: [
                dateKeyPath,
                endDate!
                ])
        }
        
       
        fetchRequest.predicate = NSPredicate(format: formatString, argumentArray: args)
        
        do {
            let dailyQuoteData = try self.coreDataStack.managedContext.fetch(fetchRequest)
            
            return dailyQuoteData
            
        } catch let error as NSError {
            print("Error: failed to fetch date due to error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchDailyQuoteStatData(forTicker tickerSymbol: TickerSymbol, forFunctionType functionType: FunctionType, forKeyPath stockQuoteKeyPath: StockQuoteKeyPath) -> Float?{
        
        let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "DailyQuoteSummary")
        
        fetchRequest.resultType = .dictionaryResultType

        fetchRequest.predicate = NSPredicate(format: "%K LIKE %@", argumentArray: [#keyPath(DailyQuoteSummary.stockQuotePeriod.companyName),tickerSymbol.rawValue])
        
        
        
        let resultsDictKey = "\(functionType.rawValue)-\(stockQuoteKeyPath.keyPath())"
        
        let expressionDesc = NSExpressionDescription()
        expressionDesc.name = resultsDictKey
        
        let keyPathExpression = NSExpression(forKeyPath: stockQuoteKeyPath.keyPath())
        expressionDesc.expression = NSExpression(forFunction: functionType.rawValue, arguments: [keyPathExpression])
        expressionDesc.expressionResultType = stockQuoteKeyPath.attributeType()
        
        fetchRequest.propertiesToFetch = [expressionDesc]
        
        do {
            let dictionaries = try self.coreDataStack.managedContext.fetch(fetchRequest)
            
            let statsDict = dictionaries.first!
            
            
            return statsDict[resultsDictKey] as? Float
            
        } catch let error as NSError {
            print("Error occurred: unable to fetch data due to error: \(error.localizedDescription)")
            return nil
        }
        
    }
    
    func getStockQuoteSummariesWithAttributeRanges(forTickerSymbol tickerSymbol: TickerSymbol, forMinMaxOpen minMaxOpen: MinMaxFloat?, forMinMaxClose minMaxClose: MinMaxFloat?, forMinMaxHigh minMaxHigh: MinMaxFloat?, forMinMaxLow minMaxLow: MinMaxFloat?, forMinMaxAdjustedOpen minMaxAdjOpen: MinMaxFloat?, forMinMaxAdjustedClose minMaxAdjClose: MinMaxFloat?, forMinMaxAdjustedHigh minMaxAdjHigh: MinMaxFloat?, forMinMaxAdjustedLow minMaxAdjLow: MinMaxFloat?, forMinMaxVolume minMaxVolume: MinMaxInt64?, forMinMaxAdjusedVolume minMaxAdjustedVolume: MinMaxInt64?, forMinMaxExDividend minMaxExDividend: MinMaxInt64?) -> [DailyQuoteSummary]?{
        
        if let stockQuoteSummaries = fetchAllDailyQuoteSummaryData(forTicker: tickerSymbol){
            
            return stockQuoteSummaries.filter({
                
                stockQuoteSummary in
                
                var filterConditions = [Bool]()
                
                filterConditions += getFilterConditions(forAttribute: stockQuoteSummary.adjustedHigh, forMinMaxTuple: minMaxAdjHigh)
                
                filterConditions += getFilterConditions(forAttribute: stockQuoteSummary.adjustedLow, forMinMaxTuple: minMaxAdjLow)
                
                filterConditions += getFilterConditions(forAttribute: stockQuoteSummary.adjustedOpen, forMinMaxTuple: minMaxAdjOpen)
                
                
                filterConditions += getFilterConditions(forAttribute: stockQuoteSummary.adjustedClose, forMinMaxTuple: minMaxAdjClose)
                
                
                filterConditions += getFilterConditions(forAttribute: stockQuoteSummary.low, forMinMaxTuple: minMaxLow)
                
                
                filterConditions += getFilterConditions(forAttribute: stockQuoteSummary.high, forMinMaxTuple: minMaxHigh)
                
                filterConditions += getFilterConditions(forAttribute: stockQuoteSummary.close, forMinMaxTuple: minMaxClose)
                
                
                filterConditions += getFilterConditions(forAttribute: stockQuoteSummary.open, forMinMaxTuple: minMaxOpen)
                
                
                filterConditions += getFilterConditions(forAttribute: stockQuoteSummary.volume, forMinMaxTuple: minMaxVolume)
                
                filterConditions += getFilterConditions(forAttribute: stockQuoteSummary.adjustedVolume, forMinMaxTuple: minMaxAdjustedVolume)
                
                filterConditions += getFilterConditions(forAttribute: stockQuoteSummary.exDividend, forMinMaxTuple: minMaxExDividend)
                
                return filterConditions.reduce(true, {$0 && $1 })
                
            })
        }
            
        
        
        return nil
    }
    
    
    
    private func getFilterConditions<T: Comparable>(forAttribute attribute: T, forMinMaxTuple minMaxTuple: (T?,T?)?) -> [Bool]{
        
        var filterConditions = [Bool]()
        
        if let minMaxTuple = minMaxTuple{
            if let minValue = minMaxTuple.0{
                filterConditions.append(
                    attribute > minValue
                )
            }
            
            if let maxValue = minMaxTuple.1{
                filterConditions.append(
                    attribute < maxValue
                )
            }
            
        }
        
        return filterConditions
    }

    func fetchAllDailyQuoteSummaryData() -> [DailyQuoteSummary]?{
        
        do {
            let fetchRequest: NSFetchRequest<DailyQuoteSummary> = DailyQuoteSummary.fetchRequest()
            
            let allDailyQuoteSummaries = try self.coreDataStack.managedContext.fetch(fetchRequest)
            
            return allDailyQuoteSummaries
            
        } catch let error as NSError {
            print("Failed to fetch data: error occurred while attempting to fetch all of the daily quote summary data: \(error.localizedDescription),\(error.localizedFailureReason)")
            return nil
        }
        
    }

    typealias BalanceSheetComponentSums = (
        totalCurrentAssets: Double,
        totalAssets: Double,
        totalCurrentLiabilities: Double,
        totalLiabilities: Double,
        totalStockHoldersEquity: Double,
        totalLiabilitiesAndStockHoldersEquity: Double
    )
    
    typealias BalanceSheetComponentMaximums = (
        maxCurrentAssets: Double,
        maxAssets: Double,
        maxCurrentLiabilities: Double,
        maxLiabilities: Double,
        maxStockHoldersEquity: Double,
        maxLiabilitiesAndStockHoldersEquity: Double
    )
    
    typealias BalanceSheetComponentMinimums = (
        minCurrentAssets: Double,
        minAssets: Double,
        minCurrentLiabilities: Double,
        minLiabilities: Double,
        minStockHoldersEquity: Double,
        minLiabilitiesAndStockHoldersEquity: Double
    )
    
    typealias BalanceSheetComponentAverages = (
        avgCurrentAssets: Double,
        avgAssets: Double,
        avgCurrentLiabilities: Double,
        avgLiabilities: Double,
        avgStockHoldersEquity: Double,
        avgLiabilitiesAndStockHoldersEquity: Double
    )
    

    // MARK: - Core Data Saving support
    
    func fetchFirstEdgarBalanceSheet() -> BalanceSheet?{
        
        let fetchRequest: NSFetchRequest<BalanceSheet> = BalanceSheet.fetchRequest()
        
        do {
            
            let balanceSheets = try self.managedContext.fetch(fetchRequest)
            
            return balanceSheets.first
            
        } catch let error as NSError {
            print("Failed to fetch balance sheets due to error: \(error.localizedDescription)")
            return nil
        }
        
        return nil
    }
    
    lazy var smallAssetPredicate: NSPredicate = {
        return NSPredicate(format: "%K < %d", #keyPath(BalanceSheet.balanceSheetSummary.totalAssets),1000000)
    }()
    
    lazy var mediumAssetsPredicate: NSPredicate = {
        return NSPredicate(format: "(%K < %d) AND (%K > %d)", #keyPath(BalanceSheet.balanceSheetSummary.totalAssets),1000000000,#keyPath(BalanceSheet.balanceSheetSummary.totalAssets),1000000)
    }()
    
    lazy var largeAssetsPredicate: NSPredicate = {
        return NSPredicate(format: "%K > %d", #keyPath(BalanceSheet.balanceSheetSummary.totalAssets),1000000000)
    }()
    
    
    func clearAllBalanceSheets(){
        
        let fetchRequest: NSFetchRequest<BalanceSheet> = BalanceSheet.fetchRequest()
        
        do {
            let allBalanceSheets = try self.managedContext.fetch(fetchRequest)
            
            try allBalanceSheets.forEach({
                print("Clearing another entry...")
                try self.managedContext.delete($0)
            })
            
            print("All balance sheet data finished clearing.")
            
            
        } catch let error as NSError {
            print("Error occurred: \(error)")
        }
    }
    
    
    func getBalanceSheetAverages() -> BalanceSheetComponentAverages{
        
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "BalanceSheet")
        fetchRequest.resultType = .dictionaryResultType
        
        let avgTotalAssetsDesc = getExpression(withName: "avgTotalAssets", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalAssets), forFunctionName: "average:")
        
        let avgCurrentAssetsDesc = getExpression(withName: "avgCurrentAssets", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalCurrentAssets), forFunctionName: "average:")
        
        let avgCurrentLiabilitiesDesc = getExpression(withName: "avgCurrentLiabilities", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalCurrentLiabilities), forFunctionName: "average:")
        
        
        let avgTotalLiabilitiesDesc = getExpression(withName: "avgTotalLiabilitiesDesc", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalLiabilities), forFunctionName: "average:")
        
        let avgTotalStockHoldersEquityDesc = getExpression(withName: "avgTotalStockHoldersEquityDesc", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalStockHoldersEquity), forFunctionName: "average:")
        
        
        let avgTotalLiabilitiesAndStockHoldersEquityDesc = getExpression(withName: "avgTotalLiabilitiesAndStockHoldersEquityDesc", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalLiabilitiesAndStockHoldersEquity), forFunctionName: "average:")
        
        
        fetchRequest.propertiesToFetch = [avgTotalAssetsDesc,avgCurrentAssetsDesc,avgCurrentLiabilitiesDesc,avgTotalLiabilitiesDesc,avgTotalStockHoldersEquityDesc,avgTotalLiabilitiesAndStockHoldersEquityDesc]
        
        
        do {
            
            //TODO
            
        } catch let error as NSError {
            
        }
        
        return DataFetcher.BalanceSheetComponentZeroAverages
    }
    
    
    func getBalanceSheetMinimums() -> BalanceSheetComponentMinimums{
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "BalanceSheet")
        fetchRequest.resultType = .dictionaryResultType
        
        let minTotalAssetsDesc = getExpression(withName: "minTotalAssets", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalAssets), forFunctionName: "min:")
        
        let minCurrentAssetsDesc = getExpression(withName: "minCurrentAssets", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalCurrentAssets) , forFunctionName: "min:")
        
        let minCurrentLiabilitiesDesc = getExpression(withName: "minCurrentLiabilities", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalCurrentLiabilities), forFunctionName: "min:")
        
        let minTotalLiabilitiesDesc = getExpression(withName: "minTotalLiabilities", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalLiabilities), forFunctionName: "min:")
        
        let minTotalStockHoldersEquityDesc = getExpression(withName: "minTotalStockHoldersEquity", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalStockHoldersEquity), forFunctionName: "min:")
        
        let minTotalLiabilitiesAndStockHoldersEquityDesc = getExpression(withName: "minTotalStockHoldersEquityAndLiabilities", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalLiabilitiesAndStockHoldersEquity), forFunctionName: "min:")
        
        do {
            
            //TODO
            
        } catch let error as NSError {
            
            
        }
        
        fetchRequest.propertiesToFetch = [minTotalAssetsDesc,minCurrentAssetsDesc,minCurrentLiabilitiesDesc,minTotalLiabilitiesDesc,minTotalStockHoldersEquityDesc,minTotalLiabilitiesAndStockHoldersEquityDesc]
        
        return DataFetcher.BalanceSheetComponentZeroMins
    }
    
    func getBalanceSheetMaximums() -> BalanceSheetComponentMaximums{
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "BalanceSheet")
        fetchRequest.resultType = .dictionaryResultType
        
        let maxTotalAssetsDesc = getExpression(withName: "maxTotalAssets", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalAssets), forFunctionName: "max:")
        
        
        let maxCurrentAssetsDesc = getExpression(withName: "maxCurrentAssets", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalCurrentAssets), forFunctionName: "max:")
        
        let maxCurrentLiabilitiesDesc = getExpression(withName: "maxCurrentLiabilities", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalCurrentLiabilities), forFunctionName: "max:")
        
        
        let maxTotalLiabilitiesDesc = getExpression(withName: "maxTotalLiabilities", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalLiabilities), forFunctionName: "max:")
        
        
        let maxTotalStockHoldersEquityDesc = getExpression(withName: "maxTotalStockHoldersEquity", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalStockHoldersEquity), forFunctionName: "max:")
        
        let maxTotalLiabilitiesAndStockHoldersEquityDesc = getExpression(withName: "maxTotalLiabilitiesAndStockHoldersEquity", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalLiabilitiesAndStockHoldersEquity), forFunctionName: "max:")
        
        fetchRequest.propertiesToFetch = [maxTotalAssetsDesc,maxCurrentAssetsDesc,maxCurrentLiabilitiesDesc,maxTotalLiabilitiesDesc,maxTotalStockHoldersEquityDesc,maxTotalLiabilitiesAndStockHoldersEquityDesc]
        
        do {
            let results =
                try self.managedContext.fetch(fetchRequest)
            let resultDict = results.first!
            
            let maxAssets = resultDict["maxTotalAssets"]! as! Double
            let maxCurrentAssets = resultDict["maxCurrentAssets"]! as! Double
            
            let maxLiabilitiesAndStockHoldersEquity = resultDict["maxTotalLiabilitiesAndStockHoldersEquity"]! as! Double
            let maxLiabilities = resultDict["maxTotalLiabilities"]! as! Double
            let maxStockHoldersEquity = resultDict["maxTotalStockHoldersEquity"]! as! Double
            let maxCurrentLiabilties = resultDict["maxCurrentLiabilities"]! as! Double
            
            return (
                maxCurrentAssets: maxCurrentAssets,
                maxAssets: maxAssets,
                maxCurrentLiabilities: maxCurrentLiabilties,
                maxLiabilities: maxLiabilities,
                maxStockHoldersEquity: maxStockHoldersEquity,
                maxLiabilitiesAndStockHoldersEquity: maxLiabilitiesAndStockHoldersEquity
            )
            
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
        
        return DataFetcher.BalanceSheetComponentZeroMaxs
    }
    
    func getBalanceSheetComponentSums() -> BalanceSheetComponentSums{
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "BalanceSheet")
        fetchRequest.resultType = .dictionaryResultType
        
        let sumTotalAssetsDesc = getExpression(withName: "sumTotalAssets", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalAssets), forFunctionName: "sum:")
        
        let sumCurrentAssetsDesc = getExpression(withName: "sumCurrentAssets", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalCurrentAssets), forFunctionName: "sum:")
        
        let sumCurrentLiabilitiesDesc = getExpression(withName: "sumCurrentLiabilities", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalCurrentLiabilities), forFunctionName: "sum:")
        
        let sumTotalLiabilitiesDesc = getExpression(withName: "sumTotalLiabilities", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalLiabilities), forFunctionName: "sum:")
        
        
        let sumTotalStockHoldersEquityDesc = getExpression(withName: "sumTotalStockHoldersEquity", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalStockHoldersEquity), forFunctionName: "sum:")
        
        let sumTotalLiabilitiesAndStockHoldersEquityDesc = getExpression(withName: "sumTotalLiabilitiesAndStockHoldersEquity", withKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalLiabilitiesAndStockHoldersEquity), forFunctionName: "sum:")
        
        fetchRequest.propertiesToFetch = [sumTotalAssetsDesc,sumCurrentAssetsDesc,sumCurrentLiabilitiesDesc,sumTotalLiabilitiesDesc,sumTotalStockHoldersEquityDesc,sumTotalLiabilitiesAndStockHoldersEquityDesc]
        
        do {
            let results =
                try self.managedContext.fetch(fetchRequest)
            let resultDict = results.first!
            
            let totalAssets = resultDict["sumTotalAssets"]! as! Double
            let totalCurrentAssets = resultDict["sumCurrentAssets"]! as! Double
            
            let totalLiabilitiesAndStockHolderEquity = resultDict["sumTotalLiabilitiesAndStockHoldersEquity"]! as! Double
            let totalLiabilities = resultDict["sumTotalLiabilities"]! as! Double
            let totalStockHoldersEquity = resultDict["sumTotalStockHoldersEquity"]! as! Double
            let totalCurrentLiabilities = resultDict["sumCurrentLiabilities"]! as! Double
            
            return (
                totalCurrentAssets: totalCurrentAssets,
                totalAssets: totalAssets,
                totalCurrentLiabilities: totalCurrentLiabilities,
                totalLiabilities: totalLiabilities,
                totalStockHoldersEquity: totalStockHoldersEquity,
                totalLiabilitiesAndStockHoldersEquity: totalLiabilitiesAndStockHolderEquity
            )
            
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
        
        return DataFetcher.BalanceSheetComponentZeroSums
        
    }
    
    func getTotalNumberOfLargeAssetCompanies() -> Int{
        
        return getTotalNumberOfBalanceSheets(withPredicate: self.largeAssetsPredicate)
    }
    
    func getTotalNumberOfMediumAssetCompanies() -> Int{
        return getTotalNumberOfBalanceSheets(withPredicate: self.mediumAssetsPredicate)
    }
    
    func getTotalNumberOfSmallAssetCompanies() -> Int{
        return getTotalNumberOfBalanceSheets(withPredicate: self.smallAssetPredicate)
    }
    
    func getTotalNumberOfCompanies() -> Int{
        
        return getTotalNumberOfBalanceSheets(withPredicate: nil)
    }
    
    func getTotalNumberOfBalanceSheets(withPredicate predicate: NSPredicate?) -> Int{
        
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "BalanceSheet")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = predicate
        
        do {
            
            let count = try self.managedContext.count(for: fetchRequest)
            
            return count
            
        } catch let error as NSError {
            print("Error occurred while fetching data: \(error.localizedDescription), \(error.localizedFailureReason)")
            
        }
        
        return 0
    }
    
    
    private func getExpression(withName name: String, withKeyPath keyPath: String, forFunctionName functionName: String) -> NSExpressionDescription{
        
        let expDescription = NSExpressionDescription()
        expDescription.name = name
        
        let nestedExpression = NSExpression(forKeyPath: #keyPath(BalanceSheet.balanceSheetSummary.totalAssets))
        
        expDescription.expression = NSExpression(forFunction: functionName, arguments: [nestedExpression])
        
        expDescription.expressionResultType = .doubleAttributeType
        
        return expDescription
    }

    
}


extension DataFetcher{
    
    static let BalanceSheetComponentZeroSums: BalanceSheetComponentSums = (
        totalCurrentAssets: 0.00,
        totalAssets: 0.00,
        totalCurrentLiabilities: 0.00,
        totalLiabilities: 0.00,
        totalStockHoldersEquity: 0.00,
        totalLiabilitiesAndStockHoldersEquity: 0.00
    )
    
    static let BalanceSheetComponentZeroMaxs: BalanceSheetComponentMaximums = (
        maxCurrentAssets: 0.00,
        maxAssets: 0.00,
        maxCurrentLiabilities: 0.00,
        maxLiabilities: 0.00,
        maxStockHoldersEquity: 0.00,
        maxLiabilitiesAndStockHoldersEquity: 0.00
    )
    
    static let BalanceSheetComponentZeroMins: BalanceSheetComponentMinimums =  (
        minCurrentAssets: 0.00,
        minAssets: 0.00,
        minCurrentLiabilities: 0.00,
        minLiabilities: 0.00,
        minStockHoldersEquity: 0.00,
        minLiabilitiesAndStockHoldersEquity: 0.00
    )
    
    static let BalanceSheetComponentZeroAverages: BalanceSheetComponentAverages = (
        avgCurrentAssets: 0.00,
        avgAssets: 0.00,
        avgCurrentLiabilities: 0.00,
        avgLiabilities: 0.00,
        avgStockHoldersEquity: 0.00,
        avgLiabilitiesAndStockHoldersEquity: 0.00
    )
    
}
