import 'package:elms/common/enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/cart/models/billing_details_model.dart';
import 'package:elms/features/cart/repository/billing_details_repository.dart';

abstract class BillingDetailsState {}

class BillingDetailsInitial extends BillingDetailsState {}

class BillingDetailsInProgress extends BillingDetailsState {}

class BillingDetailsSuccess extends BillingDetailsState {
  final BillingDetails type;
  final BillingDetailsModel? billingDetails;

  BillingDetailsSuccess(this.billingDetails, this.type);
}

class BillingDetailsCreateInProgress extends BillingDetailsState {}

class BillingDetailsUpdateInProgress extends BillingDetailsState {}

base class BillingDetailsFail extends ErrorState
    implements BillingDetailsState {
  BillingDetailsFail({required super.error});
}

class BillingDetailsCubit extends Cubit<BillingDetailsState> {
  final BillingDetailsRepository _repository;

  BillingDetailsCubit(this._repository) : super(BillingDetailsInitial());

  Future<void> fetch() async {
    try {
      emit(BillingDetailsInProgress());
      final BillingDetailsModel? result = await _repository.get();
      emit(BillingDetailsSuccess(result, BillingDetails.get));
    } catch (e) {
      emit(BillingDetailsFail(error: e));
    }
  }

  Future<void> create({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String address,
    required String city,
    required String state,
    String? postalCode,
    String? taxId,
  }) async {
    try {
      emit(BillingDetailsCreateInProgress());
      final BillingDetailsModel result = await _repository.create(
        firstName: firstName,
        lastName: lastName,
        countryCode: countryCode,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
        taxId: taxId,
      );
      emit(BillingDetailsSuccess(result, BillingDetails.post));
    } catch (e) {
      emit(BillingDetailsFail(error: e));
    }
  }

  Future<void> update({
    String? firstName,
    String? lastName,
    String? countryCode,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? taxId,
  }) async {
    try {
      emit(BillingDetailsUpdateInProgress());
      final BillingDetailsModel result = await _repository.update(
        firstName: firstName,
        lastName: lastName,
        countryCode: countryCode,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
        taxId: taxId,
      );
      emit(BillingDetailsSuccess(result, BillingDetails.patch));
    } catch (e) {
      emit(BillingDetailsFail(error: e));
    }
  }
}
