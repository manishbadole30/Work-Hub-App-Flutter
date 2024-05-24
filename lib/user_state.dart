import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work_hub_app/Jobs/jobs_screen.dart';
import 'package:work_hub_app/LoginPage/login_screen.dart';

class UserState extends StatelessWidget {
  const UserState({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot)
      {
        if(userSnapshot.data == null)
          {
            print('user is not logged in yet');
            return const Login();
          }
        else if(userSnapshot.hasData)
          {
            print('user is already logged in');
            return const JobScreen();
          }

        else if(userSnapshot.hasError)
          {
            return const Scaffold(
              body: Center(
                child: Text(
                  'An error has been occurred. Try again later',
                ),
              ),
            );
          }

        else if(userSnapshot.connectionState == ConnectionState.waiting)
        {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: Text(
              'Something went wrong',
            ),
          ),
        );
      },
    );
  }
}
