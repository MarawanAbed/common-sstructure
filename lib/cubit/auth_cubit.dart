import 'dart:async';
import 'dart:io';


import 'package:firebase_advanced/common.dart';
import 'package:firebase_advanced/services/firebase_serivces.dart';
import 'package:firebase_advanced/services/notification_services.dart';
import 'package:firebase_advanced/user.dart';
import 'package:firebase_advanced/utils/helper_method/helper_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.initial());

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  final StorageService _storageService = StorageService();

  final RemoteNotificationService _remoteNotificationService =
      RemoteNotificationService();
  static AuthCubit get(context) => BlocProvider.of(context);

  bool isVisible = true;
  IconData suffix = Icons.visibility_outlined;

  Timer? emailVerificationTimer;

  void changePasswordVisibility() {
    isVisible = !isVisible;
    suffix =
    isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(const AuthState.changePasswordVisibility());
  }

  File? profileImage;

  pickedImage() async {
    emit(const AuthState.pickImageLoadingState());
    try {
      profileImage = await HelperMethod.getImageFromGallery();
      emit(const AuthState.pickImageSuccessState());
    }  catch (e) {
      emit(AuthState.authErrorState(e.toString()));
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await _authService.sendVerificationEmail();
      Utils.showSnackBar('Verification email sent.');
      startEmailVerificationTimer();
    } on SocketException catch (e) {
      emit(_VerificationErrorState(e.toString()));
    } catch (e) {
      emit(_VerificationErrorState(e.toString()));
    }
  }

  void startEmailVerificationTimer() {
    print('Starting email verification timer.');
    emailVerificationTimer?.cancel(); // Cancel any existing timer.
    emailVerificationTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => checkEmailVerified(),
    );
  }

  void checkEmailVerified() async {
    print('Checking email verification status.');
    final isVerified = await _authService.isEmailVerified();
    if (isVerified) {
      emit(const AuthState.verificationSuccessState());
      print('Email is verified. Cancelling timer.');
      emailVerificationTimer?.cancel();
    }
  }

  signInMethod({required String email, required String password}) async {
    emit(const AuthState.authLoadingState());
    try {
      await _authService.signIn(email: email, password: password);
      await _remoteNotificationService.requestPermission();
      await _remoteNotificationService.getToken();
      emit(const AuthState.authSuccessState());
    } catch (e) {
      emit(AuthState.authErrorState(e.toString()));
    }
  }

  signUpMethod({required UserEntity userEntity}) async {
    emit(const AuthState.authLoadingState());
    try {
      await _authService.signUp(
          email: userEntity.email!, password: userEntity.password!);
      await _databaseService.createUser(userEntity);
      await _remoteNotificationService.requestPermission();
      await _remoteNotificationService.getToken();
      emit(const AuthState.authSuccessState());

    } catch (e) {
      emit(AuthState.authErrorState(e.toString()));
    }
  }

  signOutMethod() async {
    emit(const AuthState.authLoadingState());
    try {
      await _authService.signOut();
      emit(const AuthState.authSuccessState());

    } catch (e) {
      emit(AuthState.authErrorState(e.toString()));
    }
  }
  forgetPasswordMethod({required String email}) async {
    emit(const AuthState.authLoadingState());
    try {
      await _authService.forgetPassword(email);
      emit(const AuthState.authSuccessState());

    } catch (e) {
      emit(AuthState.authErrorState(e.toString()));
    }
  }

  String? imageUrl;

  uploadImageMethod() async {
    if (profileImage == null) {
      Utils.showSnackBar('No image selected');
      return;
    }
    emit(const AuthState.imageUploadLoadingState());
    try {
      imageUrl = await _storageService.uploadImage(profileImage!);
      print(imageUrl);
      emit(const AuthState.imageUploadSuccessState());
    } catch (e) {
      emit(AuthState.imageUploadErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    emailVerificationTimer?.cancel();
    return super.close();
  }

}
