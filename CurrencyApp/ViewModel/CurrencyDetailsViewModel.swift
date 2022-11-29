//
//  CurrencyDetailsViewModel.swift
//  CurrencyApp
//
//  Created by Sandip on 29/11/22.
//

import Foundation
import RxSwift
import RxCocoa

class CurrencyDetailsViewModel {
    
    public let currencyModel: PublishSubject<[CurrencyModel]> = PublishSubject()
    public let historicalDataModel: PublishSubject<[HistoricalDataModel]> = PublishSubject()
    public let error: PublishSubject<NetworkError> = PublishSubject()
    
    func getHistoricalCurrencyData(fromSymbol: String, toSymbol: String, valueToConvert: String, convertedLatestValue: String) {
        var queryItemsDict = [String: String]()
        queryItemsDict[StringConstants.baseKey] = StringConstants.euroSymbol
        queryItemsDict[StringConstants.symbolsKey] = fromSymbol + StringConstants.commaString + toSymbol
        
        var historicalModel = [HistoricalDataModel]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = StringConstants.dateFormatString
        let dateStr:String = dateFormatter.string(from: NSDate() as Date)
        historicalModel.append(HistoricalDataModel(fromCurrencySymbol: fromSymbol, fromCurrencyValue: valueToConvert, toCurrencySymobl: toSymbol, toCurrencyValue: convertedLatestValue, dateString: dateStr))
        
        let dispatchGroup = DispatchGroup()
        
        let datesArray = self.getHistoricalDates()
        
        for dateString in datesArray {
            dispatchGroup.enter()
            NetworkManager.shared.getDataResponse(urlString: dateString, queryItems: queryItemsDict, completionBlock: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let networkError):
                    if let error = networkError as? NetworkError {
                        self.error.onNext(error)
                    }
                case .success(let dta) :
                    if let rates = dta[StringConstants.ratesKey] as? [String: Double] {
                        if let fromValue = rates[fromSymbol], let toValue = rates[toSymbol], let value = Double(valueToConvert) {
                            let convertedValue = self.convertCurrency(fromValue: fromValue, toValue: toValue, valueToConvert: value)
                            historicalModel.append(HistoricalDataModel(fromCurrencySymbol: fromSymbol, fromCurrencyValue: valueToConvert, toCurrencySymobl: toSymbol, toCurrencyValue: convertedValue, dateString: dateString))
                        }
                    }
                }
                dispatchGroup.leave()
                
            })
        }
        dispatchGroup.notify(queue: .main) {
            self.historicalDataModel.onNext(historicalModel)
        }
    }
    
    func getConvertedCurrency(fromSymbol: String, toSymbol: [String], valueToConvert: String) {
        var queryItemsDict = [String: String]()
        queryItemsDict[StringConstants.baseKey] = StringConstants.euroSymbol
        var symbolData = fromSymbol
        for symbol in toSymbol {
            symbolData += StringConstants.commaString + symbol
        }
        queryItemsDict[StringConstants.symbolsKey] = symbolData
      
        NetworkManager.shared.getDataResponse(urlString: APIConstants.latestEndPoint, queryItems: queryItemsDict, completionBlock: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let networkError):
                if let error = networkError as? NetworkError {
                    self.error.onNext(error)
                }

            case .success(let dta) :
                if let rates = dta[StringConstants.ratesKey] as? [String: Double] {
                    let currencyDataModel = self.createOtherCurrencyData(toSymbols: toSymbol, ratesData: rates, fromSymbol: fromSymbol, valueToConvert: valueToConvert)
                    self.currencyModel.onNext(currencyDataModel)
                }
            }
            
        })

    }
        
    func createOtherCurrencyData(toSymbols:[String], ratesData:[String: Double], fromSymbol: String, valueToConvert: String) -> [CurrencyModel] {
        var model = [CurrencyModel]()
        for symbol in toSymbols {
            if let fromValue = ratesData[fromSymbol], let toValue = ratesData[symbol], let value = Double(valueToConvert) {
                let convertedValue = convertCurrency(fromValue: fromValue, toValue: toValue, valueToConvert: value)
                model.append(CurrencyModel(currencySymbol: symbol, currencyValue: convertedValue))
            
            }
            
            
        }
        return model
        
    }
    
    func convertCurrency(fromValue: Double, toValue:Double, valueToConvert: Double) -> String {
         let convertValue = (toValue * valueToConvert) / fromValue
        return String(format: "%.3f", convertValue)
       
    }
    
    func getHistoricalDates() -> [String] {
        
        var datesData = [String]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = StringConstants.dateFormatString
        for  i in 0...1{
            let lastWeekDate = NSCalendar.current.date(byAdding: .day, value: -(1+i), to: NSDate() as Date)
            let dateStr:String = dateFormatter.string(from: lastWeekDate!)
            datesData.append(dateStr)
        }
        return datesData
    }
    
    func getPopularCurrencySymbols() -> [String] {
        return [StringConstants.dollarSymbol, StringConstants.britishPoundSymbol, StringConstants.egyptPoundSymbol, StringConstants.euroSymbol, StringConstants.canadianDollarSymbol, StringConstants.indianRupeeSymbol, StringConstants.australianDollarSymbol, StringConstants.dollarSymbol, StringConstants.japaneseYenSymbol, StringConstants.chineseSymbol, StringConstants.qatarRiyalSymbol, StringConstants.uaeDirhamSymbol, StringConstants.swissFrancSymbol]
    }
}
