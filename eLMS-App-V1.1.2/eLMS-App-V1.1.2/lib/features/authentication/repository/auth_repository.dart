// ignore_for_file: avoid_dynamic_calls

import 'dart:io';
import 'package:elms/common/enums.dart';
import 'package:elms/common/models/user_model.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/core/api/api_params.dart';
import 'package:elms/core/error_management/exceptions.dart';
import 'package:elms/core/login/phone_password_login.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthRepository {
  Future<UserModel> loginWithEmail({
    required String firebaseToken,
    required String password,
    required String email,
  }) async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {}

    final Map<dynamic, dynamic> response = await Api.post(
      Apis.login,
      data: {
        ApiParams.firebaseToken: firebaseToken,
        ApiParams.type: AuthenticationType.email.name,
        ApiParams.password: password,
        ApiParams.confirmPassword: password,
        ApiParams.email: email,
        ApiParams.fcmId: fcmToken ?? '',
        ApiParams.platformType: Platform.operatingSystem,
      },
    );

    return UserModel.fromJson(Map.from(response[ApiParams.data]));
  }

  Future<bool> resetPassword({
    required String password,
    required String confirmPassword,
    required String firebaseToken,
  }) async {
    try {
      final Map response = await Api.post(
        Apis.resetPassword,
        data: {
          ApiParams.password: password,
          ApiParams.confirmPassword: confirmPassword,
          ApiParams.firebaseToken: firebaseToken,
        },
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUserExists({
    String? mobile,
    String? countryCallingCode,
    String? email,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (email != null) {
        data[ApiParams.email] = email;
      } else {
        data[ApiParams.mobile] = mobile;
        data[ApiParams.countryCallingCode] = countryCallingCode?.replaceAll(
          "+",
          "",
        );
      }
      final Map response = await Api.post(Apis.userExists, data: data);
      return !(response[ApiParams.data][ApiParams.isNewUser]);
    } catch (e) {
      return false;
    }
  }

  Future<UserModel> register({
    String? email,
    required String password,
    required String confirmPassword,
    required String name,
    String? mobile,
    String? country,
    required String firebaseToken,
  }) async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {}

    final Map<String, dynamic> params = {
      ApiParams.email: email,
      ApiParams.fcmId: fcmToken ?? '',
      ApiParams.name: name,
      ApiParams.platformType: Platform.operatingSystem,
      ApiParams.firebaseToken: firebaseToken,
      ApiParams.password: password,
      ApiParams.confirmPassword: confirmPassword,
      ApiParams.type: 'email',
      if (mobile != null) ApiParams.mobile: mobile,
      if (country != null) 'country_code': country,
    }.removeEmptyKeys();

    final Map<dynamic, dynamic> response = await Api.post(
      Apis.userSignup,
      data: params,
    );

    return UserModel.fromJson(
      Map<String, dynamic>.from(response[ApiParams.data]),
    );
  }

  Future<UserModel> socialLogin(UserCredential credential, String type) async {
    try {
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (_) {}
      final String? firebaseToken = await credential.user?.getIdToken();
      final Map<String, dynamic> data = {
        ApiParams.name: credential.user?.displayName ?? '',
        ApiParams.email: credential.user?.email ?? '',
        ApiParams.mobile: credential.user?.phoneNumber ?? '',
        ApiParams.fcmId: fcmToken ?? '',
        ApiParams.firebaseId: credential.user?.uid ?? '',
        ApiParams.type: type,
        ApiParams.profile: credential.user?.photoURL ?? '',
        ApiParams.platformType: Platform.operatingSystem,
        ApiParams.firebaseToken: firebaseToken,
      };
      final Map response = await Api.post(Apis.userSignup, data: data);

      return UserModel.fromJson(
        (response[ApiParams.data] as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUserDetails() async {
    try {
      if (LocalStorage.token == null) {
        throw UnAuthorizedException(toast: false);
      }
      final Map<String, dynamic> result = await Api.get(
        Apis.getUserDetails,
        data: {ApiParams.token: LocalStorage.token},
      );

      return UserModel.fromJson(Map.from(result[ApiParams.data]));
    } catch (e) {
      throw ApiException(toast: false);
    }
  }

  Future<UserModel> editProfile({
    String? name,
    String? email,
    PhoneNumber? phone,
    File? profile,
    String? country,
  }) async {
    try {
      final response = await Api.postMultipart(
        Apis.updateProfile,
        fileKey: 'profile',
        isFilesArray: false,
        files: [?profile],
        data: {
          'name': ?name,
          'email': ?email,
          'mobile': ?phone?.number,
          'country_calling_code': ?phone?.countryCallingCode?.replaceAll(
            '+',
            '',
          ),
          'country_code': ?country,
          ApiParams.platformType: Platform.operatingSystem,
        },
      );

      return UserModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await Api.post(
      Apis.changePassword,
      data: {
        'old_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      },
    );
  }

  Future<bool> deleteAccount({required String firebaseToken}) async {
    await Api.post(
      Apis.deleteAccount,
      data: {'confirm_deletion': 1, ApiParams.firebaseToken: firebaseToken},
    );
    return true;
  }
}
