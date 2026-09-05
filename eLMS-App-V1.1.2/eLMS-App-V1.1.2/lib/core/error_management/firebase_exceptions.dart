import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:get/get.dart';

class FirebaseExceptions {
  static final Map<String, String> _authErrorCodes = {
    // General
    'internal-error': AppLabels.internalError,
    'network-request-failed': AppLabels.networkRequestFailed,
    'too-many-requests': AppLabels.tooManyRequests,
    'timeout': AppLabels.timeout,

    // Email / Password
    'invalid-email': AppLabels.invalidEmail,
    'user-not-found': AppLabels.userNotFound,
    'wrong-password': AppLabels.wrongPassword,
    'email-already-in-use': AppLabels.emailAlreadyInUse,
    'weak-password': AppLabels.weakPassword,
    'user-disabled': AppLabels.userDisabled,
    'invalid-credential': AppLabels.invalidCredential,

    // Session / Token
    'user-token-expired': AppLabels.userTokenExpired,
    'invalid-user-token': AppLabels.invalidUserToken,
    'requires-recent-login': AppLabels.requiresRecentLogin,
    'user-mismatch': AppLabels.userMismatch,
    'null-user': AppLabels.nullUser,
    'session-expired': AppLabels.sessionExpired,

    // Phone Auth
    'invalid-phone-number': AppLabels.invalidPhoneNumber,
    'missing-phone-number': AppLabels.missingPhoneNumber,
    'code-expired': AppLabels.codeExpired,
    'invalid-verification-code': AppLabels.invalidVerificationCode,
    'missing-verification-code': AppLabels.missingVerificationCode,
    'invalid-verification-id': AppLabels.invalidVerificationId,
    'quota-exceeded': AppLabels.quotaExceeded,

    // OAuth / Social Login
    'account-exists-with-different-credential':
        AppLabels.accountExistsWithDifferentCredential,
    'credential-already-in-use': AppLabels.credentialAlreadyInUse,
    'popup-closed-by-user': AppLabels.popupClosedByUser,
    'popup-blocked': AppLabels.popupBlocked,
    'redirect-cancelled-by-user': AppLabels.redirectCancelledByUser,
    'provider-already-linked': AppLabels.providerAlreadyLinked,

    // App / Config
    'app-not-authorized': AppLabels.appNotAuthorized,
    'operation-not-allowed': AppLabels.operationNotAllowed,
    'invalid-api-key': AppLabels.invalidApiKey,
    'unauthorized-domain': AppLabels.unauthorizedDomain,
    'app-deleted': AppLabels.appDeleted,

    // Email actions
    'expired-action-code': AppLabels.expiredActionCode,
    'invalid-action-code': AppLabels.invalidActionCode,
    'unverified-email': AppLabels.unverifiedEmail,

    // Multi-factor
    'multi-factor-auth-required': AppLabels.multiFactorAuthRequired,
    'second-factor-already-in-use': AppLabels.secondFactorAlreadyInUse,
    'maximum-second-factor-count-exceeded':
        AppLabels.maximumSecondFactorCountExceeded,
  };

  /// Converts a Firebase error code to an AppException with localized message
  static AppException fromCode(String code) {
    final String labelKey =
        _authErrorCodes[code] ?? AppLabels.somethingWentWrong;
    // toast = false because the UI layer (BlocListener) handles showing errors
    return AppException(message: labelKey.tr, toast: false);
  }
}
