//
//  QuandlAPIClient.swift
//  EDGAR Financials Helper
//
//  Created by Aleksander Makedonski on 12/18/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation

class QuandlAPIClient{
    
    typealias QuandlData = [String: Any]
    typealias QuandlCompletionHandler = (String, QuandlData?,NSError?) -> (Void)
    
    static let sharedClient = QuandlAPIClient()
    
    let kReasonForFailure = "ReasonForFailure"
    let kHttpStatusCode = "httpStatusCode"
    
    
    var session = URLSession.shared
    
    private init(){
        
    }
    
    var persistDataCompletionHandler: QuandlCompletionHandler = {
        
        companyName, jsonData, error in
        
        if(jsonData != nil){
            
            print("About to save JSON data to persistent store....")
            
            
            //TODO:  Use jsonReader to save data
            let jsonReader = JSONReader()
            jsonReader.saveQuandlData(forCompanyName: companyName, forJSONResponseDict: jsonData!)
            
            print("Data successfully saved!")
            
        } else {
            
            print("An error occurred while attempting to get the JSON data: \(error!)")
        }
        
    }
    
    var debugCompletionHandler: QuandlCompletionHandler = {
        
        companyName, jsonData, error in
        
        if(jsonData != nil){
            
            print("The following JSON data was obtained for company: \(companyName)....")
            print(jsonData!)
            
        } else {
            
            print("An error occurred while attempting to get the JSON data: \(error!)")
        }
    }
    
    
    
    
    
    func performDataPersistAPIRequest(with ticker: TickerSymbol, startDate: Date, endDate: Date){
        
        self.performURLRequest(withTicker: ticker, withStartDate: startDate, withEndDate: endDate, withJSONTaskCompletionHandler: self.persistDataCompletionHandler)
    }
    
    func performDebugAPIRequest(forTicker ticker: TickerSymbol, startDate: Date, endDate: Date){
        
        self.performURLRequest(withTicker: ticker, withStartDate: startDate, withEndDate: endDate, withJSONTaskCompletionHandler: self.debugCompletionHandler)
    }
    
    
    
    
    /** **/
    private func performURLRequest(withTicker ticker: TickerSymbol, withStartDate startDate: Date, withEndDate endDate: Date, withJSONTaskCompletionHandler completion: @escaping QuandlCompletionHandler){
        
        
        let quandlAPIRequest = QuandlAPIRequest(withTickerSymbol: ticker, forStartDate: startDate, forEndDate: endDate, withDataBaseCode: "WIKI", withReturnFormat: .json)
        
        let urlRequest = quandlAPIRequest.getURLRequest()
        
        
        performURLRequest(urlRequest: urlRequest,forCompanyName: ticker.rawValue, withCompletionHandler: completion)
    }
    
    
    private func performURLRequest(urlRequest: URLRequest, forCompanyName companyName: String, withCompletionHandler completion: @escaping QuandlCompletionHandler){
        
        let _ = session.dataTask(with: urlRequest, completionHandler: {
            
            data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                
                var userInfoDict = [String: Any]()
                
                userInfoDict[self.kReasonForFailure] = "Failed to connect to the server, no HTTP status code obtained"
                
                let error = NSError(domain: "APIRequestError", code: 0, userInfo: userInfoDict)
                
                completion(companyName,nil, error)
                
                return
            }
            
            
            guard httpResponse.statusCode == 200 else {
                
                
                var userInfoDict = [String: Any]()
                
                userInfoDict[self.kReasonForFailure] = "Connect to the server with a status code other than 200"
                
                userInfoDict[self.kHttpStatusCode] = httpResponse.statusCode
                
                let error = NSError(domain: "APIRequestError", code: 0, userInfo: userInfoDict)
                
                completion(companyName,nil, error)
                
                return
            }
            
            
            if(data != nil){
                
                do{
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! QuandlData
                    
                    completion(companyName,jsonData, nil)
                    
                } catch let error as NSError{
                    
                    completion(companyName,nil, error)
                    
                }
                
            } else {
                var userInfoDict = [String: Any]()
                
                userInfoDict[self.kReasonForFailure] = "Nil values obtained for JSON data"
                
                let error = NSError(domain: "APIRequestError", code: 0, userInfo: userInfoDict)
                
                
                completion(companyName,nil, error)
            }
            
        }).resume()
    }
}
