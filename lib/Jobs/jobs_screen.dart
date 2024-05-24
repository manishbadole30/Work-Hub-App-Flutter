import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work_hub_app/Search/search_task.dart';
import 'package:work_hub_app/Widgets/bottom_nav_bar.dart';
import 'package:work_hub_app/Widgets/task_widget.dart';
import 'package:work_hub_app/user_state.dart';

import '../Persistent/persistent.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {

  String? taskCategoryFilter;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  _showTaskCategoriesDialog({required Size size}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: const Text(
              'Task Category',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Persistent.taskCategoryList.length,
                itemBuilder: (ctx, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        taskCategoryFilter = Persistent
                            .taskCategoryList[index];
                      });
                      Navigator.canPop(context) ? Navigator.pop(context) : null;
                      print(
                        'taskCategoryList[index], ${Persistent.taskCategoryList[index]}'
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Persistent.taskCategoryList[index],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text('Close', style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                ),
              ),
              TextButton(
                onPressed: () {
                    setState(() {
                      taskCategoryFilter = null;
                    });
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text('Cancel Filter', style: TextStyle(color: Colors.white,),),
              ),
            ],
          );
        }
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Persistent persistentObject = Persistent();
    persistentObject.getMyData();
  }


  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade300, Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 0),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Work Hub App'),
          titleTextStyle: const TextStyle(
            fontSize: 25,
            letterSpacing: 3,
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange.shade300, Colors.blueAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.2, 0.9],
                ),
            ),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black,),
            onPressed: () {
              _showTaskCategoriesDialog(size: size);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_outlined, color: Colors.black,),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const SearchScreen()));
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .where('taskCategory', isEqualTo: taskCategoryFilter)
              //.where('available', isEqualTo: true)
              .orderBy('createdAt', descending: false)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot)
            {
              if(snapshot.connectionState == ConnectionState.waiting)
                {
                  return const Center(child: CircularProgressIndicator(),);
                }
              else if(snapshot.connectionState == ConnectionState.active)
                {
                  if(snapshot.data?.docs.isNotEmpty == true)
                    {
                      return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (BuildContext context, int index)
                          {
                            return TaskWidget(
                              taskTitle: snapshot.data?.docs[index]['taskTitle'],
                              workerContactInfo: snapshot.data?.docs[index]['workerContactInfo'],
                              taskDescription: snapshot.data?.docs[index]['taskDescription'],
                              taskId: snapshot.data?.docs[index]['taskId'],
                              uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                              userImage: snapshot.data?.docs[index]['userImage'],
                              name: snapshot.data?.docs[index]['name'],
                              workerAddress: snapshot.data?.docs[index]['workerAddress'],
                              //available: snapshot.data?.docs[index]['available'],
                              email: snapshot.data?.docs[index]['email'],
                            );
                          }
                      );
                    }
                  else
                    {
                      return const Center(
                        child: Text('There is no Taskers available'),
                      );
                    }
                }
              return const Center(
                child: Text('Something went wrong',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
                ),
              );
            }
        )
      ),
    );
  }
}
