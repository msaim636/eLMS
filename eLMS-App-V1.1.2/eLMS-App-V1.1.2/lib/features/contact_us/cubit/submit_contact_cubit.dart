import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/contact_us/repository/contact_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubmitContactState {}

class SubmitContactInitial extends SubmitContactState {}

class SubmitContactInProgress extends SubmitContactState {}

class SubmitContactSuccess extends SubmitContactState {
  final Map<String, dynamic> response;
  SubmitContactSuccess({required this.response});
}

final class SubmitContactFail extends ErrorState implements SubmitContactState {
  SubmitContactFail({required super.error});
}

class SubmitContactCubit extends Cubit<SubmitContactState> {
  final ContactRepository _contactRepository;

  SubmitContactCubit(this._contactRepository) : super(SubmitContactInitial());

  Future<void> submitContact({
    required String firstName,
    required String email,
    required String message,
  }) async {
    try {
      emit(SubmitContactInProgress());
      final Map<String, dynamic> response = await _contactRepository
          .submitContactForm(
            firstName: firstName,
            email: email,
            message: message,
          );
      emit(SubmitContactSuccess(response: response));
    } catch (e) {
      emit(SubmitContactFail(error: e));
    }
  }

  void reset() {
    emit(SubmitContactInitial());
  }
}
