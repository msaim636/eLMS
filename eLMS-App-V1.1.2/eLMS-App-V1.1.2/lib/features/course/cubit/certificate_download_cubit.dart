import 'package:elms/common/models/blueprints.dart';
import 'package:elms/features/course/repository/course_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CertificateDownloadCubit extends Cubit<CertificateDownloadState> {
  final CourseRepository _repository;

  CertificateDownloadCubit(this._repository)
    : super(CertificateDownloadInitial());

  Future<void> downloadCertificate({required int courseId}) async {
    try {
      emit(CertificateDownloadProgress());
      final String filePath = await _repository.downloadCertificate(
        courseId: courseId,
      );
      emit(CertificateDownloadSuccess(filePath: filePath));
    } catch (e) {
      emit(CertificateDownloadError(error: e.toString()));
    }
  }

  void reset() {
    emit(CertificateDownloadInitial());
  }
}

abstract base class CertificateDownloadState extends BaseState {}

final class CertificateDownloadInitial extends CertificateDownloadState {}

final class CertificateDownloadProgress extends ProgressState
    implements CertificateDownloadState {}

final class CertificateDownloadSuccess extends BaseState
    implements CertificateDownloadState {
  final String filePath;

  CertificateDownloadSuccess({required this.filePath});
}

final class CertificateDownloadError extends ErrorState<String>
    implements CertificateDownloadState {
  CertificateDownloadError({required super.error});
}
