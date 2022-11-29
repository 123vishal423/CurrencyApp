//
//  Constants.swift
//  CurrencyApp
//
//  Created by Sandip on 29/11/22.
//

import Foundation

struct StringConstants {
    static let dollarSymbol = "USD"
    static let euroSymbol = "EUR"
    static let britishPoundSymbol = "GBP"
    static let egyptPoundSymbol = "EGP"
    static let canadianDollarSymbol = "CAD"
    static let indianRupeeSymbol = "INR"
    static let australianDollarSymbol = "AUD"
    static let japaneseYenSymbol = "JPY"
    static let chineseSymbol = "CNY"
    static let qatarRiyalSymbol = "QAR"
    static let uaeDirhamSymbol = "AED"
    static let swissFrancSymbol = "CHF"
    static let emptyString = ""
    static let emptySpaceString = " "
    static let epsilonString = " -> "
    static let onKey = "On"
    static let symbolsKey = "symbols"
    static let ratesKey = "rates"
    static let baseKey = "base"
    static let dateFormatString = "yyyy-MM-dd"
    static let commaString = ","
    static let accessKey = "access_key"
}

struct APIConstants {
    static let symbolsEndPoint = "symbols"
    static let latestEndPoint = "latest"
}
