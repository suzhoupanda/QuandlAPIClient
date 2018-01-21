//
//  TickerSymbol.swift
//  EDGAR Financials Helper
//
//  Created by Aleksander Makedonski on 12/16/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation

enum TickerSymbol: String{
    
    
    static let allTickerSymbols: [String] = [
        TickerSymbol.Agilent_Technologies.rawValue,
        TickerSymbol.Avnet.rawValue,
        TickerSymbol.AAC_Holdings.rawValue,
        TickerSymbol.AutoZone.rawValue,
        TickerSymbol.Fedex_Corp.rawValue
        ]
    
    case Agilent_Technologies = "A"
    case Aloca_Corporation = "AA"
    case AAC_Holdings = "AAC"
    case Aarons_Incorporated = "AAN"
    case American_Assets_Trust = "AAT"
    case Advantage_Oil_And_Gas = "AAV"
    case Alliancebernstein_Holding_LP = "AB"
    case Abbot_Laboratories = "ABT"
    case Ameren_Corporation = "AEE"
    case Alexanders = "ALX"
    case American_Express = "AXP"
    case Avnet = "AVT"
    case Arrow_Electronics = "ARW"
    case American_Tower = "AMT"
    case AutoZone = "AZO"
    
    
    case Barnes_Group = "B"
    case Big_Lots = "BIG"
    case Boeing_Company = "BA"
    case Bunge_Ltd = "BG"
    case Blackrock_Global = "BGT"
    case Barnes_And_Noble = "BKS"
    case Buckle_Inc = "BKE"
    case Burlington_Stores_Inc = "BURL"
    case Peabody_Energy_Corp = "BTU"
    
    case Citigroup_Incorporated = "C"
    case Comcast_Corp = "CCV"
    case Coeur_Mining_Inc = "CDE"
    case Celanese_Corp = "CE"
    case China_Mobile_Hong_Kong_Ltd = "CHL"
    case Chesapeake_Energy_Corp = "CHK"
    case Chegg_Inc = "CHGG"
    case Celadon_Group = "CGI"
    case Cloudera_Inc = "CLDR"
    case Circor_International = "CIR"
    
    case Dominion_Resources = "D"
    case Delta_Airlines = "DAL"
    case Tableau_Software_Inc = "DATA"
    case Donaldson_Company = "DCI"
    case Dean_Foods_Companu = "DF"
    case Dillards = "DDS"
    case Walt_Disney_Company = "DIS"
    case Dolby_Laboratories = "DLB"
    case Physicians_Realty_Trust = "DOC"
    case Dycom_Industries = "DY"
    
    case Ellie_Mae_Inc = "ELLI"
    case Estee_Lauder_Companies = "EL"
    case Eastgroup_Properties = "EGP"
    case Energen_Corp = "EGN"
    
    case Ford_Motor_Company = "F"
    case Flagstar_Bancorp = "FBC"
    case Franklin_Covey_Company = "FC"
    case Fedex_Corp = "FDX"
    case Futurefuel_Corp = "FF"
    case First_Data_Corp = "FDC"
    case Ferro_Corp = "FOE"
    
    case General_Dynamics = "GD"
    case Godaddy_Inc = "GDDY"
    case Genesco_Inc = "GCO"
    case Guess_Inc = "GES"
    case Goldman_Sachs_MLP_Energy = "GER"
    case General_Mills = "GIS"
    case CGI_Group = "GIB"
    
    case Microsoft = "MSFT"
    case Oracle = "ORCL"
    case Hewlett_Packard = "HPQ"
}
