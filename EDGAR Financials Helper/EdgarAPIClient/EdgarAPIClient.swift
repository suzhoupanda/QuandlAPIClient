//
//  EdgarAPIClient.swift
//  EDGAR Financials Helper
//
//  Created by Aleksander Makedonski on 12/15/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation
import AVKit

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
    let primaryKey = "1afa19cfa80f43b096fc9cbd366f4888"
    let secondaryKey = "bfa1658b300f43a2bc32aea9541cf6d3"
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

class EdgarAPIDownloadClient: NSObject, URLSessionDownloadDelegate{
    
    static let sharedClient = EdgarAPIDownloadClient()

    static let backgroundIdentifier1 = "backgroundID_1"
    static let backgroundIdentifier2 = "backgroundID_2"
    static let backgroundIdentifier3 = "backgroundID_3"

    

    var currentDownloadTask: Int = 0
    var downloadTasks: [URLSessionDataTask]?
    
    var session: URLSession!
    
    var operationQueue1 = OperationQueue()
    var operationQueue2 = OperationQueue()
    var operationQueue3 = OperationQueue()

    var presentingViewController: UIViewController?

    private override init(){
        
        super.init()
        
        let configuration = URLSessionConfiguration.background(withIdentifier: EdgarAPIDownloadClient.backgroundIdentifier1)

        session = URLSession(configuration: configuration, delegate: self, delegateQueue: self.operationQueue1)
        
        
        
    }
    
    
    func setPresentingViewController(toViewController viewController: UIViewController){
        self.presentingViewController = viewController
    }
    
    func downloadVideo(){
        
        let urlString = "https://suzhoupanda.github.io/alien_sniper_defense/vid/AppPreview1.mov"
        let url = URL(string: urlString)!
        
        let downloadTask = session.downloadTask(with: url)
        
        downloadTask.resume()
    }
    
  
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        /**
        if let fileHandler = try? FileHandle(forReadingFrom: location){
            //Read the file that has just been downloaded
             let fileData = fileHandler.readDataToEndOfFile()
            
        }
        **/
        
        let player = AVPlayer(url: location)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        if let presentingViewController = self.presentingViewController{
            presentingViewController.present(playerViewController, animated: true, completion: nil)
        }
        
        
        /**
        let fileManager = FileManager.default
    
    
        if let cacheDirectory = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first{
            do{
                
                if fileManager.fileExists(atPath: cacheDirectory.path){
                    if fileManager.isWritableFile(atPath: cacheDirectory.path){
                        try fileManager.replaceItemAt(cacheDirectory, withItemAt: location)

                    } else {
                    
                    }
                } else {
                    try fileManager.moveItem(at: location, to: cacheDirectory)

                }
                
            } catch let error as NSError {
                print("An error occurred while moving the temporary file to the cache directory, error: \(error.description), \(error.localizedDescription), \(error.localizedFailureReason)")
            }
        }
         **/
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("Error occurred while downloading...")
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
    
    
    
    
    /** Recursive function that process the URL request for each node in a linked list **/
    func performLinkedListPersistDataTraverse(forAPIRequestNode apiRequestNode: APIRequestNode){
        
        self.performURLRequest(withAPIRequestNode: apiRequestNode, withCompletionHandler: self.persistDataCompletionHandler)
    }
    
    func performLinkedListDebugTraverse(forAPIRequestNode apiRequestNode: APIRequestNode){
        
        self.performURLRequest(withAPIRequestNode: apiRequestNode, withCompletionHandler: self.debugCompletionHandler)
    }
    
    func performURLRequest(withAPIRequestNode apiRequestNode: APIRequestNode, withCompletionHandler completion: @escaping JSONTaskCompletionHandler){
        
        let urlRequest = apiRequestNode.getAPIRequest().getURLRequest()
        
        self.performURLRequest(urlRequest: urlRequest, withCompletionHandler: {
            
            jsonData, error in
            
            if(jsonData != nil){
                
                completion(jsonData!,nil)
          
            } else {
                completion(nil,error)
            }
            
            if let nextAPIRequestNode = apiRequestNode.getNextAPIRequestNode(){
                self.performURLRequest(withAPIRequestNode: nextAPIRequestNode, withCompletionHandler: completion)
            }
            
        })
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
   



/**
 
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
 
 **/
    



