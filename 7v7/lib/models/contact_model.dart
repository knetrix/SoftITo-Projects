import 'package:cloud_firestore/cloud_firestore.dart';

/// `users/{uid}/private/contact` — yalnızca sahibi okur (KVKK): e-posta ve
/// telefon başka kullanıcılara hiçbir zaman açılmaz.
class ContactModel {
  const ContactModel({required this.email, this.phone = '', this.phoneNormalized = ''});

  final String email;
  final String phone;
  final String phoneNormalized;

  factory ContactModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return ContactModel(
      email: (m['email'] ?? '') as String,
      phone: (m['phone'] ?? '') as String,
      phoneNormalized: (m['phoneNormalized'] ?? '') as String,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'email': email,
        'phone': phone,
        'phoneNormalized': phoneNormalized,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
