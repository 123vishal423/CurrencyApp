//
//  PickerTextField.swift
//  CurrencyApp
//
//  Created by Sandip on 29/11/22.
//

import Foundation
import RxSwift
import RxCocoa

class PickerTextField: UITextField {
    
    private let pickerView = UIPickerView(frame: .zero)
    private let disposeBag = DisposeBag()
    public var pickerItems: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupBindings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupBindings()
    }
    
    func setupBindings() {
        self.inputView = pickerView
        
        pickerItems.bind(to: self.pickerView.rx.itemTitles) { (row, element) in
            return element
        }.disposed(by: disposeBag)
        
        
        let _ = pickerView.rx.itemSelected
            .subscribe(onNext: { (row, value) in
                self.text = self.pickerItems.value[row]
                self.resignFirstResponder()
            })
        
    }
    
}

