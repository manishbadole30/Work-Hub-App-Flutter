import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Services/global_variables.dart';

class Persistent
{
  static List<String> taskCategoryList = [
    'Architecture and Construction',
    'Plumber',
    'Electrician',
    'Furniture Assembly',
    'Mount a TV,art or shelves',
    'Minor Home Repairs',
  ];

  void getMyData() async
  {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    name = userDoc.get('name');
    userImage = userDoc.get('userImage');
    //location = userDoc.get('location');
  }
}