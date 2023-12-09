import 'dart:io';

import 'package:firebase_advanced/common.dart';
import 'package:firebase_advanced/services/firebase_serivces.dart';
import 'package:firebase_advanced/user.dart';
import 'package:firebase_advanced/utils/helper_method/helper_method.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_cubit.freezed.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState.initial());

  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  static HomeCubit get(context) => BlocProvider.of(context);

  void getAllUsers() {
    emit(const HomeState.getAllUsersLoadingState());
    try {
      final usersStream = _databaseService.getAllUsers();
      usersStream.listen((List<UserEntity> event) {
        emit(HomeState.getAllUsersSuccessState(event));
      });
    } catch (e) {
      emit(HomeState.getAllUsersErrorState(e.toString()));
    }
  }
  UserEntity? user;
  getSingleUser(String uid) async {
    emit(const HomeState.getSingleUserLoadingState());
    try {
      final user = _databaseService.getSingleUser(uid);
      user.listen((event) {
        this.user=event;
        emit(HomeState.getSingleUserSuccessState(event));
      });
    } catch (e) {
      emit(HomeState.getSingleUserErrorState(e.toString()));
    }
  }

  File? profileImage;

  pickedImage() async {
    try {
      profileImage = await HelperMethod.getImageFromGallery();
      emit(const HomeState.pickImageSuccessState());
    } catch (e) {
      Utils.showSnackBar(e.toString());
    }
  }

  void clearProfileImage() {
    profileImage = null;
  }
  updateUser({required UserEntity user}){
    emit(const HomeState.updateUserLoadingState());
    try {
      _authService.updateEmailAndPassword(email: user.email!, password: user.password!);
      _databaseService.updateUser(user.toJson());
      emit(const HomeState.updateUserSuccessState());
    } catch (e) {
      emit(HomeState.updateUserErrorState(e.toString()));
    }
  }
  String?imageUrl;
  uploadImageMethod() async {
    if (profileImage == null) {
      return;
    }
    emit(const HomeState.uploadImageLoadingState());
    try {
      imageUrl = await _storageService.uploadImage(profileImage!);
      emit(const HomeState.uploadImageSuccessState());
    } catch (e) {
      emit(HomeState.uploadImageErrorState(e.toString()));
    }
  }
}
