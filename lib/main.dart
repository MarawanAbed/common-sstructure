import 'package:firebase_advanced/common.dart';
import 'package:firebase_advanced/cubit/auth_cubit.dart';
import 'package:firebase_advanced/cubit/chat_cubit.dart';
import 'package:firebase_advanced/cubit/home_cubit.dart';
import 'package:firebase_advanced/firebase_options.dart';
import 'package:firebase_advanced/home_page.dart';
import 'package:firebase_advanced/login.dart';
import 'package:firebase_advanced/services/bloc_observer.dart';
import 'package:firebase_advanced/services/firebase_serivces.dart';
import 'package:firebase_advanced/verify_email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
        BlocProvider(create: (context) => HomeCubit()..getAllUsers()),
        BlocProvider(create: (context)=>ChatCubit(),),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: Utils.messengerKey,
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: AuthService().userState(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && user.emailVerified) {
                return const HomePage();
              } else {
                return const VerifyEmail();
              }
            } else if (snapshot.hasError) {
              return const Text('Something went wrong');
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
