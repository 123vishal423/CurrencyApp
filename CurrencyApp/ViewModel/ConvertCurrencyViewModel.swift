//
//  ConvertCurrencyViewModel.swift
//  CurrencyApp
//
//  Created by Sandip on 29/11/22.
//

import Foundation
import RxSwift
import RxCocoa

class ConvertCurrencyViewModel {
    
    public let currencySymbols: PublishSubject<[String]> = PublishSubject()
    public let convertedValue: PublishSubject<String> = PublishSubject()
    public let error: PublishSubject<NetworkError> = PublishSubject()
    public let loading: PublishSubject<Bool> = PublishSubject()
    
    func getValidCurrencySymbols() {
        self.loading.onNext(true)
        NetworkManager.shared.getDataResponse(urlString: APIConstants.symbolsEndPoint, completionBlock: { [weak self] result in
                   guard let self = self else {return}
                self.loading.onNext(false)
                   switch result {
                   case .failure(let networkError):
                       if let error = networkError as? NetworkError {
                           self.error.onNext(error)
                       }
       
                   case .success(let dta) :
                       if let symbolsData = dta[StringConstants.symbolsKey] as? [String: String] {
                           let allSymbols = Array(symbolsData.keys)
                           let sortedSymbols = allSymbols.sorted()
                           self.currencySymbols.onNext(sortedSymbols)
                       }
                   }
               })
    }
    
    func getConvertedCurrency(fromSymbol: String, toSymbol: String, valueToConvert: String) {
        var queryItemsDict = [String: String]()
        queryItemsDict[StringConstants.baseKey] = StringConstants.euroSymbol
        queryItemsDict[StringConstants.symbolsKey] = fromSymbol + StringConstants.commaString + toSymbol
        self.loading.onNext(true)
        NetworkManager.shared.getDataResponse(urlString: APIConstants.latestEndPoint, queryItems: queryItemsDict, completionBlock: { [weak self] result in
            guard let self = self else { return }
            self.loading.onNext(false)
            switch result {
            case .failure(let networkError):
                if let error = networkError as? NetworkError {
                    self.error.onNext(error)
                }

            case .success(let dta) :
                if let rates = dta[StringConstants.ratesKey] as? [String: Double] {
                    if let fromValue = rates[fromSymbol], let toValue = rates[toSymbol], let value = Double(valueToConvert) {
                        let convertedString = self.convertCurrency(fromValue: fromValue, toValue: toValue, valueToConvert: value)
                        self.convertedValue.onNext(convertedString)
                    }
                }
            }
            
        })
    }
    
    func convertCurrency(fromValue: Double, toValue:Double, valueToConvert: Double) -> String {
         let convertValue = (toValue * valueToConvert) / fromValue
        return String(format: "%.3f", convertValue)
        
    }
}

