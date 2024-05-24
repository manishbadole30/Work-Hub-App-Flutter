// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:work_hub_app/Jobs/task_details.dart';
import 'package:work_hub_app/Services/global_methods.dart';

class TaskWidget extends StatefulWidget {

  final String taskTitle;
  final String workerContactInfo;
  final String taskDescription;
  final String taskId;
  final String uploadedBy;
  final String userImage;
  final String name;
  final String workerAddress;
  //final bool available;
  final String email;

  const TaskWidget({
    super.key,
    required this.taskTitle,
    required this.workerContactInfo,
    required this.taskDescription,
    required this.taskId,
    required this.uploadedBy,
    required this.userImage,
    required this.name,
    required this.workerAddress,
    //required this.available,
    required this.email,
});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  _deleteDialog()
  {
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    showDialog(
      context: context,
      builder: (ctx)
        {
          return AlertDialog(
            actions: [
              TextButton(
                onPressed: () async {
                  try
                      {
                        if(widget.uploadedBy == _uid)
                          {
                            await FirebaseFirestore.instance.collection('tasks')
                                .doc(widget.taskId)
                                .delete();
                            await Fluttertoast.showToast(
                              msg: 'Task has been deleted',
                              toastLength: Toast.LENGTH_LONG,
                              backgroundColor: Colors.grey,
                              fontSize: 18.0,
                            );
                            Navigator.canPop(context) ? Navigator.pop(context) : null;
                          }
                        else
                        {
                          GlobalMethod.showErrorDialog(error: 'You can\'t perform this action', ctx: ctx);
                        }
                      }
                      catch(error)
                     {
                       GlobalMethod.showErrorDialog(error: 'This task can\'t be deleted', ctx: ctx);
                     } finally {}
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white24,
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8,),
      child: ListTile(
        onTap: ()
        {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TaskDetailsScreen(
            uploadedBy: widget.uploadedBy,
            taskID: widget.taskId,
          )));
        },
        onLongPress: () {
          _deleteDialog();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10,),
        leading: Container(
          padding: const EdgeInsets.only(right: 12,),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(width: 1,),
            ),
          ),
          child: Image.network(widget.userImage),
        ),
        title: Text(
          widget.taskTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8,),
            Text(
              widget.workerContactInfo,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              widget.taskDescription,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            Text(
              widget.workerAddress,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Colors.black,
        ),
      ),
    );
  }
}
