import 'package:firebase_advanced/chat_model.dart';
import 'package:firebase_advanced/cubit/chat_cubit.dart';
import 'package:firebase_advanced/services/notification_services.dart';
import 'package:firebase_advanced/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.user});

  final UserEntity user;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[300],
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.user.image!),
            ),
            const SizedBox(
              width: 30,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.user.name!),
                Text(
                  widget.user.isOnline! ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.user.isOnline! ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ChatMessage(
                receiverId: widget.user.uId!,
              ),
            ),
            ChatTextField(
              receiverId: widget.user.uId!,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatefulWidget {
  const ChatMessage({super.key, required this.receiverId});

  final String receiverId;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {

  final RemoteNotificationService remoteNotificationService=RemoteNotificationService();
  @override
  void initState() {
    var cubit = ChatCubit.get(context);
    cubit.getAllMessage(receiverId: widget.receiverId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          loading: () {
            const Center(child: CircularProgressIndicator());
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
              ),
            );
          },
        );
      },
      builder: (context, state) {
        return state.maybeWhen(orElse: () {
          BlocProvider.of<ChatCubit>(context).getAllMessage(
            receiverId: widget.receiverId,
          );
          return const Center(child: CircularProgressIndicator());
        }, success: (messages) {
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              final message = messages[index];
              //check if the message is sent by me or not
              //equal to the receiver id then its sent by me
              //else its sent by the other user
              final isMe = message.senderId != widget.receiverId;
              return MessageBubble(
                isMe: isMe,
                messageModel: message,
              );
            },
            itemCount: messages.length,
          );
        });
      },
    );
  }
}

class ChatTextField extends StatefulWidget {
  const ChatTextField({super.key, required this.receiverId});

  final String receiverId;

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  TextEditingController messageController = TextEditingController() ;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          addTextMessageSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Message sent successfully.'),
              ),
            );
          },
          addImageMessageSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image sent successfully.'),
              ),
            );
          },
          addImageMessageLoading: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sending image...'),
              ),
            );
          },
          addImageMessageError: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
              ),
            );
          },
          addTextMessageError: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
              ),
            );
          },
        );
      },
      builder: (context, state) {
        var cubit = ChatCubit.get(context);
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {
                _sendText(cubit);
              },
              child: const Icon(Icons.send),
            ),
            const SizedBox(
              width: 10,
            ),
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () {
                cubit.addMessageImage(receiverId: widget.receiverId);
              },
              child: const Icon(Icons.camera_alt_outlined),
            ),
          ],
        );
      },
    );
  }

  _sendText(ChatCubit cubit) {
    if (messageController.text.isNotEmpty) {
      cubit.addMessageText(
          content: messageController.text, receiverId: widget.receiverId);
      messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message.'),
        ),
      );
    }
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.messageModel,
    required this.isMe,
  });

  final MessageModel messageModel;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final isImageMessage = messageModel.messageType == MessageType.image;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Align(
        alignment: isMe ? Alignment.topLeft : Alignment.topRight,
        child: Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.red[300] : Colors.blue[300],
            borderRadius: isMe
                ? const BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
          ),
          margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (isImageMessage)
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(messageModel.content),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Text(
                  messageModel.content,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              const SizedBox(
                height: 5,
              ),
              Text(
                timeago.format(messageModel.sendTime),
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
