import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:robokid/services/services.dart';
import 'package:robokid/theme/app_theme.dart';
import 'package:robokid/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  // Booleano para el botón de inicio de sesión
  bool buttonIsLoading = false;
  // Booleano para el icono para ver la contraseña
  bool obscureText = true;
  // BORRAR ?
  bool showButtons = false;

  final FirebaseServices firebaseServices = FirebaseServices();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Instancio la clase del firebase
    final FirebaseServices firebaseServices = FirebaseServices();
    final theme = Theme.of(context);
    // Color del borde de los contenedores
    final containerBorder = theme.brightness == Brightness.light
        ? AppTheme.lightTheme.primaryColorLight
        : AppTheme.darkTheme.primaryColorDark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await onBackButtonPressed(context, theme);

        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(),
        backgroundColor: theme.scaffoldBackgroundColor,
        // Para que el teclado no empuje los SnackBars
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                // Contenedor primario
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.height * 0.0225,
                  ),
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.0225,
                  ),
                  width: MediaQuery.of(context).size.width * 0.825,
                  height: MediaQuery.of(context).size.height * 0.62,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: containerBorder, width: 3),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0225,
                      ),

                      Text('Iniciar sesión', style: theme.textTheme.titleLarge),

                      const SizedBox(height: 20),

                      // Correo
                      LoginFormWidget(
                        controller: emailController,
                        hintText: 'Correo electrónico',
                        keyboardType: TextInputType.emailAddress,
                        enabled: !buttonIsLoading,
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0175,
                      ),

                      // Contraseña
                      LoginFormWidget(
                        controller: passwordController,
                        hintText: 'Contraseña',
                        obscureText: obscureText,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscureText = !obscureText),
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        enabled: !buttonIsLoading,
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0225,
                      ),

                      // Botón de iniciar sesión
                      CustomRegisterButton(
                        theme: theme,
                        content: buttonIsLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Iniciar sesión',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                        onPressed: buttonIsLoading
                            ? null
                            : () async {
                                // Quitamos el focus del botón
                                FocusScope.of(context).unfocus();
                                // Comprobamos si el login está vacío
                                if (emailController.text.trim().isEmpty ||
                                    passwordController.text.trim().isEmpty) {
                                  CustomSnackBar.showSnackBar(
                                    'Debe introducir correo y contraseña',
                                    context,
                                    theme,
                                  );
                                  return;
                                }
                                final String email = emailController.text.trim();
                                final String password = passwordController.text;

                                setState(() => buttonIsLoading = true);

                                try {
                                  //le decimos qie espero a ver si devuelve datos antes de poner el snabar y de qe te lleve a la pantalla
                                  final user = await firebaseServices.login(
                                    email: email,
                                    password: password,
                                  );
                                  if (user != null) {
                                    if (context.mounted) {
                                      CustomSnackBar.showSnackBar(
                                        '¡Bienvenido !',
                                        context,
                                        theme,
                                      );
                                      Navigator.pushReplacementNamed(context, 'navigation');
                                    }
                                  } else {
                                    if (context.mounted) {
                                      CustomSnackBar.showSnackBar(
                                        'Correo o contraseña incorrectos',
                                        context,
                                        theme,
                                      );
                                    }
                                  }
                                } on FirebaseAuthException catch (e) {
                                  //Si hay un error porque no encontro al usuario; no salta el siguiente print
                                  if (e.message!.contains(
                                    'credential is incorrect',
                                  )) {
                                    if (context.mounted) {
                                      CustomSnackBar.showSnackBar(
                                        'Usuario no encontrado o credenciales incorrectas',
                                        context,
                                        theme,
                                      );
                                    }
                                  } else {
                                    if (context.mounted) {
                                      CustomSnackBar.showSnackBar(
                                        'Error en la conexion a Firebase',
                                        context,
                                        theme,
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    CustomSnackBar.showSnackBar(
                                      'Error al iniciar sesión',
                                      context,
                                      theme,
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => buttonIsLoading = false);
                                  }
                                }
                              },
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0225,
                      ),

                      Text(
                        'O',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0225,
                      ),

                      // Botón de Google
                      GoogleButton(
                        screen: 'login',
                        onPressed: buttonIsLoading
                          ? null
                          : () async {
                            setState(() => buttonIsLoading = true);
                            try {
                              final user = await firebaseServices.googleLogin(context);

                              if (user != null) {
                                if (context.mounted) {
                                  CustomSnackBar.showSnackBar(
                                    '¡Bienvenido!',
                                    context,
                                    theme,
                                  );
                                }
                              }
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'account-exists-with-different-credential') {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: theme.scaffoldBackgroundColor,
                                    title: Text('Cuenta ya existente', style: theme.textTheme.titleLarge,),
                                    content: Text(
                                      'Ya tienes una cuenta con ese correo. '
                                      'Inicia sesión con tu contraseña y desde dentro '
                                      'de la app podrás vincular Google.',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Entendido'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                CustomSnackBar.showSnackBar(
                                  'Error al iniciar con Google',
                                  context,
                                  theme,
                                );
                              }
                            } finally {
                              if (mounted) setState(() => buttonIsLoading = false);
                            }
                          },
                        textTheme: theme.textTheme.titleMedium
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0225,
                      ),

                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'navigation');
                        },
                        child: Text(
                          'Continuar como invitado',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0225,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.0225),

                // Contenedor secundario
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01075,
                  ),
                  width: MediaQuery.of(context).size.width * 0.825,
                  height: MediaQuery.of(context).size.height * 0.125,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: containerBorder, width: 3),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0225,
                      ),
                      Text(
                        '¿Aún no tienes una cuenta?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Botón de registro
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'signup');
                        },
                        child: Text(
                          'Regístrate ahora',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.lightBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Ventana de salida de aplicación
  Future<bool> onBackButtonPressed(
    BuildContext context,
    ThemeData theme,
  ) async {
    bool? exitApp = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.825,
            child: Text(
              "¿Desea cerrar la aplicación?",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("No", style: theme.textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Sí", style: theme.textTheme.titleMedium),
                ),
              ],
            ),
          ],
        );
      },
    );

    return exitApp ?? false;
  }
}