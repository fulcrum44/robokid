import 'dart:async';
import 'package:flutter/material.dart';
import 'package:robokid/services/supabase_services.dart';
import 'package:robokid/theme/app_theme.dart';
import 'package:robokid/widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenStateAlumn();
}

class _RegisterScreenStateAlumn extends State<RegisterScreen> {
  //Instancio la clase del supabaseServices
  final SupabaseServices supabaseServices = SupabaseServices();
  // Booleano para el AlertDialog
  bool loadTime = false;
  // Booleano para el botón de registro
  bool buttonIsLoading = false;
  final formKey = GlobalKey<FormState>();

  final FocusNode focusNode = FocusNode();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listener para el FocusNode del campo de teléfono
    focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    // Temporizador para el AlertDialog
    Future.delayed(Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          loadTime = true;
        });
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Color del CircularProgressIndicator
    final loadingColor = theme.brightness == Brightness.light
        ? AppTheme.lightTheme.primaryColorLight
        : AppTheme.darkTheme.primaryColorDark;

    return Scaffold(
      appBar: customappBar(context: context, logo: 'Robokids'),
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
                obscureText: true,
                controller: passwordController,
                enabled: !buttonIsLoading,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor introduzca la contraseña';
                  } else if (!RegExp(
                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[a-zA-Z\d@$!%*?&#]{8,}$',
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
                            await supabaseServices.registrarUsuario(
                              name: name,
                              lastName: lastName,
                              email: email,
                              password: password,
                            );
                            if (context.mounted) {
                              CustomSnackBar.showSnackBar(
                                '¡Registro completado!',
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
                          } catch (error) {
                            debugPrint('Error en el registro: $error');
                            if (context.mounted) {
                              CustomSnackBar.showSnackBar(
                                'Error al registrar: $error',
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
                          child: CircularProgressIndicator(
                            color: loadingColor,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Registrarse'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
