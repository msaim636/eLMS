import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/models/purchase_certificate_response_model.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PurchaseCertificateCubit extends Cubit<PurchaseCertificateState> {
  final CourseRepository _repository;

  PurchaseCertificateCubit(this._repository)
    : super(PurchaseCertificateInitial());

  Future<void> purchaseCertificate({
    required int courseId,
    required String paymentMethod,
  }) async {
    try {
      emit(PurchaseCertificateProgress());
      final PurchaseCertificateResponseModel result = await _repository
          .purchaseCertificate(
            courseId: courseId,
            paymentMethod: paymentMethod,
          );
      emit(PurchaseCertificateSuccess(data: result));
    } catch (e) {
      emit(PurchaseCertificateError(error: e.toString()));
    }
  }

  void reset() {
    emit(PurchaseCertificateInitial());
  }
}

abstract base class PurchaseCertificateState extends BaseState {}

final class PurchaseCertificateInitial extends PurchaseCertificateState {}

final class PurchaseCertificateProgress extends ProgressState
    implements PurchaseCertificateState {}

final class PurchaseCertificateSuccess extends BaseState
    implements PurchaseCertificateState {
  final PurchaseCertificateResponseModel data;

  PurchaseCertificateSuccess({required this.data});
}

final class PurchaseCertificateError extends ErrorState<String>
    implements PurchaseCertificateState {
  PurchaseCertificateError({required super.error});
}
