//
//  ApplePayButtonView.swift
//  ceres
//
//  Created by Sai Chand on 13/03/23.
//  Copyright © 2023 ceres. All rights reserved.
//

import UIKit
import PassKit

class ApplePayButtonView: UIView {
    
    var applePayButton: PKPaymentButton?
    @objc var onPressAction: RCTDirectEventBlock?

    @objc func handleApplePayButtonTapped() {
            if onPressAction != nil {
                onPressAction!(["true": true])
            
            } else {

            }
        }
    
    override func didSetProps(_ changedProps: [String]!) {
            if let applePayButton = self.applePayButton {
                applePayButton.removeFromSuperview()
            }
        self.applePayButton = PKPaymentButton(paymentButtonType: .book, paymentButtonStyle: .black)
            
            if let applePayButton = self.applePayButton {
                applePayButton.addTarget(self, action: #selector(handleApplePayButtonTapped), for: .touchUpInside)
                self.addSubview(applePayButton)
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        override func layoutSubviews() {
            if let applePayButton = self.applePayButton {
                applePayButton.frame = self.bounds
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
