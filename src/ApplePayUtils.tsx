import {NativeModules, Platform} from 'react-native';

const {ApplePayNativeModule} = NativeModules;

if (!ApplePayNativeModule && Platform.OS === 'ios') {
  throw new Error('ApplePayNativeModule is not defined');
}

export default class ApplePay {
  initApplePay!: () => any;
  isApplePayAllowed!: (applePayMerchantID: string) => any;
  constructor(
    applePayMerchantID: string,
    tourCountryCode: string,
    currencyCode: string,
    pricePayable: number,
    authorizationKey: string,
  ) {
    if (Platform.OS === 'ios') {
      ApplePayNativeModule.invokeApplePay(
        applePayMerchantID,
        tourCountryCode,
        currencyCode,
        pricePayable,
        authorizationKey,
      );
      this.initApplePay = this._RNinitApplePay;
      this.isApplePayAllowed = this._RNcanMakePayments;
    } else {
      console.info('Not supported os (IOS ONLY)');
    }
  }

  _RNinitApplePay = () => {
    return ApplePayNativeModule.initApplePay();
  };

  _RNcanMakePayments = (applePayMerchantID: string) => {
    // auth key
    return ApplePayNativeModule.isApplePayAllowed(applePayMerchantID);
  };
}
