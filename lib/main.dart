import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/list_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFA146DD),
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            color: Color(0xFFA146DD),
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFA146DD),
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
            titleLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA146DD),
              textStyle: const TextStyle(fontSize: 18),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFA146DD)),
            ),
            labelStyle: TextStyle(color: Color(0xFFA146DD)),
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
          return const HomeScreen();
        } else {
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
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = switch (e.code) {
          'invalid-credential' => 'Credenciais inválidas',
          'operation-not-allowed' => 'Operação não permitida',
          _ => 'Erro ao fazer login com o Google: ${e.message}',
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


  //feture futura

  Future<void> _signInWithApple() async {
    // Implementar a lógica de autenticação com Apple aqui
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login com Apple em Desenvolvimento =)')),
    );
  }


// para funcionamento correto precisa definir o sdk do facebook de maneira correta
  Future<void> _signInWithFacebook() async {
    setState(() => _isLoading = true); // Indica que o processo de login está em andamento.
    try {
      // Inicia o login do Facebook
      final result = await FacebookAuth.instance.login();

      // Verifica se o login foi bem-sucedido
      if (result.status == LoginStatus.success) {
        // Obtém o token de acesso
        final accessToken = result.accessToken;

        // Verifica se o accessToken é nulo
        if (accessToken != null) {
          // Cria as credenciais para o Firebase
          final credential = FacebookAuthProvider.credential(accessToken.token);

          // Faz o login no Firebase
          await _auth.signInWithCredential(credential);
        }
      } else {
        // Caso não tenha sido bem-sucedido, mostre uma mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Erro ao autenticar com o Facebook'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Lida com exceções de autenticação do Firebase
      if (mounted) {
        String message = switch (e.code) {
          'invalid-credential' => 'Credenciais inválidas',
          'operation-not-allowed' => 'Operação não permitida',
          _ => 'Erro ao fazer login com o Facebook: ${e.message}',
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Independente do resultado, o loading é encerrado
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.golf_course), // Ícone do Google
                    color: Colors.red,
                    onPressed: _signInWithGoogle,
                  ),
                  IconButton(
                    icon: const Icon(Icons.apple), // Ícone da Apple
                    color: Colors.white,
                    onPressed: _signInWithApple,
                  ),
                  IconButton(
                    icon: const Icon(Icons.facebook), // Ícone do Facebook
                    color: Colors.blue,
                    onPressed: _signInWithFacebook,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
