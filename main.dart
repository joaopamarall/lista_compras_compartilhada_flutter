import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/list_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListProvider()),
      ],
      child: MaterialApp(
        title: 'Shopping List',
        theme: ThemeData(
          brightness: Brightness.dark, // Definir o tema como escuro
          primaryColor: const Color(0xFFA146DD), // Cor primária para os botões
          scaffoldBackgroundColor: Colors.black, // Cor de fundo do Scaffold
          appBarTheme: const AppBarTheme(
            color: Color(0xFFA146DD), // Cor da AppBar
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFA146DD), // Cor do botão flutuante
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white), // Texto em branco
            titleLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Cor do título
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA146DD), // Cor dos botões
              textStyle: const TextStyle(fontSize: 18),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFA146DD)), // Cor da borda quando focado
            ),
            labelStyle: TextStyle(color: Color(0xFFA146DD)), // Cor do rótulo
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // Usuário autenticado, vá para a HomeScreen
          return const HomeScreen();
        } else {
          // Usuário não autenticado, vá para a tela de login
          return const LoginScreen();
        }
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = switch (e.code) {
          'user-not-found' => 'Usuário não encontrado',
          'wrong-password' => 'Senha incorreta',
          'invalid-email' => 'Email inválido',
          'user-disabled' => 'Usuário desativado',
          _ => 'Erro ao fazer login: ${e.message}',
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = switch (e.code) {
          'weak-password' => 'A senha é muito fraca',
          'email-already-in-use' => 'Este email já está em uso',
          'invalid-email' => 'Email inválido',
          _ => 'Erro ao registrar: ${e.message}',
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                validator: _validatePassword,
                obscureText: true,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _register,
                child: const Text('Criar nova conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
