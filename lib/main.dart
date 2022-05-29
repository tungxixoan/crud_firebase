import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _product =
      FirebaseFirestore.instance.collection('products');

  // application has a blue toolbar. Then, without quitting the app, try
  // changing the primarySwatch below to Colors.green and then invoke
  // "hot reload" (press "r" in the console where you ran "flutter run",
  // or simply save your changes to "hot reload" in a Flutter IDE).
  // Notice that the counter didn't reset back to zero; the application
  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _priceController = TextEditingController();

    Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
      if(documentSnapshot != null){
        _nameController.text = documentSnapshot['name'];
        _priceController.text = documentSnapshot['price'].toString();
      }
      await showModalBottomSheet(
        context: context, 
        builder: (BuildContext ctx) { 
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              right: 20,
              left: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom +20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name'
                    ),
                  ),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price'
                    ),
                  ),
                  const SizedBox(height: 20,),
                  ElevatedButton(
                    child: const Text('Update'),
                    onPressed: () async {
                      final String name = _nameController.text;
                      final double? price = double.tryParse(_priceController.text);
                      if(price != null){
                        await   _product.doc(documentSnapshot!.id).update({"name": name, "price": price});
                        _nameController.text='';
                        _priceController.text='';
                      }
                    }, 
                  )
                ],
              ),
            ),
          );
        }
      );
    }
    Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
      if(documentSnapshot != null){
        _nameController.text = documentSnapshot['name'];
        _priceController.text = documentSnapshot['price'].toString();
      }
      await showModalBottomSheet(
        context: context, 
        builder: (BuildContext ctx) { 
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              right: 20,
              left: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom +20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name'
                    ),
                  ),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price'
                    ),
                  ),
                  const SizedBox(height: 20,),
                  ElevatedButton(
                    child: const Text('Create'),
                    onPressed: () async {
                      final String name = _nameController.text;
                      final double? price = double.tryParse(_priceController.text);
                      if(price != null){
                        await   _product.add({"name": name, "price": price});
                        _nameController.text='';
                        _priceController.text='';
                      }
                    }, 
                  )
                ],
              ),
            ),
          );
        }
      );
    }
    Future<void> _delete(String productId) async {
      await _product.doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have successfully deleted a product')));
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: StreamBuilder(
          stream: _product.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return Card(
                    margin: EdgeInsets.all(5),
                    child: ListTile(
                      title: Text(documentSnapshot['name']),
                      subtitle: Text(documentSnapshot['price'].toString()),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _update(documentSnapshot)
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _delete(documentSnapshot.id)
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
