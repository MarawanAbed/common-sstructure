
import 'package:firebase_advanced/common.dart';
import 'package:firebase_advanced/cubit/auth_cubit.dart';
import 'package:firebase_advanced/user.dart';
import 'package:firebase_advanced/verify_email.dart';
import 'package:firebase_advanced/widgets/buttons/custom_button.dart';
import 'package:firebase_advanced/widgets/text-field/text_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController userNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    userNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          authErrorState: (message) {
            Utils.showSnackBar(message);
          },
          authLoadingState: () {
            const Center(child: CircularProgressIndicator());
          },
          imageUploadLoadingState: () {
            const Center(child: CircularProgressIndicator());
          },
          imageUploadErrorState: (message) {
            Utils.showSnackBar(message);
          },
          pickImageLoadingState: () {
            const Center(child: CircularProgressIndicator());
          },
          pickImageSuccessState: () {
            Utils.showSnackBar('Image picked successfully');
          },
          pickImageErrorState: (message) {
            Utils.showSnackBar(message);
          },
          authSuccessState: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const VerifyEmail()));
          },
        );
      },
      builder: (context, state) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            var cubit = AuthCubit.get(context);
            return Scaffold(
              body: RegisterBody(
                formKey: formKey,
                cubit: cubit,
                userNameController: userNameController,
                emailController: emailController,
                passwordController: passwordController,
              ),
            );
          },
        );
      },
    );
  }
}

class RegisterBody extends StatelessWidget {
  const RegisterBody({
    super.key,
    required this.formKey,
    required this.cubit,
    required this.userNameController,
    required this.emailController,
    required this.passwordController,
  });

  final GlobalKey<FormState> formKey;
  final AuthCubit cubit;
  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ProfileImage(
                  image: cubit.profileImage == null
                      ? null
                      : FileImage(cubit.profileImage!),
                  radius: 50,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: () async {
                    await cubit.pickedImage();
                  },
                  child: const Text(
                    'Choose Profile Picture',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  labelText: 'User Name',
                  prefixIcon: Icons.person,
                  controller: userNameController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your user name';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomTextField(
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    } else if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomTextField(
                  labelText: 'Password',
                  prefixIcon: Icons.lock,
                  controller: passwordController,
                  obscureText: cubit.isVisible,
                  suffixIcon: IconButton(
                      onPressed: () {
                        cubit.changePasswordVisibility();
                      },
                      icon: Icon(cubit.suffix)),
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                MyCustomButton(
                    height: 45.0,
                    text: 'Sign Up',
                    color: Colors.blue,
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        if (cubit.profileImage != null) {
                          await cubit.uploadImageMethod();
                          if (cubit.imageUrl != null) {
                            final userEntity = UserEntity(
                              email: emailController.text,
                              password: passwordController.text,
                              name: userNameController.text,
                              image: cubit.imageUrl!,
                              isOnline: true,
                              lastActive: DateTime.now(),
                            );
                            await cubit.signUpMethod(userEntity: userEntity);
                          }
                        } else {
                          Utils.showSnackBar(
                              'Please choose your profile image');
                        }
                      }
                    }),
                const SizedBox(
                  height: 10,
                ),
                BuildAuthRow(
                  body: 'Already have an account?',
                  label: 'Sign In',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.image,
    required this.radius,
  });

  final ImageProvider<Object>? image;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      backgroundImage: image,
    );
  }


  Widget _buildSignUpTitle(BuildContext context) {
    return Text(
      'Sign Up',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildProfileImageSection(BuildContext context, AuthCubit cubit) {
    return Column(
      children: [
        ProfileImage(
          image: cubit.profileImage == null ? null : FileImage(cubit.profileImage!),
          radius: 50,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () async {
            // Handle image picking logic
          },
          child: const Text(
            'Choose Profile Picture',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFields(BuildContext context, AuthCubit cubit) {
    return Column(
      children: [
        CustomTextField(
          labelText: 'User Name',
          prefixIcon: Icons.person,
          controller: TextEditingController(),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your user name';
            }
            return null;
          },
        ),
        const SizedBox(height: 30),
        // Add Email and Password TextFields similarly
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context, AuthCubit cubit) {
    return MyCustomButton(
      height: 45.0,
      text: 'Sign Up',
      color: Colors.blue,
      onPressed: () async {
        // Handle sign-up logic
      },
    );
  }

  Widget _buildAuthRow(BuildContext context) {
    return BuildAuthRow(
      body: 'Already have an account?',
      label: 'Sign In',
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
