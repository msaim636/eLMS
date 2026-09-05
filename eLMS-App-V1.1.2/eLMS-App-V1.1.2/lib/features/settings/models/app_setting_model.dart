import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class AppSettingModel extends Model {
  final String? systemColor;
  final String? currencyCode;
  final String? currencySymbol;
  final String? taxType;
  final List<PaymentSettingModel>? activePaymentSettings;
  final String? playstoreUrl;
  final String? appstoreUrl;
  final String? androidVersion;
  final String? iosVersion;
  final String? appVersion;
  final String? maintainceMode;
  final String? forceUpdate;
  final String? websiteURL;
  final num? weeklyAverageWatchHours;
  final String? instructorMode;

  AppSettingModel({
    this.systemColor,
    this.currencyCode,
    this.currencySymbol,
    this.taxType,
    this.activePaymentSettings,
    this.playstoreUrl,
    this.appstoreUrl,
    this.androidVersion,
    this.iosVersion,
    this.appVersion,
    this.maintainceMode,
    this.forceUpdate,
    this.websiteURL,
    this.weeklyAverageWatchHours,
    this.instructorMode,
  });

  AppSettingModel.fromJson(Map<String, dynamic> json)
    : systemColor = json.optional<String>('system_color'),
      currencyCode = json.optional<String>('currency_code'),
      currencySymbol = json.optional<String>('currency_symbol'),
      weeklyAverageWatchHours = json.require<num>('weekly_average_watch_hours'),
      taxType = json.optional<String>('tax_type'),
      activePaymentSettings =
          json.optional<List>('active_payment_settings') != null
          ? (json.require<List>(
              'active_payment_settings',
            )).map((e) => PaymentSettingModel.fromJson(e)).toList()
          : null,
      playstoreUrl = json.optional<String>('playstore_url'),
      appstoreUrl = json.optional<String>('appstore_url'),
      androidVersion = json.optional<String>('android_version'),
      iosVersion = json.optional<String>('ios_version'),
      appVersion = json.optional<String>('app_version'),
      maintainceMode = json.optional<String>('maintaince_mode'),
      websiteURL = json.optional<String>('website_url'),
      forceUpdate = json.optional<String>('force_update'),
      instructorMode = json.optional<String>('instructor_mode');

  @override
  Map<String, dynamic> toJson() {
    return {
      'system_color': systemColor,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'tax_type': taxType,
      'active_payment_settings': activePaymentSettings
          ?.map((e) => e.toJson())
          .toList(),
      'playstore_url': playstoreUrl,
      'appstore_url': appstoreUrl,
      'android_version': androidVersion,
      'ios_version': iosVersion,
      'app_version': appVersion,
      'maintaince_mode': maintainceMode,
      'force_update': forceUpdate,
      'instructor_mode': instructorMode,
    };
  }
}

class PaymentSettingModel {
  final String? paymentGateway;
  final String? razorpayApiKey;

  PaymentSettingModel({this.paymentGateway, this.razorpayApiKey});

  factory PaymentSettingModel.fromJson(Map<String, dynamic> json) {
    return PaymentSettingModel(
      paymentGateway: json.optional<String>('payment_gateway'),
      razorpayApiKey: json.optional<String>('razorpay_api_key'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_gateway': paymentGateway,
      'razorpay_api_key': razorpayApiKey,
    };
  }
}
