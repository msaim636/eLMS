import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';
import 'package:elms/utils/local_storage.dart';

class UserModel extends Model {
  final int id;
  final String name;
  final String? email;
  final String? mobile;
  final String? emailVerifiedAt;
  final String? profile;
  final String? type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Role> roles;
  final num walletBalance;
  final num creditBalance;
  final num totalBalance;
  final String token;
  final String? countryCode;
  final String? countryCallingCode;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.mobile,
    this.emailVerifiedAt,
    this.profile,
    this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
    required this.token,
    required this.walletBalance,
    required this.creditBalance,
    required this.totalBalance,
    this.countryCode,
    this.countryCallingCode,
  });

  static String? _normalizeCallingCode(String? code) {
    if (code == null || code.isEmpty) return code;
    return code.startsWith('+') ? code : '+$code';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'email_verified_at': emailVerifiedAt,
      'profile': profile,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'roles': roles.map((role) => role.toJson()).toList(),
      'token': token,
      'wallet_balance': walletBalance,
      'credit_balance': creditBalance,
      'total_balance': totalBalance,
      'country_code': countryCode,
      'country_calling_code': countryCallingCode?.replaceAll('+', ''),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json.require<int>('id'),
        walletBalance: json.optional('wallet_balance') is String
            ? num.parse(json.require<String>('wallet_balance'))
            : json.optional<num>('wallet_balance') ?? 0,
        creditBalance: json.optional('credit_balance') is String
            ? num.parse(json.require<String>('credit_balance'))
            : json.optional<num>('credit_balance') ?? 0,
        totalBalance: (json.optional('total_balance') is String
            ? num.parse(json.require<String>('total_balance'))
            : json.optional<num>('total_balance') ?? 0),
        name: json.require<String>('name'),
        email: json.optional<String>('email'),
        mobile: json.optional<String>('mobile'),
        emailVerifiedAt: json.optional<String>('email_verified_at'),
        profile: json.optional<String>('profile'),
        type: json.optional<String>('type'),
        createdAt: DateTime.parse(json.require<String>('created_at')),
        updatedAt: DateTime.parse(json.require<String>('updated_at')),
        roles:
            json
                .optional<List>('roles')
                ?.map((roleJson) => Role.fromJson(roleJson))
                .toList() ??
            [],
        token: json.optional<String>('token') ?? LocalStorage.token ?? '',
        countryCode: json.optional<String>('country_code'),
        countryCallingCode: _normalizeCallingCode(
          json.optional<String>('country_calling_code'),
        ),
      );
    } catch (e) {
      throw Exception('Failed to parse UserModel: $e');
    }
  }
}

class Role {
  final int id;
  final String name;
  final String guardName;

  Role({required this.id, required this.name, required this.guardName});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'guard_name': guardName};
  }

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json.require<int>('id'),
      name: json.require<String>('name'),
      guardName: json.require<String>('guard_name'),
    );
  }
}
