import 'package:firebase_auth/firebase_auth.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository{
  Future<void> signUp({required String email, required String password}) async {
    try {
      await Util.auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await Util.auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
    }
  }

  Future<void> signInWithGoogle() async {
    await Util.googleSignIn.signIn().then((GoogleSignInAccount? acc) async{
      acc!.authentication.then((auth) async{
        if (auth.idToken == '' || auth.accessToken == '') {
          print('GoogleSignInAuthentication Error. Retry...');
          await Util.googleSignIn.disconnect();
        }else{
          final credential = GoogleAuthProvider.credential(
            accessToken: auth.accessToken,
            idToken: auth.idToken,
          );
          await Util.auth.signInWithCredential(credential);
        }
      });
    });
  }

  Future<void> signOut() async {
    try {
      await Util.auth.signOut().then((value) async{
        await Util.googleSignIn.disconnect();
      });
    } catch (e) {
      throw Exception(e);
    }
  }
}