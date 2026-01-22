import 'package:in_app_purchase/in_app_purchase.dart';

class IAPToastMessages {
  IAPToastMessages._();

  static const String productIdMissing =
      'Unable to identify the product id. Please refresh and try again.';
  static const String orderNoMissing =
      'Failed to generate the order information. Please try again.';
  static const String notAvailable =
      'Purchases are not available right now. Please check your store availability or try again later.';
  static const String productDetailsNull =
      'Unable to load product information. Please check your network and store account.';
  static const String launchPayFailed =
      'We encountered an issue while starting the payment. Please try again.';
  static const String paymentPending =
      'Your payment is being processed. Please wait for confirmation.';

  // ====== Billing Response Messages ======
  static const String billingServiceTimeout =
      'The request timed out. Please try again.';
  static const String billingFeatureNotSupported =
      'The requested feature is not supported by Play Store on the current device.';
  static const String billingServiceDisconnected =
      'The Play Store service is not connected now. Please try again.';
  static const String billingServiceUnavailable =
      'The network connection is down. Please check your connection.';
  static const String billingUnavailable =
      'The billing API version is not supported for the type requested.';
  static const String billingItemUnavailable =
      'The requested product is not available for purchase.';
  static const String billingDeveloperError =
      'Invalid arguments provided to the API.';
  static const String billingError =
      'Fatal error during the API action. Please try again.';
  static const String billingItemAlreadyOwned =
      'Failure to purchase since item is already owned.';
  static const String billingItemNotOwned =
      'Failure to consume since item is not owned.';
  static const String billingNetworkError =
      'Network connection failure between the device and Play systems. Please check your connection and try again.';
}

/// 内购平台返回的错误信息
class IAPPlatformErrorMessages {
  IAPPlatformErrorMessages._();

  static const String pendingPurchase =
      'There is already a pending purchase for the requested item.';
  static const String insufficientFunds =
      'Payment declined due to insufficient funds.';
  static const String internalError = 'An internal error occurred.';
  static const String serverError = 'Server error, please try again.';
}

class IAPToastHelper {
  IAPToastHelper._();

  static String? resolveCancelToast(IAPError? error) {
    var details = error?.details;
    if (details is String && details.trim().isNotEmpty) {
      return details;
    }
    return null;
  }

  static String? resolveErrorToast(IAPError? error) {
    return _resolveDetailsToast(error?.details, error?.message);
  }

  static String? _resolveDetailsToast(dynamic details, String? message) {
    if (details is String && details.trim().isNotEmpty) {
      return details;
    }
    final fallback = _mapBillingResponseMessage(message);
    return fallback;
  }

  static String? _mapBillingResponseMessage(String? message) {
    if (message == null || message.trim().isEmpty) return null;

    final normalized = message.trim();
    const prefix = 'BillingResponse.';
    final name = normalized.startsWith(prefix)
        ? normalized.substring(prefix.length)
        : normalized;
    switch (name) {
      case 'serviceTimeout':
        return IAPToastMessages.billingServiceTimeout;
      case 'featureNotSupported':
        return IAPToastMessages.billingFeatureNotSupported;
      case 'serviceDisconnected':
        return IAPToastMessages.billingServiceDisconnected;
      case 'serviceUnavailable':
        return IAPToastMessages.billingServiceUnavailable;
      case 'billingUnavailable':
        return IAPToastMessages.billingUnavailable;
      case 'itemUnavailable':
        return IAPToastMessages.billingItemUnavailable;
      case 'developerError':
        return IAPToastMessages.billingDeveloperError;
      case 'error':
        return IAPToastMessages.billingError;
      case 'itemAlreadyOwned':
        return IAPToastMessages.billingItemAlreadyOwned;
      case 'itemNotOwned':
        return IAPToastMessages.billingItemNotOwned;
      case 'networkError':
        return IAPToastMessages.billingNetworkError;
      case 'ok':
        return null;
      default:
        return null;
    }
  }
}
