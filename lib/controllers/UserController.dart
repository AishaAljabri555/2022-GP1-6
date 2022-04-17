import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled_design/app/app.dart';
import 'package:untitled_design/app/modules/user/screens/home.dart';
import 'package:untitled_design/controllers/profileController.dart';

import 'adminHomeController.dart';
import 'medicalHistoryController.dart';

class UserController extends GetxController {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController userNameController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  TextEditingController otpController = TextEditingController();

  TextEditingController contactNameController = TextEditingController();

  TextEditingController contactNumberController = TextEditingController();

  String? refId;

  void signInUser(context) async {
    signOut();
    String email = emailController.text;
    String password = passwordController.text;
    await _getUsername();

    try {
      final User? user = (await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password))
          .user;
      user!;
      // emailController.clear();
      // passwordController.clear(); emailController.text
      // if (user.email == 'Aishaaljabri.521@gmail.com') {
      if (emailController.text == 'Aishaaljabri.521@gmail.com') {
        final adminHomeController = Get.put(AdminHomeController());
        await adminHomeController.getAllUsers();
        Get.offAll(AdminHome());
      } else {
        final profileController = Get.put(ProfileController());
        final medicalHistoryController = Get.put(MedicalHistoryController());
        await profileController.patchData();
        await medicalHistoryController.patchData();

        Get.to(UserHome());
        //Get.offAll(const UserHome());
      }
      emailController.clear(); //NEW
      passwordController.clear(); //NEW
    } on FirebaseAuthException catch (_) {
      emailController.clear();
      passwordController.clear();
      showSnackBar("Incorrect username or Password!", context);
      onClose();
    }
  }

  void signUpUser(context) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);

    DocumentReference ref =
        await FirebaseFirestore.instance.collection('Users').add({
      'username': userNameController.text,
      'email': emailController.text,
      // 'phone': '',
      'password': passwordController.text,
    });

    ref.update({'userID': ref.id});
    await FirebaseFirestore.instance.collection('contacts').add({
      'Contact_1': null,
      'Contact_2': null,
      'Contact_3': null,
      'index': '1',
      'User_ID': ref.id
    });

    final userProfile = Get.put(ProfileController());
    userProfile.userProfileForm
        .control('phoneNumber')
        .updateValue(phoneController.text);
    try {
      DocumentReference reference = await FirebaseFirestore.instance
          .collection('userProfile')
          .add(userProfile.userProfileForm.value);
      reference.update({'userID': ref.id});
    } catch (_) {}

    userNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    showSnackBar("Signup Success", context);
  }

  Future<String> FindContactID() async {
    //1>We need to find the id of the current user since results of User? bring
    // diffrent ID of the current one.
    String uid = "";
    User? a = getUserInfo();

    //FIND THE ID OF THE CURRENT USER
    await FirebaseFirestore.instance
        .collection('Users')
        .get()
        .then((QuerySnapshot b) async {
      for (var doc in b.docs) {
        if (doc['email'] == a?.email) {
          uid = doc.id;

          break;
        }
      }
    });
    //2>search on the contacts where is the USERID==a.uid?

    String id = "";
    try {
      await FirebaseFirestore.instance
          .collection('contacts')
          .get()
          .then((QuerySnapshot b) async {
        for (var doc in b.docs) {
          if (doc['User_ID'] == uid) {
            id = doc.id;
            return id;
          }
        }
      });
    } catch (e) {
      print("Couldn't find the user.");
      print(e);
    }

    //IF OLD ACCOUNT MAKE A CONT OBJ FOR THEM
    if (id == "") {
      await FirebaseFirestore.instance.collection('contacts').add({
        'Contact_1': null,
        'Contact_2': null,
        'Contact_3': null,
        'index': '1',
        'User_ID': uid
      });

      await FirebaseFirestore.instance
          .collection('contacts')
          .get()
          .then((QuerySnapshot b) async {
        for (var doc in b.docs) {
          if (doc['User_ID'] == uid) {
            id = doc.id;
            return id;
          }
        }
      });
    }
    //3>then in .doc() write parm the id of that contact obj
    return id;
  }

  void forgotPassword(context) async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: emailController.text);
    showSnackBar("Please check your email inbox!", context);
    emailController.clear();
  }

  void showSnackBar(String message, scaffoldContext) {
    final snackBar =
        SnackBar(content: Text(message), backgroundColor: Colors.teal);

    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(snackBar);
  }

  Future<void> _getUsername() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['email'] == emailController.text) {
          userNameController.clear();
          userNameController.text = doc['username'];
          refId = doc['userID'];
          break;
        }
      }
    });
  }

  void DoContact(context, number123, name, phone) async {
    try {
      number123 = number123.toString();

      String contact = "Contact_" +
          number123; //So we know which of the three contact we add/upd

      CollectionReference AllContacts =
          FirebaseFirestore.instance.collection('contacts');

      AllContacts.doc(await FindContactID()).update({
        contact: ['$name', '$phone']
      });
    } catch (e) {
      print("-------------CONATCT EXPECTION-------------");
      print(e);
    }
  }

  Future<void> index(String contact) async {
    try {
      CollectionReference AllContacts =
          FirebaseFirestore.instance.collection('contacts');

      String id = await FindContactID();

      AllContacts.doc(id).update({'index': '$contact'});
    } catch (e) {
      print("Error in Index method.");
      print(e);
    }
  }

  Future<String> readIndex() async {
    CollectionReference AllContacts =
        FirebaseFirestore.instance.collection('contacts');

    String ind = "";
    try {
      await AllContacts.doc(await FindContactID())
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        // Get value of field date from document
        ind = await documentSnapshot.get('index');

        return ind;
      });
    } catch (e) {
      print("Error in Index reading.");
      print(e);
    }
    return ind;
  }

  Future<String> readInfo(String info) async {
    //***String infro ref to which contact of the three u want?
    CollectionReference AllContacts =
        FirebaseFirestore.instance.collection('contacts');

//***the list ind is bc we save each contact info in array of name and phone number so we read it as list
    List ind;
    try {
      await AllContacts.doc(await FindContactID())
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        // Get value of field date from document

        ind = await documentSnapshot.get('$info');

        return ind[0].toString();
      });
    } catch (e) {
      print("Error in reading Contact name.");
      print(e);
    }
    return "";
  }

  Future<String> readInfoPhone(String info) async {
    CollectionReference AllContacts =
        FirebaseFirestore.instance.collection('contacts');

    List ind;
    try {
      await AllContacts.doc(await FindContactID())
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        // Get value of field date from document

        ind = await documentSnapshot.get('$info');

        return ind[1].toString();
      });
    } catch (e) {
      print("Error in reading Contact phone.");
      print(e);
    }
    return "";
  }

  User? getUserInfo() {
    final User? user = FirebaseAuth.instance.currentUser;

    return user;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
