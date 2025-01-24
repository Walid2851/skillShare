import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final AuthController authController = Get.find();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      "Let's create your account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: firstNameController,
                      hint: 'First name',
                      icon: Icons.person_outline,
                      autofillHints: [AutofillHints.givenName],
                    ),
                    _buildTextField(
                      controller: lastNameController,
                      hint: 'Last name',
                      icon: Icons.person_outline,
                      autofillHints: [AutofillHints.familyName],
                    ),
                    _buildTextField(
                      controller: usernameController,
                      hint: 'Username',
                      icon: Icons.alternate_email,
                      autofillHints: [AutofillHints.username],
                    ),
                    _buildTextField(
                      controller: emailController,
                      hint: 'E-Mail',
                      icon: Icons.email_outlined,
                      autofillHints: [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      controller: phoneController,
                      hint: 'Phone Number',
                      icon: Icons.phone_outlined,
                      autofillHints: [AutofillHints.telephoneNumber],
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      autofillHints: [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: 32),
                    Obx(() => _buildSignUpButton()),
                    const SizedBox(height: 16),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                          children: [
                            TextSpan(text: "By signing up, you agree to our "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: " and "),
                            TextSpan(
                              text: "Terms of use",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          'assets/apple_icon.png',
                          onPressed: () {},
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          'assets/google_icon.png',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    List<String> autofillHints = const [],
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black38),
          prefixIcon: Icon(icon, color: Colors.black54, size: 22),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: isPassword
              ? Icon(Icons.visibility_outlined, color: Colors.black54, size: 22)
              : null,
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) return '$hint is required';
          if (hint == 'E-Mail' && !GetUtils.isEmail(value!))
            return 'Invalid email format';
          if (hint == 'Password' && value!.length < 6)
            return 'Password must be at least 6 characters';
          return null;
        },
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authController.isLoading.value
            ? null
            : () {
          if (_formKey.currentState!.validate()) {
            authController.signUp(
              email: emailController.text.trim(),
              password: passwordController.text,
              firstName: firstNameController.text.trim(),
              lastName: lastNameController.text.trim(),
              username: usernameController.text.trim(),
              phone: phoneController.text.trim(),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: authController.isLoading.value
            ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(
          'Create Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String iconPath, {required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(iconPath, height: 24),
      ),
    );
  }
}