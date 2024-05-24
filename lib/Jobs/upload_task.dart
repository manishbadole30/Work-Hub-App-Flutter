import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:work_hub_app/Persistent/persistent.dart';
import 'package:work_hub_app/Services/global_methods.dart';

import '../Services/global_variables.dart';
import '../Widgets/bottom_nav_bar.dart';

class UploadTaskNow extends StatefulWidget {
  const UploadTaskNow({super.key});

  @override
  State<UploadTaskNow> createState() => _UploadTaskNowState();
}

class _UploadTaskNowState extends State<UploadTaskNow> {

  final TextEditingController _taskCategoryController = TextEditingController(text: 'Select Job Category');
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _workerContactInfoController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();
  final TextEditingController _workerAddressController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose()
  {
    super.dispose();
    _taskCategoryController.dispose();
    _taskTitleController.dispose();
    _workerContactInfoController.dispose();
    _taskDescriptionController.dispose();
    _workerAddressController.dispose();
  }

  Widget _textTitles({required String label})
  {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textFormFields({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
})
{
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: InkWell(
      onTap: ()
      {
        fct();
      },
      child: TextFormField(
        validator: (value)
        {
          if(value!.isEmpty)
            {
              return 'Value is missing';
            }
          return null;
        },
        controller: controller,
        enabled: enabled,
        key: ValueKey(valueKey),
        style: const TextStyle(
          color: Colors.white,
        ),
        maxLines: valueKey == 'TaskDescription' ? 3 : 1,
        maxLength: maxLength,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.black54,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black,),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
        ),
      ),
    ),
  );
}

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
                       _taskCategoryController.text = Persistent
                           .taskCategoryList[index];
                     });
                     Navigator.pop(context);
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
               child: const Text('Cancel', style: TextStyle(
                 color: Colors.white,
                 fontSize: 18,
               ),
               ),
             ),
           ],
         );
       }
   );
 }

   void _uploadTask() async
   {
     final taskId = const Uuid().v4();
     User? user = FirebaseAuth.instance.currentUser;
     final _uid = user!.uid;
     final isValid = _formKey.currentState!.validate();

     if(isValid)
       {
         if(_taskCategoryController.text == 'Choose task category')
           {
             GlobalMethod.showErrorDialog(
               error: 'Please pick everything', ctx: context
             );
             return;
           }
         setState(() {
           _isLoading = true;
         });
         try
         {
           await FirebaseFirestore.instance.collection('tasks').doc(taskId).set({
             'taskId': taskId,
             'uploadedBy': _uid,
             'email': user.email,
             'taskTitle': _taskTitleController.text,
             'workerContactInfo': _workerContactInfoController.text,
             'taskDescription': _taskDescriptionController.text,
             'taskCategory': _taskCategoryController.text,
             'workerAddress': _workerAddressController.text,
             'taskerComments': [],
             //'available': true,
             'createdAt': Timestamp.now(),
             'name': name,
             'userImage': userImage,
             //location: location,
             //applicants: 0,
           });
           await Fluttertoast.showToast(
             msg: 'The task has been uploaded',
             toastLength: Toast.LENGTH_LONG,
             backgroundColor: Colors.grey,
             fontSize: 18.0,
           );
           _taskTitleController.clear();
           _workerContactInfoController.clear();
           _taskDescriptionController.clear();
           _workerAddressController.clear();
           setState(() {
             _taskCategoryController.text = 'Choose task category';
           });
         }catch(error) {
           {
             setState(() {
               _isLoading = false;
             });
             GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
           }
         }
         finally {
           setState(() {
             _isLoading = false;
           });
         }
       }
     else
     {
       print('Its not valid');
     }
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
          )
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(
          indexNum: 2,
        ),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Upload Task Now'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange.shade300, Colors.blueAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.2, 0.9],
                )
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Card(
              color: Colors.white10,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10,),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Please fill all fields',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Signatra',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Divider(
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textTitles(label: 'Task Category :'),
                            _textFormFields(
                              valueKey: 'TaskCategory',
                              controller: _taskCategoryController,
                              enabled: false,
                              fct: (){
                                _showTaskCategoriesDialog(size: size);
                              },
                              maxLength: 100,
                            ),
                            _textTitles(label: 'Task Title :'),
                            _textFormFields(
                              valueKey: 'TaskTitle',
                              controller: _taskTitleController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                            _textTitles(label: 'Contact Info :'),
                            _textFormFields(
                              valueKey: 'ContactInfo',
                              controller: _workerContactInfoController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                            _textTitles(label: 'Task Description :'),
                            _textFormFields(
                              valueKey: 'TaskDescription',
                              controller: _taskDescriptionController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                            _textTitles(label: 'Worker Address :'),
                            _textFormFields(
                              valueKey: 'WorkerAddress',
                              controller: _workerAddressController,
                              enabled: true,
                              fct: () {},
                              maxLength: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30,),
                        child: _isLoading
                        ? const CircularProgressIndicator()
                            : MaterialButton(
                            onPressed: () {
                              _uploadTask();
                            },
                            color: Colors.black,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14,),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                 Text(
                                    'Upload Task',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    fontFamily: 'NotoSans',
                                  ),
                                ),
                                  SizedBox(width: 9,),
                                  Icon(
                                    Icons.upload_file,
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
