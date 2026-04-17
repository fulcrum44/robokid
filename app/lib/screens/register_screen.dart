import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:robokid/services/firebase_crud.dart';
import 'package:robokid/services/firebase_services.dart';
import 'package:robokid/widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenStateAlumn();
}

class _RegisterScreenStateAlumn extends State<RegisterScreen> {
  // controlador de visibilidad de la contraseña mediante botón-icóno
  bool obscureText = true;
  //Instancio la clase del firebase
  final FirebaseServices firebaseAuth = FirebaseServices();
  // Booleano para el botón de registro
  bool buttonIsLoading = false;
  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: theme.scaffoldBackgroundColor,
      // Para que el teclado no empuje los SnackBars
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.0225,
          horizontal: MediaQuery.of(context).size.height * 0.0225,
        ),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Text(
                'Registro',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.0225),

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

              SizedBox(height: MediaQuery.of(context).size.height * 0.0175),

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

              SizedBox(height: MediaQuery.of(context).size.height * 0.0175),

              // Nombre
              LoginFormWidget(
                hintText: 'Nombre',
                icon: Icons.person_add_alt_1,
                controller: nameController,
                enabled: !buttonIsLoading,
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.0175),

              // Apellidos
              LoginFormWidget(
                hintText: 'Apellidos',
                icon: Icons.person_add_alt_1,
                controller: lastNameController,
                enabled: !buttonIsLoading,
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.035),

              // Botón de registro
              CustomRegisterButton(
                theme: theme,
                content: buttonIsLoading
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0225,
                        width: MediaQuery.of(context).size.height * 0.0225,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Registrarse', style: theme.textTheme.titleMedium),
                // El botón se deshabilia si la panalla está cargando
                onPressed: buttonIsLoading
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();

                        if (!formKey.currentState!.validate()) {
                          CustomSnackBar.showSnackBar(
                            'Por favor, rellena todos los campos',
                            context,
                            theme,
                          );
                          return;
                        }

                        final String email = emailController.text.trim();
                        final String lastName = lastNameController
                            .text // está sin usar, pendiente de un user_sevice con un insertUsuario()
                            .trim();
                        final String name = nameController.text
                            .trim(); // está sin usar, pendiente de un user_sevice con un insertUsuario()

                        setState(() => buttonIsLoading = true);

                        try {
                          final user = await firebaseAuth.createUser(
                            email: email,
                            password: passwordController
                                .text, // llamo la contraseña directamente del controlador para no tenerla guardada en una variable. el controlador solamente mira el texto del campo contraseña cuando se le da al botón de 'Registrarse' y luego, al cambiar de panalla con el dispose() se limpia el controlador.
                          );
                          await insertUsuario(user!.uid, name, lastName, email);
                          await user.sendEmailVerification();

                          if (context.mounted) {
                            CustomSnackBar.showSnackBar(
                              '¡Correo de verificación enviado! Comprueba spam',
                              context,
                              theme,
                            );
                          }
                          Future.delayed(const Duration(seconds: 1), () {
                            if (context.mounted) {
                              Navigator.pushNamed(context, 'login');
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
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.035),

              Text(
                'Ó',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.035),

              CustomRegisterButton(
                theme: theme,
                content: Text(
                  'Iniciar sesión',
                  style: theme.textTheme.titleMedium,
                ),
                onPressed: () => Navigator.pushNamed(context, 'login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
