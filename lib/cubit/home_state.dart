part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;

  const factory HomeState.pickImageSuccessState() = _PickImageSuccessState;

  const factory HomeState.getAllUsersLoadingState() = _GetAllUsersLoadingState;

  const factory HomeState.getAllUsersSuccessState(List<UserEntity> users) =
      _GetAllUsersSuccessState;

  const factory HomeState.getAllUsersErrorState(String error) =
      _GetAllUsersErrorState;

  const factory HomeState.getSingleUserLoadingState() =
      _GetSingleUserLoadingState;

  const factory HomeState.getSingleUserSuccessState(UserEntity user) =
      _GetSingleUserSuccessState;

  const factory HomeState.getSingleUserErrorState(String error) =
      _GetSingleUserErrorState;

  const factory HomeState.updateUserLoadingState() = _UpdateUserLoadingState;

  const factory HomeState.updateUserSuccessState() = _UpdateUserSuccessState;

  const factory HomeState.updateUserErrorState(String error) = _UpdateUserErrorState;

  const factory HomeState.uploadImageLoadingState() = _UploadImageLoadingState;

  const factory HomeState.uploadImageSuccessState() = _UploadImageSuccessState;

  const factory HomeState.uploadImageErrorState(String error) = _UploadImageErrorState;
}
