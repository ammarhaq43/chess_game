import 'package:flutter/material.dart';
import 'package:food_hygiene_app/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'new_screen.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}


class _MyScreenState extends State<MyScreen> {
  TextEditingController searchController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              height: 200,
              width: 600,
              color: Colors.yellow,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Icon(Icons.fastfood_sharp,size: 67,),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text('Food Hygiene Rating',style: GoogleFonts.pacifico(
                        textStyle: TextStyle(
                          fontSize: 21,
                        )
                    )),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Form(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 50),
                              hintText: 'Enter Your Menu',
                              hintStyle: TextStyle(color: Colors.black),
                              prefixIcon: Icon(Icons.search,color: Colors.black,),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1,)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1,),
                              )
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Form(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextFormField(
                                controller: addressController,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 50),
                                    prefixIcon: Icon(Icons.location_on,color: Colors.black,),
                                    hintText: 'Address/Postcode',
                                    hintStyle: TextStyle(color: Colors.black),
                                    border: new OutlineInputBorder(
                                        borderSide: BorderSide(width: 1)
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1)
                                    )
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.yellow
                                ),
                                onPressed: (){
                                  // fetchUsers();
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>  NewScreen(search: searchController.text,address: addressController.text ,)));
                                },
                                child: Text('Search',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


