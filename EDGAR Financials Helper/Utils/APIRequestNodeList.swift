//
//  APIRequestNodeList.swift
//  EDGAR Financials Helper
//
//  Created by Aleksander Makedonski on 12/16/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation


class APIRequestNodeList{
    
    var rootNode: APIRequestNode
    var currentNode: APIRequestNode?
    
    
    func getFirstNode() -> APIRequestNode{
        return self.rootNode
    }
   
    /**
    func traverseToNextNode(){
        self.currentNode = self.currentNode?.getNextAPIRequestNode()
    }
    
    func getCurrentNodeAPIRequest() -> EdgarAPIRequest{
        
        if(self.currentNode == nil){
            resetIterator()
        }
        
        return self.currentNode!.getAPIRequest()
        
    }
    
    func resetIterator(){
        self.currentNode = self.rootNode
    }
    **/
    
    init?(withAPIRequests someAPIRequests: [EdgarAPIRequest]){
        
        if(someAPIRequests.isEmpty || someAPIRequests.count == 0){
            return nil
        } else if (someAPIRequests.count == 1){
            self.rootNode = APIRequestNode(withAPIRequest: someAPIRequests.first!)
            self.currentNode = self.rootNode
        } else {
            
            self.rootNode = APIRequestNode(withAPIRequest: someAPIRequests.first!)
            self.currentNode = self.rootNode

            var tempNode = self.rootNode
            
            let remainingRequests = someAPIRequests[1..<someAPIRequests.count]
            
            remainingRequests.forEach({
                
                tempNode = tempNode.setNextAPIRequest(withAPIRequest: $0)
                
            })
            
        }
        
        
        
    }
    
    
    
    func traverseAPIRequests(withHandler handler: (EdgarAPIRequest) -> (Void)){
        
        let firstAPIRequest = self.rootNode.getAPIRequest()
        handler(firstAPIRequest)
        
        var currentNode = self.rootNode.getNextAPIRequestNode()
        
        repeat{
            
            if(currentNode != nil){
                handler(currentNode!.getAPIRequest())
            }
            
            currentNode = currentNode?.getNextAPIRequestNode()
            
        } while(currentNode != nil)
        
    }
    
   
}
