import 'package:firebase_advanced/chat_page.dart';
import 'package:firebase_advanced/cubit/home_cubit.dart';
import 'package:firebase_advanced/profile.dart';
import 'package:firebase_advanced/services/firebase_serivces.dart';
import 'package:firebase_advanced/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome '),
          actions: [
            IconButton(
              onPressed: () {
                AuthService().signOut();
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
          return state.maybeWhen(
              orElse: () {
            return const SizedBox();
          }, getAllUsersSuccessState: (users) {
            return ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) => UserItems(users: users[index]),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: users.length,
            );
          });
        }),
      ),
    );
  }
}

class UserItems extends StatelessWidget {
  const UserItems({super.key, required this.users});

  final UserEntity users;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25.0,
        backgroundImage: NetworkImage(users.image!),
      ),
      title: Text(users.name!),
      subtitle: Text(users.email!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatPage(user: users,)));
          }, icon: const Icon(Icons.message)),
          const SizedBox(width: 10.0),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(uId: users.uId!),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
