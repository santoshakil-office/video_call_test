import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart'
    show
        AppBar,
        BuildContext,
        ButtonStyle,
        CheckboxListTile,
        Colors,
        Column,
        Container,
        Divider,
        EdgeInsets,
        ElevatedButton,
        InputDecoration,
        MaterialApp,
        MaterialStateColor,
        OutlineInputBorder,
        Scaffold,
        SingleChildScrollView,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextEditingController,
        TextField,
        TextStyle,
        Widget,
        debugPrint,
        runApp;
import 'package:jitsi_meet/jitsi_meet.dart'
    show
        FeatureFlagEnum,
        JitsiGenericListener,
        JitsiMeet,
        JitsiMeetingListener,
        JitsiMeetingOptions;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Meeting());
  }
}

class Meeting extends StatefulWidget {
  @override
  _MeetingState createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> {
  final serverText = TextEditingController();
  final roomText = TextEditingController(text: "santoshakil");
  final subjectText = TextEditingController(text: "My Plugin Test Meeting");
  final nameText = TextEditingController(text: "Plugin Test User");
  final emailText = TextEditingController(text: "fake@email.com");
  // final roomText = TextEditingController(text: "plugintestroom");
  // final subjectText = TextEditingController(text: "My Plugin Test Meeting");
  // final nameText = TextEditingController(text: "Plugin Test User");
  // final emailText = TextEditingController(text: "fake@email.com");
  final iosAppBarRGBAColor =
      TextEditingController(text: "#0080FF80"); //transparent blue
  bool? isAudioOnly = true;
  bool? isAudioMuted = true;
  bool? isVideoMuted = true;

  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(
      JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: meetConfig(),
        ),
      ),
    );
  }

  Widget meetConfig() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          TextField(
            controller: serverText,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Server URL",
                hintText: "Hint: Leave empty for meet.jitsi.si"),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: roomText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Room",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: subjectText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Subject",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: nameText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Display Name",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: emailText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Email",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: iosAppBarRGBAColor,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "AppBar Color(IOS only)",
                hintText: "Hint: This HAS to be in HEX RGBA format"),
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Audio Only"),
            value: isAudioOnly,
            onChanged: _onAudioOnlyChanged,
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Audio Muted"),
            value: isAudioMuted,
            onChanged: _onAudioMutedChanged,
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Video Muted"),
            value: isVideoMuted,
            onChanged: _onVideoMutedChanged,
          ),
          Divider(
            height: 48.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 64.0,
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () => _joinMeeting(),
              child: Text(
                "Join Meeting",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateColor.resolveWith((states) => Colors.blue)),
            ),
          ),
          SizedBox(
            height: 48.0,
          ),
        ],
      ),
    );
  }

  _onAudioOnlyChanged(bool? value) => setState(() => isAudioOnly = value);

  _onAudioMutedChanged(bool? value) => setState(() => isAudioMuted = value);

  _onVideoMutedChanged(bool? value) => setState(() => isVideoMuted = value);

  _joinMeeting() async {
    String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

    // Enable or disable any feature flag here
    // If feature flag are not provided, default values will be used
    // Full list of feature flags (and defaults) available in the README
    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };

    // Here is an example, disabling features for each platform
    if (Platform.isAndroid) {
      // Disable ConnectionService usage on Android to avoid issues (see README)
      featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
    } else if (Platform.isIOS) {
      // Disable PIP on iOS as it looks weird
      featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
    }

    // Define meetings options here
    var options = JitsiMeetingOptions(room: roomText.text)
      ..serverURL = serverUrl
      ..subject = subjectText.text
      ..userDisplayName = nameText.text
      ..userEmail = emailText.text
      ..iosAppBarRGBAColor = iosAppBarRGBAColor.text
      ..audioOnly = isAudioOnly
      ..audioMuted = isAudioMuted
      ..videoMuted = isVideoMuted
      ..featureFlags.addAll(featureFlags);

    debugPrint("JitsiMeetingOptions: $options");

    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
        onConferenceWillJoin: (message) =>
            debugPrint("${options.room} will join with message: $message"),
        onConferenceJoined: (message) =>
            debugPrint("${options.room} joined with message: $message"),
        onConferenceTerminated: (message) =>
            debugPrint("${options.room} terminated with message: $message"),
        genericListeners: [
          JitsiGenericListener(
            eventName: 'readyToClose',
            callback: (dynamic message) => debugPrint("readyToClose callback"),
          ),
        ],
      ),
    );
  }

  void _onConferenceWillJoin(message) =>
      debugPrint("_onConferenceWillJoin broadcasted with message: $message");

  void _onConferenceJoined(message) =>
      debugPrint("_onConferenceJoined broadcasted with message: $message");

  void _onConferenceTerminated(message) =>
      debugPrint("_onConferenceTerminated broadcasted with message: $message");

  _onError(error) => debugPrint("_onError broadcasted: $error");
}
