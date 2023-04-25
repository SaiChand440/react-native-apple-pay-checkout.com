import React from 'react';
import {ViewProps, requireNativeComponent} from 'react-native';

const ApplePayView = requireNativeComponent('RNApplePayView');

interface Props extends ViewProps {
  onPressAction: () => void;
}

export const ApplePayButton: React.FC<Props> = props => {
  return <ApplePayView {...props} />;
};
