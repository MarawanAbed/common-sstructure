import 'package:firebase_advanced/cubit/home_cubit.dart';
import 'package:firebase_advanced/register.dart';
import 'package:firebase_advanced/user.dart';
import 'package:firebase_advanced/widgets/buttons/custom_button.dart';
import 'package:firebase_advanced/widgets/text-field/text_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.uId});

  final String uId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    BlocProvider.of<HomeCubit>(context).getSingleUser(widget.uId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconTheme(
          data: const IconThemeData(color: Colors.black),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
              BlocProvider.of<HomeCubit>(context).getAllUsers();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        title: const Text('Edit Profile'),
      ),
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          var cubit = HomeCubit.get(context);
          state.maybeWhen(
            orElse: () {},
            updateUserSuccessState: () {
              Future.delayed(const Duration(seconds: 3), () {
                Navigator.pop(context);
                cubit.getAllUsers();
              });
            },
            pickImageSuccessState: () {
              cubit.uploadImageMethod();
            },
          );
        },
        builder: (context, state) {
          var cubit = HomeCubit.get(context);
          return state.maybeWhen(
            orElse: () {
              return BuildProfileItem(user: cubit.user!);
            },
            getSingleUserSuccessState: (user) {
              return BuildProfileItem(user: user);
            },
            getSingleUserLoadingState: () {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            getSingleUserErrorState: (error) {
              return Center(
                child: Text(error),
              );
            },
          );
        },
      ),
    );
  }
}

class BuildProfileItem extends StatefulWidget {
  const BuildProfileItem({super.key, required this.user});

  final UserEntity user;

  @override
  State<BuildProfileItem> createState() => _BuildProfileItemState();
}

class _BuildProfileItemState extends State<BuildProfileItem> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController.text = widget.user.name!;
    _emailController.text = widget.user.email!;
    _passwordController.text = widget.user.password!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = HomeCubit.get(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ProfileImage(
              image: cubit.profileImage == null
                  ? NetworkImage(widget.user.image!) as ImageProvider
                  : FileImage(cubit.profileImage!),
              radius: 50.0,
            ),
            const SizedBox(
              height: 20.0,
            ),
            TextButton(
              onPressed: () {
                cubit.pickedImage();
              },
              child: const Text('Change Profile Picture'),
            ),
            const SizedBox(
              height: 20.0,
            ),
            CustomTextField(
              labelText: 'Name',
              prefixIcon: Icons.person,
              controller: _nameController,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(
              height: 20.0,
            ),
            CustomTextField(
              labelText: 'Email',
              prefixIcon: Icons.email,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 20.0,
            ),
            CustomTextField(
              labelText: 'Password',
              prefixIcon: Icons.lock,
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(
              height: 20.0,
            ),
            MyCustomButton(
              height: 50.0,
              color: Colors.red,
              text: 'Update',
              onPressed: () {
                var user = UserEntity(
                  name: _nameController.text ?? widget.user.name,
                  email: _emailController.text ?? widget.user.email,
                  password: _passwordController.text ?? widget.user.password,
                  image: cubit.imageUrl ?? widget.user.image,
                  uId: widget.user.uId,
                  lastActive: widget.user.lastActive,
                  isOnline: widget.user.isOnline,
                );
                cubit.updateUser(user: user);
              },
            ),
          ],
        ),
      ),
    );
  }
}
