//
//  APIRequestNode.swift
//  EDGAR Financials Helper
//
//  Created by Aleksander Makedonski on 12/16/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation

class APIRequestNode{
    
    var apiRequest: EdgarAPIRequest
    
    var nextNode: APIRequestNode?
    
    init(withAPIRequest anAPIRequest: EdgarAPIRequest){
        self.apiRequest = anAPIRequest
    }
    
    init(withTicker ticker: String, withEnpoint endpoint: EdgarAPIRequest.APIEndpoint, withFormType formType: String?,withFilingOrder filingOrder: String?){
        
        self.apiRequest = EdgarAPIRequest(withTicker: ticker, andWithEndpoint: endpoint, withFormType: formType, withFilingOrder: filingOrder)
        
    }
    
    func getAPIRequest() -> EdgarAPIRequest{
        return self.apiRequest
    }
    
    func setNextAPIRequest(withTicker ticker: String, withEndpoint endpoint: EdgarAPIRequest.APIEndpoint,withFormType formType: String?, withFilingOrder filingOrder: String?) -> APIRequestNode{
        
        self.nextNode = APIRequestNode(withTicker: ticker, withEnpoint: endpoint, withFormType: formType, withFilingOrder: filingOrder)
        
        return self.nextNode!
    }
    
    func setNextAPIRequest(withAPIRequest anAPIRequest: EdgarAPIRequest) -> APIRequestNode{
        self.nextNode = APIRequestNode(withAPIRequest: anAPIRequest)
        
        return self.nextNode!
    }
    
    func getNextAPIRequestNode() -> APIRequestNode?{
        return self.nextNode
    }
}
