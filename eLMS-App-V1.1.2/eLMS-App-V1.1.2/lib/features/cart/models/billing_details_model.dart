// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/utils/extensions/data_type_extensions.dart';

class BillingDetailsModel extends Model {
  final int id;
  final String firstName;
  final String lastName;
  final String countryCode;
  final String? countryName;
  final String address;
  final String city;
  final String state;
  final String? postalCode;
  final String? taxId;

  BillingDetailsModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.countryCode,
    this.countryName,
    required this.address,
    required this.city,
    required this.state,
    this.postalCode,
    this.taxId,
  });

  factory BillingDetailsModel.fromJson(Map<String, dynamic> json) {
    return BillingDetailsModel(
      id: json.require<int>('id'),
      firstName: json.require<String>('first_name'),
      lastName: json.require<String>('last_name'),
      countryCode: json.require<String>('country_code'),
      countryName: json.optional<String?>('country_name'),
      address: json.require<String>('address'),
      city: json.require<String>('city'),
      state: json.require<String>('state'),
      postalCode: json.optional<String?>('postal_code'),
      taxId: json.optional<String?>('tax_id'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'country_code': countryCode,
    'country_name': countryName,
    'address': address,
    'city': city,
    'state': state,
    'postal_code': postalCode,
    'tax_id': taxId,
  };

  BillingDetailsModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? countryCode,
    String? countryName,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? taxId,
  }) {
    return BillingDetailsModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      taxId: taxId ?? this.taxId,
    );
  }
}
