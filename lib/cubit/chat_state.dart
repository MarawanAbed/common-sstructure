part of 'chat_cubit.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState.initial() = _Initial;

  const factory ChatState.loading() = _Loading;

  const factory ChatState.success(List<MessageModel>message) = _Success;

  const factory ChatState.error(String error) = _Error;

  const factory ChatState.pickedImageSuccess() = _PickedImageSuccess;

  const factory ChatState.uploadImageLoading() = _UploadImageLoading;

  const factory ChatState.uploadImageSuccess() = _UploadImageSuccess;

  const factory ChatState.uploadImageError(String error) = _UploadImageError;

  const factory ChatState.addTextMessageLoading() = _addTextMessageLoading;

  const factory ChatState.addTextMessageSuccess() = _addTextMessageSuccess;

  const factory ChatState.addTextMessageError(String error) = _addTextMessageError;

  const factory ChatState.addImageMessageLoading() = _addImageMessageLoading;

  const factory ChatState.addImageMessageSuccess() = _addImageMessageSuccess;

  const factory ChatState.addImageMessageError(String error) = _addImageMessageError;



}
