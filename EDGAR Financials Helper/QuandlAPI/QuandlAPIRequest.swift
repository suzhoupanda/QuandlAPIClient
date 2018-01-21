//
//  QuandlAPIRequest.swift
//  EDGAR Financials Helper
//
//  Created by Aleksander Makedonski on 12/18/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation

struct QuandlAPIRequest{
    
    let apiKey = "abfB68eZ25Jjs_xZfkadf"
    let baseURL = "https://www.quandl.com/api/v3/datasets"
    var startDate: Date
    var endDate: Date
    
    var dataBase_code = "WIKI"
    
    var tickerSymbol: TickerSymbol = .Fedex_Corp
    var returnFormat: ReturnFormat = .json


    enum ReturnFormat: String{
        case json
        case xml
        case csv
    }
    
    init(withTickerSymbol tickerSymbol: TickerSymbol, forStartDate startDate: Date, forEndDate endDate: Date, withDataBaseCode dataBaseCode: String = "WIKI", withReturnFormat returnFormat: ReturnFormat = .json){
        
        self.returnFormat = returnFormat
        self.dataBase_code = dataBaseCode
        self.tickerSymbol = tickerSymbol
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func getURLRequest() -> URLRequest{
        
        
        let urlString = getDataRequestURLString()
        
        let url = URL(string: urlString)!
        
        return URLRequest(url: url)
    }
    
    func getMetaDataRequestURL() -> String{
    
        return "https://www.quandl.com/api/v3/datasets/\(self.dataBase_code)/\(self.tickerSymbol)/metadata.\(returnFormat.rawValue)"
    }
    
    func getDataRequestURLString() -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        let startDateStr = dateFormatter.string(from: self.startDate)
        let endDateStr = dateFormatter.string(from: self.endDate)
        
        let urlWithRequestParameters = "\(baseURL)/\(dataBase_code)/\(self.tickerSymbol.rawValue)/data.\(returnFormat.rawValue)?start_date=\(startDateStr)&end_date=\(endDateStr)&api_key=\(apiKey)"
        
        return urlWithRequestParameters
    }
}
