import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lear_flutter/models/User.dart';
import 'package:lear_flutter/screens/details.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
       


        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future <List<User>> getUser()async{

      var url = Uri.parse('https://randomuser.me/api/?results=40');
      late http.Response response;
      List<User> users = [];
     
      try{
        response = await http.get(url);

        if (response.statusCode == 200){
          Map peopleData = jsonDecode(response.body);
          List<dynamic> peoples = peopleData["results"];

          for(var items in peoples){
            var email = items['email'];
            var name = items['name']['first'] +" "+items['name']['last'];
            var id = items['login']['uuid'];
            var avatar = items['picture']['large'];
            User user = User (id,name, email,avatar);
            users.add(user);
          }
        }
        else{
          return Future.error("Somthing went wrong, ${response.statusCode}");
        }
      }
      catch(e){
        return Future.error(e.toString());
      }

      return users;
  }
 
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        title: Center(
          child: Text(
            widget.title
            ),
        ),
      ),
      body: FutureBuilder(
        future: getUser(),
        builder: (BuildContext context , AsyncSnapshot snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }else{
            if (snapshot.hasError){
              return Text(snapshot.error.toString());
            }else{
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder:(BuildContext context , int index){
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        snapshot.data[index].avatar)
                       ,),
                    title: Text(
                      snapshot.data[index].name,
                    ),
                    subtitle: Text(
                      snapshot.data[index].email,
                    ),
                    onTap: (){
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => 
                           UserDetails(snapshot.data[index]),
                        ),
                       );
                    },
                  );
                },
              );
            }
          }
      },),
    );
  }
}
