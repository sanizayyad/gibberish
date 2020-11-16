import 'package:flutter/material.dart';
import 'package:testproject/fcm.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PushNotificationService pushNotificationService;
  @override
  void initState() {
    super.initState();
    pushNotificationService = PushNotificationService();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Pro"),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RaisedButton(
                  onPressed: ()async {
//                    await notificationPlugin.showNotificationWithAttachment();
              },
                child: Text('attachment'),
              ),
              RaisedButton(
                onPressed: ()async {
//                  await notificationPlugin.groupNotification();
                },
                child: Text('group'),
              ),
              RaisedButton(
                onPressed: ()async {
//                  await notificationPlugin.showNotification();
                },
                child: Text('basic show'),
              ),
              RaisedButton(
                onPressed: (){
//                  notificationPlugin.cancelAllNotification();
                },
                child: Text('cancel'),
              )
            ],
          ),
        ),
      )
    );
  }
}
