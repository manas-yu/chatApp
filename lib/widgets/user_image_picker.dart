import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickedImage});
  final void Function(File selectedImage) onPickedImage;
  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? pickedImageFile;
  void _pickImage(ImageSource src) async {
    final image = await ImagePicker()
        .pickImage(source: src, imageQuality: 50, maxWidth: 150);
    if (image == null) {
      return;
    }
    setState(() {
      pickedImageFile = File(image.path);
    });
    widget.onPickedImage(pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey.withOpacity(0.2),
          foregroundImage:
              pickedImageFile != null ? FileImage(pickedImageFile!) : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
                onPressed: () {
                  _pickImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera),
                label: Text(
                  'Click Image',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                )),
            TextButton.icon(
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.image),
                label: Text(
                  'Pick Image',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                )),
          ],
        )
      ],
    );
  }
}
