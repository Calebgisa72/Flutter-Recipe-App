import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/screens/recipe_upload_flow.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_recipe_app/utils/constants.dart';
import 'package:iconsax/iconsax.dart';

class ImageUpload extends StatefulWidget {
  final RecipeFormData formData;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool edit;
  const ImageUpload({
    super.key,
    required this.formData,
    required this.onNext,
    required this.onBack,
    required this.edit,
  });

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  File? _pickedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }
    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl = await _uploadToCloudinary(_pickedImage!);
      widget.formData.image = imageUrl;
      widget.onNext();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<String> _uploadToCloudinary(File imageFile) async {
    final uploadUrl = 'https://api.cloudinary.com/v1_1/da4rqn95a/image/upload';

    final request =
        http.MultipartRequest('POST', Uri.parse(uploadUrl))
          ..fields['upload_preset'] = 'flutter_upload'
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final respData = json.decode(responseData);

    return respData['secure_url'];
  }

  void _saveAndNext() {
    if (widget.edit &&
        widget.formData.image.isNotEmpty &&
        _pickedImage == null) {
      widget.onNext();
    } else if (_pickedImage != null) {
      _uploadImage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          if (_isUploading)
            const CircularProgressIndicator()
          else if (widget.edit &&
              widget.formData.image.isNotEmpty &&
              _pickedImage == null)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(bRadius),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(widget.formData.image),
                ),
              ),
            )
          else if (_pickedImage != null)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(bRadius),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(_pickedImage!),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(bRadius),
                border: Border.all(color: Colors.grey, width: 1),
                color: secondary,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey,
                      ),
                      child: Center(
                        child: Icon(Iconsax.image5, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Add a Cover Photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '(Up to 5 Mb)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: secondary,
              elevation: 6,
              shadowColor: Colors.black.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(bRadius),
              ),
            ),
            child: SizedBox(
              height: 50,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.camera5, size: 30, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(
                      _pickedImage != null
                          ? 'Change Cover Image'
                          : widget.edit
                          ? 'Change Cover Image'
                          : 'Upload Cover Image',
                      style: TextStyle(fontSize: 16, color: foreGround),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isUploading ? null : widget.onBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondary,
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(bRadius),
                    ),
                  ),
                  child: const SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        'Back',
                        style: TextStyle(fontSize: 16, color: foreGround),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _saveAndNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(bRadius),
                    ),
                  ),
                  child: SizedBox(
                    height: 50,
                    child: Center(
                      child:
                          _isUploading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
