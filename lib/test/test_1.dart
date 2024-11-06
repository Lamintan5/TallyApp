import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionExample extends StatefulWidget {
  const EncryptionExample({super.key});

  @override
  State<EncryptionExample> createState() => _EncryptionExampleState();
}
class _EncryptionExampleState extends State<EncryptionExample> {
  final _key = encrypt.Key.fromUtf8('f2caaf40-68db-11ee-b339-f1847070'); // 256-bit key
  final _iv = encrypt.IV.fromLength(16);

  String encryptedText = '';
  String decryptedText = '';

  // Encrypt function
  void encryptText(String text) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(text, iv: _iv);
    setState(() {
      encryptedText = encrypted.base64;
    });
  }

  // Decrypt function
  void decryptText(String base64Text) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt64(base64Text, iv: _iv);
    setState(() {
      decryptedText = decrypted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AES Encryption Example"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Enter text to encrypt:"),
            SizedBox(height: 8.0),
            TextField(
              onChanged: (value) {
                encryptText(value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Text to Encrypt',
              ),
            ),
            SizedBox(height: 16.0),
            Text("Encrypted Text (Base64):"),
            SizedBox(height: 8.0),
            SelectableText(encryptedText),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                decryptText(encryptedText);
              },
              child: Text("Decrypt Text"),
            ),
            SizedBox(height: 16.0),
            Text("Decrypted Text:"),
            SizedBox(height: 8.0),
            SelectableText(decryptedText),
          ],
        ),
      ),
    );
  }
}

