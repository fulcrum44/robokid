import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:robokid/services/firebase_services.dart';
import 'package:robokid/theme/app_theme.dart';
import 'package:robokid/widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenStateAlumn();
}

class _RegisterScreenStateAlumn extends State<RegisterScreen> {
  //para ver el texto luego cuando pones la contraseña
  bool obscureText = true;
  //Instancio la clase del firebase
  final FirebaseServices firebaseServices = FirebaseServices();
  // Booleano para el botón de registro
  bool buttonIsLoading = false;
  final formKey = GlobalKey<FormState>();

  final FocusNode focusNode = FocusNode();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(logo: 'Robokids'),
      backgroundColor: theme.scaffoldBackgroundColor,
      // Para que el teclado no empuje los SnackBars
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              Text(
                'Crear una cuenta de usuario',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),

              const SizedBox(height: 20),

              // Correo electrónico
              LoginFormWidget(
                hintText: 'Correo electrónico',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
                controller: emailController,
                enabled: !buttonIsLoading,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor introduzca su email';
                  } else if (!RegExp(
                    r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9][a-zA-Z0-9-]{0,253}\.)*[a-zA-Z0-9][a-zA-Z0-9-]{0,253}\.[a-zA-Z0-9]{2,}$",
                  ).hasMatch(value)) {
                    return 'Introduzca una dirección de correo válida';
                  } else {
                    return null;
                  }
                },
              ),

              const SizedBox(height: 15),

              LoginFormWidget(
                hintText: 'Contraseña',
                keyboardType: TextInputType.visiblePassword,
                icon: Icons.lock_outline,
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
                controller: passwordController,
                enabled: !buttonIsLoading,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor introduzca la contraseña';
                  } else if (!RegExp(
                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])[^\s]{8,}$',
                  ).hasMatch(value)) {
                    return 'Al menos 8 caracteres, una letra mayúscula y minúscula, \nun número y un carácter especial';
                  } else {
                    return null;
                  }
                },
              ),

              const SizedBox(height: 15),

              // Nombre
              LoginFormWidget(
                hintText: 'Nombre',
                icon: Icons.person_add_alt_1,
                controller: nameController,
                enabled: !buttonIsLoading,
              ),
              const SizedBox(height: 15),

              // Apellidos
              LoginFormWidget(
                hintText: 'Apellidos',
                icon: Icons.person_add_alt_1,
                controller: lastNameController,
                enabled: !buttonIsLoading,
              ),

              const SizedBox(height: 15),

              // Botón de registro
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: theme.elevatedButtonTheme.style?.copyWith(
                    backgroundColor: WidgetStateProperty.all(AppTheme.robokids),
                  ),
                  // Si está cargando, onPressed es null y el botón se deshabilita automáticamente
                  onPressed: buttonIsLoading
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();

                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final String email = emailController.text.trim();
                          final String password = passwordController.text;
                          final String lastName = lastNameController.text
                              .trim();
                          final String name = nameController.text.trim();

                          if (email.isEmpty ||
                              password.isEmpty ||
                              lastName.isEmpty ||
                              name.isEmpty) {
                            CustomSnackBar.showSnackBar(
                              'Por favor, rellena todos los campos',
                              context,
                              theme,
                            );
                            return;
                          }

                          // --- INICIO CARGA ---
                          setState(() => buttonIsLoading = true);

                          try {
                            final user = await firebaseServices.createUser(
                              email: email,
                              password: password,
                            );
                            await user!.sendEmailVerification();
                            if (context.mounted) {
                              CustomSnackBar.showSnackBar(
                                '¡Correo de verificación enviado! Comprueba spam',
                                context,
                                theme,
                              );
                            }
                            Future.delayed(const Duration(seconds: 1), () {
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  'login',
                                );
                              }
                            });
                          } on FirebaseAuthException catch (e) {
                            //Si hay un error porque no encontro al usuario; no salta el siguiente print
                            if (e.code == 'email-already-in-use') {
                             if (context.mounted) {
                              CustomSnackBar.showSnackBar(
                                '¡El usuario ya está registrado',
                                context,
                                theme,
                              );
                            }
                              //Si hay un error porque la contraseña es incorrecta; no salta el siguiente print
                            } else if (e.code == 'weak-password') {
                              if (context.mounted) {
                              CustomSnackBar.showSnackBar(
                                'Contraseña demasiado débil',
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
                          } catch (error) {
                            debugPrint('Error en el registro: $error');
                            if (context.mounted) {
                              CustomSnackBar.showSnackBar(
                                'Error al registrar',
                                context,
                                theme,
                              );
                            }
                          } finally {
                            // Usamos finally para asegurar que el botón se reactive
                            // pase lo que pase, a menos que hayamos navegado fuera.
                            setState(() => buttonIsLoading = false);
                          }
                        },
                  child: buttonIsLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Registrarse', style: theme.textTheme.titleMedium),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'O',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: theme.elevatedButtonTheme.style?.copyWith(
                    backgroundColor: WidgetStateProperty.all(AppTheme.robokids),
                  ),
                  onPressed: () => Navigator.pushNamed(context, 'login'),

                  child: Text(
                    'Volver a la pantalla de login',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
