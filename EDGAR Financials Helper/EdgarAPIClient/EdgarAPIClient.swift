//
//  EdgarAPIClient.swift
//  EDGAR Financials Helper
//
//  Created by Aleksander Makedonski on 12/15/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation

/**
 Use an array of download tasks; increment the current index and resume the current download task each time a task is completed
 **/

struct EdgarAPIRequest{
    
    enum APIEndpoint: String{
        case BalanceSheet = "balancesheet"
        case IncomeStatement = "income"
        case CashFlows = "cashflows"
        case FinancialRatios = "ratios"
    }
    
    let baseURL = "https://services.last10k.com/v1/company"
    let primaryKey = "1aadfkd99fla19cfa80fadfkj88096fc9cbd366fadfkjld8"
    let secondaryKey = "badlkjf888935kadfkj;ad"
    let headerFieldKey = "Ocp-Apim-Subscription-Key"
    
    var ticker: String
    var endpoint: APIEndpoint
    var formType: String?
    var filingOrder: String?
    
    init(withTicker companyTicker: String, andWithEndpoint apiEndpoint: APIEndpoint, withFormType formType: String?, withFilingOrder filingOrder: String?){
        
        self.ticker = companyTicker
        self.endpoint = apiEndpoint
        self.formType = formType
        self.filingOrder = filingOrder
        
    }
    
    func getURLRequest() -> URLRequest{
        
        let urlString = getURL()
        let url = URL(string: urlString)!
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.setValue(self.primaryKey, forHTTPHeaderField: self.headerFieldKey)
        
        return urlRequest
    }
    
    private func getURL() -> String{
        
        var url = "\(self.baseURL)/\(self.ticker)/\(self.endpoint.rawValue)"
        
        switch (self.formType,self.filingOrder) {
        case (.some,.some):
            url = url.appending("/?\(formType!)&\(filingOrder!)")
            break
        case (.some,.none):
            url = url.appending("/?\(formType!)")
            break
        case (.none,.some):
            url = url.appending("/?\(filingOrder!)")
            break
        default:
            break
        }
        
        return url
        
        
    }

    
}
class EdgarAPIClient{
    
    typealias JSONData = [String: Any]
    typealias JSONTaskCompletionHandler = (JSONData?,NSError?) -> (Void)
    
    static let sharedClient = EdgarAPIClient()
    
    let kReasonForFailure = "ReasonForFailure"
    let kHttpStatusCode = "httpStatusCode"
    
   
    var session = URLSession.shared
    
    private init(){
        
    }
    
    var persistDataCompletionHandler: JSONTaskCompletionHandler = {
        
        jsonData, error in
        
        if(jsonData != nil){
            
            print("About to save JSON data to persistent store....")
            
            
            //Use jsonReader to save data
            
            let jsonReader = JSONReader()
            
            jsonReader.saveData(forJSONResponseDict: jsonData!)
            
            print("Data successfully saved!")
            
        } else {
            
            print("An error occurred while attempting to get the JSON data: \(error!)")
        }
        
    }
    
    var debugCompletionHandler: JSONTaskCompletionHandler = {
        
        jsonData, error in
        
        if(jsonData != nil){
            
            print("The following JSON data was obtained....")
            print(jsonData!)
            
        } else {
            
            print("An error occurred while attempting to get the JSON data: \(error!)")
        }
    }
    
  
    
    func perforumDataPersistenceURLRequest(forTicker ticker: String, forEndpoint endpoint: EdgarAPIRequest.APIEndpoint, forFormType formType: String?, withFilingOrder filingOrder: String?){
        
        
        self.performURLRequest(withTicker: ticker, withEndpoint: endpoint, forFormType: formType, withFilingOrder: filingOrder, withJSONTaskCompletionHandler: self.persistDataCompletionHandler)
    }
    
    func perforumDebugURLRequest(forTicker ticker: String, forEndpoint endpoint: EdgarAPIRequest.APIEndpoint, forFormType formType: String?, withFilingOrder filingOrder: String?){
        
        
        self.performURLRequest(withTicker: ticker, withEndpoint: endpoint, forFormType: formType, withFilingOrder: filingOrder, withJSONTaskCompletionHandler: self.debugCompletionHandler)
    }
    
    
    
    
    
    
    
    private func performURLRequest(withTicker ticker: String, withEndpoint endpoint: EdgarAPIRequest.APIEndpoint, forFormType formType: String?, withFilingOrder filingOrder: String?, withJSONTaskCompletionHandler completion: @escaping JSONTaskCompletionHandler){
        
        
        let apiRequest = EdgarAPIRequest(withTicker: ticker, andWithEndpoint: endpoint, withFormType: formType, withFilingOrder: filingOrder)
        
        let urlRequest = apiRequest.getURLRequest()
        
        
        performURLRequest(urlRequest: urlRequest, withCompletionHandler: completion)
    }
    
    
    private func performURLRequest(urlRequest: URLRequest, withCompletionHandler completion: @escaping JSONTaskCompletionHandler){
        
        let _ = session.dataTask(with: urlRequest, completionHandler: {
            
            data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                
                var userInfoDict = [String: Any]()
                
                userInfoDict[self.kReasonForFailure] = "Failed to connect to the server, no HTTP status code obtained"
                
                let error = NSError(domain: "APIRequestError", code: 0, userInfo: userInfoDict)
                
                completion(nil, error)
                
                return
            }
            
            
            guard httpResponse.statusCode == 200 else {
                
                
                var userInfoDict = [String: Any]()
                
                userInfoDict[self.kReasonForFailure] = "Connect to the server with a status code other than 200"
                
                let error = NSError(domain: "APIRequestError", code: 0, userInfo: userInfoDict)
                
                completion(nil, error)
                
                return
            }
            
            
            if(data != nil){
                
                do{
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! JSONData
                    
                    completion(jsonData, nil)
                    
                } catch let error as NSError{
                    
                    completion(nil, error)
                    
                }
                
            } else {
                var userInfoDict = [String: Any]()
                
                userInfoDict[self.kReasonForFailure] = "Nil values obtained for JSON data"
                
                let error = NSError(domain: "APIRequestError", code: 0, userInfo: userInfoDict)
                
                
                completion(nil, error)
            }
            
        }).resume()
    }

}
   


