//
//  ViewController.swift
//  EDGAR Financials Helper
//
//  Created by Aleksander Makedonski on 12/15/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.date(from: "2005-01-01")!
        let endDate = dateFormatter.date(from: "2014-05-10")!
        
        QuandlAPIClient.sharedClient.performDebugAPIRequest(forTicker: TickerSymbol.Fedex_Corp, startDate: startDate, endDate: endDate)
        
        
        let dataFetcher = DataFetcher()

        if let allStockQuoteSummaries = dataFetcher.fetchAllDailyQuoteSummaryData(){
            
            allStockQuoteSummaries.forEach({
 
                summary in
 
                let high = summary.high
                let low = summary.low
                let close = summary.close
                let open = summary.open
                let adjHigh = summary.adjustedHigh
                let adjLow = summary.adjustedLow
                let date = summary.date
                let volume = summary.volume
                let adjVolume = summary.adjustedVolume
 
                print("\n Stock quote summary info - \n high: \(high), \n low: \(low), \n close: \(close), \n open: \(open), \n adjHigh: \(adjHigh), \n adjLow: \(adjLow), \n date: \(date!), \n volume: \(volume), \n adjVolume: \(adjVolume)")
            })
 
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
    

