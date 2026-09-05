// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:elms/common/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elms/common/models/blueprints.dart';
import 'package:elms/core/login/phone_password_login.dart';
import 'package:elms/features/authentication/repository/auth_repository.dart';

abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

class EditProfileInProgress extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {
  final UserModel user;
  EditProfileSuccess({required this.user});
}

base class EditProfileFail extends ErrorState implements EditProfileState {
  EditProfileFail({required super.error});
}

class EditProfileCubit extends Cubit<EditProfileState> {
  final AuthRepository _repository;
  EditProfileCubit(this._repository) : super(EditProfileInitial());

  void edit({
    String? name,
    String? email,
    PhoneNumber? phone,
    File? profile,
    String? country,
  }) async {
    try {
      emit(EditProfileInProgress());

      final UserModel userModel = await _repository.editProfile(
        email: email,
        phone: phone,
        profile: profile,
        name: name,
        country: country,
      );

      emit(EditProfileSuccess(user: userModel));
    } catch (e) {
      emit(EditProfileFail(error: e));
    }
  }
}
