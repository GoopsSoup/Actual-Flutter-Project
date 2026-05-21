import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_last_app/layout/Home.dart';


const _green = Color(0xFF4CAF50);

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    try {
      final result = await auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Catch specific Firebase errors to show user-friendly messages
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        throw 'The email address is badly formatted.';
      }
      throw e.message ?? 'An unknown error occurred';
    }
  }

  Future<User?> register(String email, String password, String name) async {
    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      final user = result.user;
      
      if (user != null) {
        // FIX: Update the name inside Firebase Auth
        await user.updateDisplayName(name);
        
        // Refresh the user data so the local app sees the new name immediately
        await user.reload();
      }
      
      return auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Password is to weak';
      } else if (e.code == 'email-already-in-user') {
        throw 'An account is already exist for that email';
      } else if (e.code == 'invalid-email') {
        throw 'Invalid email';
      } 
      throw e.message ?? 'Unknown error';
    }
  }

  Future<void> logout() async {
    await auth.signOut();
  }
}

class _Field extends StatefulWidget {
  const _Field({required this.hint, this.isPassword = false, this.controller});
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) => TextField(
        controller: widget.controller,
        obscureText: widget.isPassword && _obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
        ),
      );
}



class _TermsRow extends StatelessWidget {
  const _TermsRow();
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: _green, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'I agree to Terms & Service bla bla bla bla bla bla bla bl bla',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      );
}

class _GreenButton extends StatelessWidget {
  const _GreenButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: onPressed, 
          child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
        ),
      );
}

Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );

// ── Sign Up Page ─────────────────────────────────────────────────────────────

// ── Sign Up Page ─────────────────────────────────────────────────────────────

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim(); 

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return; 
    }

    try {
      final user = await _authService.register(email, password, name );

      if (user != null && mounted) {
        // Success! Navigate to Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false,
        );
      }
    } catch (e) {
      // Show Firebase registration errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Colors.grey[800]),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _label('Name'),
              _Field(
                hint: 'Username',
                controller: _nameController, // Attached Name Controller
              ),
              const SizedBox(height: 16),
              _label('Email Account'),
              _Field(
                hint: 'example@email.com',
                controller: _emailController, // Attached Email Controller
              ),
              const SizedBox(height: 16),
              _label('Password'),
              _Field(
                hint: '', 
                isPassword: true,
                controller: _passwordController, // Attached Password Controller
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
                child: const Text('Already have an account?',
                    style: TextStyle(color: _green, decoration: TextDecoration.underline)),
              ),
              const Spacer(),
              const _TermsRow(),
              const SizedBox(height: 16),
              _GreenButton(
                label: 'Sign Up', 
                onPressed: _handleRegister, // Connected the Register function!
              ),
            ],
          ),
        ),
      );
}

// ── Sign In Page ─────────────────────────────────────────────────────────────

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return; 
    }

    try {
      final user = await _authService.login(email, password);

      if (user != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false,
        );
      }
    } catch (e) {
      // This catches the string we threw from AuthService!
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Colors.grey[800]),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _label('Email'), // Changed from Name
              _Field(
                hint: 'user@email.com', 
                controller: _emailController, // Attach controller
              ),
              const SizedBox(height: 16),
              _label('Password'),
              _Field(
                hint: '**************', 
                isPassword: true, 
                controller: _passwordController, // Attach controller
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: _green, decoration: TextDecoration.underline),
                ),
              ),
              const Spacer(),
              const _TermsRow(),
              const SizedBox(height: 16),
              _GreenButton(
                label: 'Sign In', 
                onPressed: _handleLogin,
              ),
            ],
          ),
        ),
      );
}




