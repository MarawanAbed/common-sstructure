import 'package:firebase_advanced/common.dart';
import 'package:firebase_advanced/cubit/auth_cubit.dart';
import 'package:firebase_advanced/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  void initState() {
    AuthCubit.get(context).sendVerificationEmail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
            orElse: () {},
            verificationErrorState: (message) {
              Utils.showSnackBar(message);
            },
            verificationSuccessState: () {
              Utils.showSnackBar('Verification email sent.');
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()), (
                      route) => false);
            });
      },
      builder: (context, state) {
        var cubit = AuthCubit.get(context);
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Verify Email',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'A verification email has been sent to. Please verify your email to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        cubit.sendVerificationEmail();
                      },
                      child: const Text('Resend Email'),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        cubit.signOutMethod();
                      },
                      child: const Text('cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
