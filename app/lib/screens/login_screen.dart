import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:robokid/services/supabase_services.dart';
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
  // BORRAR
  bool mostrarBotones = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Instancio la clase del supabaseServices
    final SupabaseServices supabaseServices = SupabaseServices();
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
<<<<<<< Antonio
      
=======
>>>>>>> main
        appBar: CustomAppBar(logo: 'Robokids'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.only(top: 20),
                  width: 350,
                  height: 500,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: containerBorder, width: 3),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      Text('Iniciar sesión', style: theme.textTheme.titleLarge),

                      const SizedBox(height: 20),

                      // Correo
                      LoginFormWidget(
                        controller: emailController,
                        hintText: 'Correo electrónico',
                        keyboardType: TextInputType.emailAddress,
                        enabled: !buttonIsLoading,
                      ),

                      const SizedBox(height: 13),

                      // Contraseña
                      LoginFormWidget(
                        controller: passwordController,
                        hintText: 'Contraseña',
                        obscureText: obscureText,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        enabled: !buttonIsLoading,
                      ),

                      const SizedBox(height: 20),

                      // Botón de iniciar sesión
                      ElevatedButton(
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
                                final String email = emailController.text
                                    .trim();
                                final String password = passwordController.text;

                                setState(() => buttonIsLoading = true);

                                try {
                                  //le decimos qie espero a ver si devuelve datos antes de poner el snabar y de qe te lleve a la pantalla
                                  final usuario = await supabaseServices
                                      .iniciarSesion(
                                        email: email,
                                        password: password,
                                      );
                                  if (usuario != null) {
                                    if (context.mounted) {
                                      CustomSnackBar.showSnackBar(
                                        '¡Bienvenido !',
                                        context,
                                        theme,
                                      );
                                      Navigator.pushNamed(
                                        context,
                                        'blocksScreen',
                                      );
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
                                } finally {
                                  if (mounted) {
                                    setState(() => buttonIsLoading = false);
                                  }
                                }
                              },
                        child: buttonIsLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: containerBorder,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Iniciar sesión',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'O',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'blocksScreen');
                        },
                        child: Text(
                          'Continuar como invitado',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Contenedor secundario
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 8),
                  width: 350,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: containerBorder, width: 3),
                  ),

                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        '¿Aún no tienes una cuenta?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Botón de registro
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'registerUser');
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
            width: 280,
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
