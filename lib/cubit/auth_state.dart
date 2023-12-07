part of 'auth_cubit.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.changePasswordVisibility() = _ChangePasswordVisibility;
  const factory AuthState.pickImageLoadingState() = _PickImageLoadingState;
  const factory AuthState.pickImageSuccessState() = _PickImageSuccessState;
  const factory AuthState.pickImageErrorState(String error) = _PickImageErrorState;
  const factory AuthState.authLoadingState() = _AuthLoadingState;
  const factory AuthState.authSuccessState() = _AuthSuccessState;
  const factory AuthState.authErrorState(String error) = _AuthErrorState;
  const factory AuthState.verificationErrorState(String error) = _VerificationErrorState;
  const factory AuthState.verificationSuccessState() = _VerificationSuccessState;

  const factory AuthState.imageUploadLoadingState() = _ImageUploadLoadingState;

  const factory AuthState.imageUploadSuccessState() = _ImageUploadSuccessState;

  const factory AuthState.imageUploadErrorState(String error) = _ImageUploadErrorState;

}
