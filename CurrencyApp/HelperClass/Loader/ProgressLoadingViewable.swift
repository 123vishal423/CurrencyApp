//
//  ProgressLoadingViewable.swift
//  CurrencyApp
//
//  Created by Sandip on 29/11/22.
//

import Foundation
import UIKit

protocol ProgressLoadingViewable {
    func startAnimating()
    func stopAnimating()
}
extension ProgressLoadingViewable where Self : BaseViewController {
    func startAnimating(){
        let animateLoading = ProgressLoadingView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        view.addSubview(animateLoading)
        view.bringSubviewToFront(animateLoading)
        animateLoading.restorationIdentifier = "loadingView"
        animateLoading.center = view.center
        animateLoading.loadingViewMessage = "Loading Message"
       
        animateLoading.clipsToBounds = true
        animateLoading.startAnimation()
    }
    func stopAnimating() {
        for item in view.subviews
            where item.restorationIdentifier == "loadingView" {
                UIView.animate(withDuration: 0.3, animations: {
                    item.alpha = 0
                }) { (_) in
                    item.removeFromSuperview()
                }
        }
    }
}

