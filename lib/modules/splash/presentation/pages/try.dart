import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl= 'skhjjhsakjasjd,,s,aasddj';
  const supabaseKey= 'ehbjsdmjbhfdhjefbhmsnfs';

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseKey,
  );

  await GetStorage.init();

  runApp(Try());
}


class Try extends StatelessWidget{
  const Try({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
   title:'try',
   debugShowCheckedModeBanner: false,

   home: Scaffold(
    appBar: AppBar(title: Text('try the possible',style: TextStyle(fontSize: 35),
    
    ),
    backgroundColor:Colors.green,
    centerTitle: true,

    ),

    body: Padding(padding: EdgeInsets.all(5),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Text('FIND FARMS. PICK FRESH AND ENJOY NATURE',style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
      SizedBox(height: 30,),
        Row(
          spacing: 19,
          
          children: [
          TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              hintText: 'search the best food',
              prefixIcon: Icon(Icons.search_off_outlined, ))
              
            ),

            TextButton(onPressed: (){}, child: Icon(Icons.tune_outlined))
            
          
        ],),
 Stack()
            ],
    ),
    ),
   ),
    );
  }
}

class Authentication extends StatelessWidget {
   Authentication({SupabaseClient? client}): _client = client ?? Supabase.instance.client;

 final SupabaseClient _client;
Future<void> signUp( {
required String email,
required String name,
required String password,

})async{
  final Response = await _client.auth.signUp(password: password ,email:email );
}

Future<void> signIn({
  required String email,
  required String password,

})async{
  final Response = await _client.auth.signInWithPassword(password: password, email: email);
  final Session = await _client.auth.currentSession;
}
  

  @override
  Widget build(BuildContext context) {
   return GetMaterialApp(); 
  }
}