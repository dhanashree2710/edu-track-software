import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack_application/utils/common/pop_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TrainerRegisterScreen extends StatefulWidget {
  const TrainerRegisterScreen({super.key});

  @override
  State<TrainerRegisterScreen> createState() => _TrainerRegisterScreenState();
}

class _TrainerRegisterScreenState extends State<TrainerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController qualificationCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  final LinearGradient redGradient = const LinearGradient(
    colors: [Color(0xff3f5efb), Color(0xfffc466b)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    qualificationCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  /// 🔹 Gradient Border Wrapper
  Widget gradientBorderWrapper({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: redGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }

  /// 🔹 Input Decoration
  InputDecoration inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }

  /// 🔹 Register Trainer
  Future<void> registerTrainer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      /// 1️⃣ Firebase Auth
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final uid = user.user!.uid;

      /// 2️⃣ Trainer Collection
      await FirebaseFirestore.instance.collection('trainer').doc(uid).set({
        'trainer_id': uid,
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'qualification': qualificationCtrl.text.trim(),
        'created_at': Timestamp.now(),
      });

      /// 3️⃣ Users Collection
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'user_id': uid,
        'user_name': nameCtrl.text.trim(),
        'user_email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'role': 'trainer',
        'created_at': Timestamp.now(),
      });

      setState(() => loading = false);

      showCustomAlert(
        context,
        isSuccess: true,
        title: "Success",
        description: "Trainer registered successfully",
      );

      nameCtrl.clear();
      emailCtrl.clear();
      phoneCtrl.clear();
      qualificationCtrl.clear();
      passCtrl.clear();
    } catch (e) {
      setState(() => loading = false);

      showCustomAlert(
        context,
        isSuccess: false,
        title: "Error",
        description: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 🔹 APP BAR
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff3f5efb), Color(0xfffc466b)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  "assets/logo.png",
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),

      /// 🔹 BODY
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// 🔹 Title
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          redGradient.createShader(bounds),
                      child: const Text(
                        "Register Trainer",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// 🔹 Name
                  gradientBorderWrapper(
                    child: TextFormField(
                      controller: nameCtrl,
                      decoration: inputDecoration("Trainer Name"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  /// 🔹 Email
                  gradientBorderWrapper(
                    child: TextFormField(
                      controller: emailCtrl,
                      decoration: inputDecoration("Email"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  /// 🔹 Phone
                  gradientBorderWrapper(
                    child: TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: inputDecoration("Phone Number"),
                      validator: (v) =>
                          v == null || v.length < 10
                              ? "Enter valid phone number"
                              : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  /// 🔹 Qualification
                  gradientBorderWrapper(
                    child: TextFormField(
                      controller: qualificationCtrl,
                      decoration: inputDecoration("Qualification"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  /// 🔹 Password
                  gradientBorderWrapper(
                    child: TextFormField(
                      controller: passCtrl,
                      obscureText: obscurePassword,
                      decoration: inputDecoration(
                        "Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (v) => v != null && v.length < 6
                          ? "Minimum 6 characters"
                          : null,
                    ),
                  ),
                  const SizedBox(height: 25),

                  /// 🔹 Button
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : GestureDetector(
                          onTap: registerTrainer,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: redGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Register Trainer",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
