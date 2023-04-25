//
//  ApplePayNativeModule.swift
//  ceres
//
//  Created by Sai Chand on 13/03/23.
//  Copyright © 2023 ceres. All rights reserved.
//

import Frames
import PassKit
import Reachability
import SwiftyBeaver
import SwiftyJSON

@objc(ApplePayNativeModule)
class ApplePayNativeModule: UIViewController {

    enum PaymentType: String {
        case Checkout = "CHECKOUT"
    }
    
    private var rootViewController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
    private var request: PKPaymentRequest = PKPaymentRequest()
    private var resolver: RCTPromiseResolveBlock?
    private var authorizationKey: String = ""
    private var rejector: RCTPromiseRejectBlock?

   
    @objc func isApplePayAllowed(_ applePayMerchantID: NSString, resolver: RCTPromiseResolveBlock, rejector: RCTPromiseRejectBlock) {
        if applePayMerchantID == "" {
            rejector("PACKAGE_NOT_FOUND", "Id and Verification code didn't match a package", nil)
        }else {
            if doesDeviceSupportApplePay() {
                resolver(["applePayMerchantID": applePayMerchantID, "isAppleAllowed": true])
            } else {
                rejector("PACKAGE_NOT_FOUND", "Id and Verification code didn't match a package", nil)
                }
            }
    }

    static func supportedApplePayNetworks() -> [PKPaymentNetwork] {
        var supportedBrands = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex, PKPaymentNetwork.discover]
        if #available(iOS 10.1, *) {
            supportedBrands.append(PKPaymentNetwork.JCB)
        }
        if #available(iOS 12.0, *) {
            supportedBrands.append(PKPaymentNetwork.maestro)
        }
        return supportedBrands
    }

    func doesDeviceSupportApplePay() -> Bool {
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: ApplePayNativeModule.supportedApplePayNetworks(), capabilities: PKMerchantCapability.capability3DS)
    }
    
    @objc func invokeApplePay(_ applePayMerchantID: String,tourCountryCode: String, currencyCode: String, pricePayable: Double, authorizationKey: String) -> Void {
        let paymentItem = PKPaymentSummaryItem.init(label: "HEADOUT INC.", amount: NSDecimalNumber(value: pricePayable))
        request.currencyCode = currencyCode
        request.countryCode = tourCountryCode
        request.merchantIdentifier = applePayMerchantID
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.supportedNetworks = ApplePayNativeModule.supportedApplePayNetworks()
        request.paymentSummaryItems = [paymentItem]
        self.authorizationKey = authorizationKey
    }

    func makeApplePayPayment(_ payment: PKPayment,authorizationKey: String, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void), resolver: @escaping RCTPromiseResolveBlock, rejector: @escaping RCTPromiseRejectBlock) {

            var environment: Environment = Environment.sandbox
            #if APPSTORE
            environment = Environment.live
            #endif
            let checkoutInstance = CheckoutAPIClient(publicKey: authorizationKey, environment: environment)
            checkoutInstance.createApplePayToken(paymentData: payment.token.paymentData) { result in
                    switch result {
                    case .success(let applePayToken):
                        completion(PKPaymentAuthorizationStatus.success)
                        resolver(applePayToken)
                    case .failure(let error):
                        completion(PKPaymentAuthorizationStatus.failure)
                        rejector(error.localizedDescription, nil, error)
                    }
            }
        }
    
    @objc(initApplePay:withRejecter:)
    func initApplePay(resolve: @escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) -> Void {
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: ApplePayNativeModule.supportedApplePayNetworks()) else {
            print("Can not make payment")
            return
        }
        self.resolver = resolve
        self.rejector = reject
        if let controller = PKPaymentAuthorizationViewController(paymentRequest: request) {
            controller.delegate = self
            DispatchQueue.main.async {
                self.rootViewController.present(controller, animated: true, completion: nil)
            }
        }
    }

}

extension ApplePayNativeModule: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (@escaping (PKPaymentAuthorizationStatus) -> Void)) {
        var environment: Environment = Environment.sandbox
        #if APPSTORE
        environment = Environment.live
        #endif
        let checkoutInstance = CheckoutAPIClient(publicKey: authorizationKey, environment: environment)
        checkoutInstance.createApplePayToken(paymentData: payment.token.paymentData) { result in
                switch result {
                case .success(let applePayToken):
                    completion(PKPaymentAuthorizationStatus.success)
                    self.resolver!(applePayToken)
                case .failure(let error):
                    completion(PKPaymentAuthorizationStatus.failure)
                    self.rejector!("PAYMENT_FAILURE","Token Creation Failed",error)
                }
        }
    }
    
}

