//
//  ApplePayViewManager.swift
//  ceres
//
//  Created by Sai Chand on 13/03/23.
//  Copyright © 2023 ceres. All rights reserved.
//

@objc (RNApplePayViewManager)
class RNApplePayViewManager: RCTViewManager {
 
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
 
  override func view() -> UIView! {
      let view = ApplePayButtonView(frame: CGRect.init())
      return view
  }
 
}

