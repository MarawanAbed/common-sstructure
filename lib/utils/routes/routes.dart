


import 'package:flutter/material.dart';

class OnGenerateRoutes{

  static Route<dynamic>route(RouteSettings settings)
  {
    switch(settings.name)
    {
      // case '/':
      //   return MaterialPageRoute(builder: (_)=>const SplashScreen());
      // case '/auth':
      //   return MaterialPageRoute(builder: (_)=>const AuthScreen());
      // case '/signIn':
      //   return MaterialPageRoute(builder: (_)=>const SignIn());
      // case '/signUp':
      //   return MaterialPageRoute(builder: (_)=>const SignUp());
      // case '/forgetPassword':
      //   return MaterialPageRoute(builder: (_)=>const ForgetPassword());
      // case '/verifyEmail':
      //   return MaterialPageRoute(builder: (_)=>const VerifyEmail());
      // case '/search':
      //   return MaterialPageRoute(builder: (_)=>const SearchScreen());
      // case '/home':
      //   return MaterialPageRoute(builder: (_)=>const HomeScreen());
      default:
        return MaterialPageRoute(builder: (_)=>const ErrorPage());
    }
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("error"),
      ),
      body: const Center(
        child: Text("error"),
      ),
    );
  }
}
