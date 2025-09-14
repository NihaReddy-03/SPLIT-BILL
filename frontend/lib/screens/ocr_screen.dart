// ocr_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BillOCRScreen extends StatefulWidget {
  @override
  _BillOCRScreenState createState() => _BillOCRScreenState();
}

class _BillOCRScreenState extends State<BillOCRScreen> {
  File? _mobileImage;
  Uint8List? _webImageBytes;
  
  String _extractedText = '';
  bool _isLoading = false;
  String _errorMessage = '';

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _extractedText = '';
        _errorMessage = '';
      });

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
        await _sendToBackend(bytes: bytes);
      } else {
        final file = File(pickedFile.path);
        setState(() {
          _mobileImage = file;
        });
        await _sendToBackend(file: file);
      }
    }
  }

  Future<void> _sendToBackend({File? file, Uint8List? bytes}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/ocr'), // replace with your backend URL
      );

      if (kIsWeb && bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: 'bill.png'),
        );
      } else if (!kIsWeb && file != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = json.decode(respStr);

        setState(() {
          _extractedText = data['extracted_text'] ?? "No text found";
        });
      } else {
        final errorStr = await response.stream.bytesToString();
        final errorData = json.decode(errorStr);
        setState(() {
          _errorMessage = errorData['error'] ?? "Failed to extract text from image";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error connecting to server: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildImageView() {
    if (kIsWeb && _webImageBytes != null) {
      return Container(
        constraints: BoxConstraints(maxHeight: 300),
        child: Image.memory(_webImageBytes!, fit: BoxFit.contain),
      );
    } else if (!kIsWeb && _mobileImage != null) {
      return Container(
        constraints: BoxConstraints(maxHeight: 300),
        child: Image.file(_mobileImage!, fit: BoxFit.contain),
      );
    } else {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text("No image selected", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
  }

  Widget _buildExtractedTextView() {
    if (_extractedText.isEmpty) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Extracted Text",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            Divider(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SelectableText(
                _extractedText,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  "Text is selectable and copyable",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    if (_errorMessage.isEmpty) return SizedBox.shrink();

    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR Text Extractor'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: Icon(Icons.upload_file),
                label: Text('Select Image to Extract Text'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            SizedBox(height: 20),

            // Loading indicator
            if (_isLoading)
              Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("Extracting text from image...", 
                       style: TextStyle(color: Colors.grey)),
                ],
              ),

            // Content area
            if (!_isLoading)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image preview
                      _buildImageView(),
                      
                      SizedBox(height: 20),

                      // Error message
                      _buildErrorView(),

                      // Extracted text
                      _buildExtractedTextView(),
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