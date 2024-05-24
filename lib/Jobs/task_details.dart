import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:work_hub_app/Jobs/jobs_screen.dart';
import 'package:work_hub_app/Services/global_methods.dart';
import 'package:work_hub_app/Widgets/comments_widget.dart';

import '../Services/global_variables.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String uploadedBy;
  final String taskID;

  const TaskDetailsScreen({
    super.key,
    required this.uploadedBy,
    required this.taskID,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _commentController = TextEditingController();

  bool _isCommenting = false;

  String? authorName;
  String? userImageUrl;
  String? taskCategory;
  String? taskDescription;
  String? taskTitle;
  String? workerContactInfo;
  String? workerAddress;
  Timestamp? postedDateTimeStamp;
  bool? available;
  String? email = '';

  bool showComment = false;

  void getTaskData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uploadedBy)
        .get();

    if (userDoc == null) {
      return;
    } else {
      setState(() {
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
      });
    }
    final DocumentSnapshot taskDatabase = await FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.taskID)
        .get();

    if (taskDatabase == null) {
      return;
    } else {
      setState(() {
        taskTitle = taskDatabase.get('taskTitle');
        taskDescription = taskDatabase.get('taskDescription');
        email = taskDatabase.get('email');
        workerAddress = taskDatabase.get('workerAddress');
        workerContactInfo = taskDatabase.get('workerContactInfo');
        taskCategory = taskDatabase.get('taskCategory');
        postedDateTimeStamp = taskDatabase.get('createdAt');
        available = taskDatabase.get('available');
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTaskData();
  }

  Widget dividerWidget() {
    return const Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
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
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              size: 40,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const JobScreen()));
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                          ),
                          child: Text(
                            taskTitle == null ? '' : taskTitle!.toUpperCase(),
                            maxLines: 3,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 3,
                                  color: Colors.grey,
                                ),
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    userImageUrl == null
                                        ? 'https://icons.veryicon.com/png/o/internet--web/55-common-web-icons/person-4.png'
                                        : userImageUrl!,
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName == null
                                        ? ''
                                        : authorName!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        dividerWidget(),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Tasker Address',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              const Icon(
                                Icons.location_pin,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                workerAddress.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FirebaseAuth.instance.currentUser!.uid !=
                                widget.uploadedBy
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  dividerWidget(),
                                  const Text(
                                    'Available',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          User? user = _auth.currentUser;
                                          final _uid = user!.uid;
                                          if (_uid == widget.uploadedBy) {
                                            try {
                                              FirebaseFirestore.instance
                                                  .collection('tasks')
                                                  .doc(widget.taskID)
                                                  .update({'available': true});
                                            } catch (error) {
                                              GlobalMethod.showErrorDialog(
                                                error:
                                                    'Action can\'t be performed',
                                                ctx: context,
                                              );
                                            }
                                          } else {
                                            GlobalMethod.showErrorDialog(
                                              error:
                                                  'You can\'t performed this action',
                                              ctx: context,
                                            );
                                          }
                                          getTaskData();
                                        },
                                        child: const Text(
                                          'Yes',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Opacity(
                                        opacity: available == true ? 1 : 0,
                                        child: const Icon(
                                          Icons.check_box,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 40,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          User? user = _auth.currentUser;
                                          final _uid = user!.uid;
                                          if (_uid == widget.uploadedBy) {
                                            try {
                                              FirebaseFirestore.instance
                                                  .collection('tasks')
                                                  .doc(widget.taskID)
                                                  .update({'available': false});
                                            } catch (error) {
                                              GlobalMethod.showErrorDialog(
                                                error:
                                                    'Action can\'t be performed',
                                                ctx: context,
                                              );
                                            }
                                          } else {
                                            GlobalMethod.showErrorDialog(
                                              error:
                                                  'You can\'t performed this action',
                                              ctx: context,
                                            );
                                          }
                                          getTaskData();
                                        },
                                        child: const Text(
                                          'No',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Opacity(
                                        opacity: available == false ? 1 : 0,
                                        child: const Icon(
                                          Icons.check_box,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                        dividerWidget(),
                        const Text(
                          'Task Description',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          taskDescription == null ? '' : taskDescription!,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Contact Info',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            const Icon(
                              Icons.call,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              workerContactInfo.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(
                            milliseconds: 500,
                          ),
                          child: _isCommenting
                            ?
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 3,
                                    child: TextField(
                                      controller: _commentController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      maxLength: 200,
                                      keyboardType: TextInputType.text,
                                      maxLines: 6,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                          ),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.pink,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8,),
                                          child: MaterialButton(
                                            onPressed: () async {
                                              if(_commentController.text.length < 7)
                                                {
                                                  GlobalMethod.showErrorDialog(
                                                    error: 'Comment can\'t be less than 7 characters',
                                                    ctx: context,
                                                  );
                                                }
                                              else
                                                {
                                                  final _generatedId = const Uuid().v4();
                                                  await FirebaseFirestore.instance
                                                      .collection('tasks')
                                                      .doc(widget.taskID)
                                                  .update({
                                                    'taskComments': FieldValue.arrayUnion([{
                                                      'userId': FirebaseAuth.instance.currentUser!.uid,
                                                      'commentId': _generatedId,
                                                      'name': name,
                                                      'userImageUrl': userImage,
                                                      'commentBody': _commentController.text,
                                                      'time': Timestamp.now(),
                                                    }]),
                                                  });
                                                  await Fluttertoast.showToast(
                                                    msg: 'Your comment has been added successfully',
                                                    toastLength: Toast.LENGTH_LONG,
                                                    backgroundColor: Colors.grey,
                                                    fontSize: 18.0,
                                                  );
                                                  _commentController.clear();
                                                }
                                              setState(() {
                                                showComment = true;
                                              });
                                            },
                                            color: Colors.blueAccent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Post',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _isCommenting = !_isCommenting;
                                              showComment = false;
                                            });
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                              :
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isCommenting = !_isCommenting;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add_comment,
                                      color: Colors.blueAccent,
                                        size: 40,
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showComment = true;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.arrow_drop_down_circle,
                                      color: Colors.blueAccent,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                        ),
                        showComment == false 
                            ?
                        Container()
                            :
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                .collection('tasks')
                                    .doc(widget.taskID)
                                    .get(),
                                builder: (context, snapshot)
                                {
                                   if(snapshot.connectionState == ConnectionState.waiting)
                                     {
                                       return const Center(child: CircularProgressIndicator(),);
                                     }
                                   else
                                     {
                                       if(snapshot.data == null)
                                         {
                                           const Center(child: Text('No Comments for this task'),);
                                         }
                                     }
                                   return ListView.separated(
                                     shrinkWrap: true,
                                     physics: const NeverScrollableScrollPhysics(),
                                     itemBuilder: (context, index)
                                     {
                                       return CommentWidget(
                                         commentId: snapshot.data!['taskComments'] [index]['commentId'],
                                         commenterId: snapshot.data!['taskComments'] [index]['userId'],
                                         commenterName: snapshot.data!['taskComments'] [index]['name'],
                                         commentBody: snapshot.data!['taskComments'] [index]['commentBody'],
                                         commenterImageUrl: snapshot.data!['taskComments'] [index]['userImageUrl'],
                                       );
                                     },
                                     separatorBuilder: (context, index) {
                                       return const Divider(
                                         thickness: 1,
                                         color: Colors.grey,
                                       );
                                     },
                                     itemCount: snapshot.data!['taskComments'].length,
                                   );
                                },
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
