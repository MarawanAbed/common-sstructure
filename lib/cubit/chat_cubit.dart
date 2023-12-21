import 'package:firebase_advanced/chat_model.dart';
import 'package:firebase_advanced/services/firebase_serivces.dart';
import 'package:firebase_advanced/services/notification_services.dart';
import 'package:firebase_advanced/utils/helper_method/helper_method.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_cubit.freezed.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState.initial());

  static ChatCubit get(context) => BlocProvider.of(context);

  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  final RemoteNotificationService _remoteNotificationService =
      RemoteNotificationService();

  final StorageService _storageService = StorageService();

  addMessageText({required String content, required String receiverId}) async {
    emit(const ChatState.addTextMessageLoading());
    try {
      final uId = _authService.getCurrentUserId();
      final messageEntity = MessageModel(
        content: content,
        senderId: uId!,
        receiverId: receiverId,
        sendTime: DateTime.now(),
        messageType: MessageType.text,
      );
      await _databaseService.addTextMessage(messageEntity: messageEntity);
      var receiverToken=await _remoteNotificationService.getReceiverToken(uId);
      await _remoteNotificationService.sendNotification(
        receiverToken: receiverToken,
        body: content,
        senderId: uId,
      );
      emit(const ChatState.addTextMessageSuccess());
    } catch (e) {
      emit(ChatState.addTextMessageError(e.toString()));
    }
  }

  addMessageImage({required String receiverId}) async {
    emit(const ChatState.addImageMessageLoading());
    try {
      final image = await HelperMethod.getImageFromGallery();
      if (image != null) {
        final imageUrl = await _storageService.uploadImage(image);
        final uId = _authService.getCurrentUserId();
        final messageEntity = MessageModel(
          content: imageUrl,
          senderId: uId!,
          receiverId: receiverId,
          sendTime: DateTime.now(),
          messageType: MessageType.image,
        );
        await _databaseService.addImageMessage(messageEntity: messageEntity);
        var receiverToken=await _remoteNotificationService.getReceiverToken(uId);
        await _remoteNotificationService.sendNotification(
          receiverToken: receiverToken,
          body: 'Image sent',
          senderId: uId,
        );
        emit(const ChatState.addImageMessageSuccess());
      } else {
        emit(const ChatState.addImageMessageError('Please pick an image'));
      }
    } catch (e) {
      emit(ChatState.addImageMessageError(e.toString()));
    }
  }

  getAllMessage({required String receiverId}) async {
    emit(const ChatState.loading());
    try {
      _databaseService.getAllMessage(receiverId: receiverId).listen((event) {
        emit(ChatState.success(event));
      });
    } catch (e) {
      emit(ChatState.error(e.toString()));
    }
  }
}
