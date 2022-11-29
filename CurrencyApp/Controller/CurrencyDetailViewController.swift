//
//  CurrencyDetailViewController.swift
//  CurrencyApp
//
//  Created by Sandip on 29/11/22.
//

import UIKit
import RxSwift
import RxCocoa

enum InformationType {
    case historicalData
    case otherCurrencyData
}

class CurrencyDetailViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    public var currencyData = PublishSubject<[CurrencyModel]>()
    public var historicalData = PublishSubject<[HistoricalDataModel]>()
    
    public var informationType: InformationType = .historicalData
    
    var fromCurrencyValue: String = StringConstants.emptyString
    var fromCurrencyCode: String = StringConstants.emptyString
    var toCurrencyCode: String = StringConstants.emptyString
    var toCurrencyValue: String = StringConstants.emptyString
    
    let disposeBag = DisposeBag()
    var currencyDetailViewModel = CurrencyDetailsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch informationType {
        case .historicalData:
            tableView.register(UINib(nibName: CellConstants.historicalDataCell, bundle: nil), forCellReuseIdentifier: String(describing: HistoricalDataTableViewCell.self))
            
            historicalData.bind(to: tableView.rx.items(cellIdentifier: CellConstants.historicalDataCell, cellType: HistoricalDataTableViewCell.self)) {  (row,track,cell) in
                //cell.cellModel = track
                }.disposed(by: disposeBag)
            
        case .otherCurrencyData:
            tableView.register(UINib(nibName: CellConstants.otherCurrencyDataCell, bundle: nil), forCellReuseIdentifier: String(describing: OtherCurrencyDataTableViewCell.self))
            
            currencyData.bind(to: tableView.rx.items(cellIdentifier: CellConstants.otherCurrencyDataCell, cellType: OtherCurrencyDataTableViewCell.self)) {  (row,track,cell) in
                //cell.cellModel = track
                }.disposed(by: disposeBag)
        }
        setupBindings()
        currencyDetailViewModel.getConvertedCurrency(fromSymbol: fromCurrencyCode, toSymbol: currencyDetailViewModel.getPopularCurrencySymbols(), valueToConvert: fromCurrencyValue)
        currencyDetailViewModel.getHistoricalCurrencyData(fromSymbol: fromCurrencyCode, toSymbol: toCurrencyCode, valueToConvert: fromCurrencyValue, convertedLatestValue: toCurrencyValue)
        
        
    }
    
    private func setupBindings() {

        currencyDetailViewModel
            .currencyModel
            .observe(on: MainScheduler.instance)
            .bind(to: currencyData)
            .disposed(by: disposeBag)
        
        currencyDetailViewModel
            .historicalDataModel
            .observe(on: MainScheduler.instance)
            .bind(to: historicalData)
            .disposed(by: disposeBag)
        
        currencyDetailViewModel.error.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [ weak self ]error in
                guard let self = self else { return }
                self.parseNetworkError(error: error)
                
            }).disposed(by: disposeBag)
       
    }
    
}
