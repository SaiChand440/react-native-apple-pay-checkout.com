//
//  CheckoutObjCNativeModule.m
//  ceres
//
//  Created by Neel Bakshi on 17/05/21.
//  Copyright © 2021 ceres. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ApplePayNativeModule, NSObject)
RCT_EXTERN_METHOD(isApplePayAllowed: (nonnull NSString *)applePayMerchantID resolver:(RCTPromiseResolveBlock)resolver rejector:(RCTPromiseRejectBlock)rejctor);
RCT_EXTERN_METHOD(invokeApplePay: (nonnull NSString *)applePayMerchantID
                  tourCountryCode: (nonnull NSString *)tourCountryCode
                  currencyCode: (nonnull NSString *)currencyCode
                  pricePayable:(nonnull double)pricePayable
                  authorizationKey:(nonnull NSString *)authorizationKey);
RCT_EXTERN_METHOD(initApplePay:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
@end
