// ignore_for_file: avoid_print
import 'dart:io';

import 'package:chat/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  final _form = GlobalKey<FormState>();
  var _emailAddress = '';
  var _password = '';
  var _username = '';
  File? selectedImage;
  var isAuthenticating = false;
  void _saveForm() async {
    var isValid = _form.currentState!.validate();
    if (!isValid || (selectedImage == null && !_isLogin)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pick an Image ')));
      return;
    }

    _form.currentState!.save();
    try {
      setState(() {
        isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _emailAddress, password: _password);
        print(userCredentials);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _emailAddress, password: _password);
        print(userCredentials);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        print(imageUrl);
        await FirebaseFirestore.instance
            .collection('user-data')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _username,
          'image-url': imageUrl,
          'email': _emailAddress,
          'about': '',
          'phone': '',
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //...
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 25,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: deviceSize.width * 0.7,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isLogin
                      ? deviceSize.height * 0.27
                      : deviceSize.height * 0.48,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImagePicker(
                                onPickedImage: (pickedImage) {
                                  selectedImage = pickedImage;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Email Address'),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.none,
                              autocorrect: false,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Enter valid Email';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _emailAddress = newValue!;
                              },
                            ),
                            if (!_isLogin)
                              TextFormField(
                                enableSuggestions: false,
                                decoration: const InputDecoration(
                                    labelText: 'Username'),
                                onSaved: (newValue) {
                                  _username = newValue!;
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter valid username';
                                  }
                                  return null;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Password'),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Atleast 6 characters';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _password = newValue!;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!isAuthenticating)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                onPressed: _saveForm,
                                child: Text(_isLogin ? 'Login' : 'SignUp'),
                              ),
                            if (!isAuthenticating)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(_isLogin
                                      ? 'Create new account'
                                      : 'Already have an account'))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
