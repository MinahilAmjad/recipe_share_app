import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_share_cooking_app/provider/user_provider.dart';
import 'package:recipe_share_cooking_app/user_activivity_cycle_screen/user_activity_cycle_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyDJ29dpNRPjScls2YGaN_vvhxM899en9GU',
      projectId: 'recipeshareap',
      messagingSenderId: '898702203652',
      storageBucket: "recipeshareap.appspot.com",
      appId: '1:898702203652:android:251067c95aa168ce3d8e51',
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: UserActivityCycleScreen());
  }
}
