import 'package:flutter/material.dart';
import 'package:robokid/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServices {
  final String urlDatabase = SupabaseConfig.urlSupabase;
  final String anonKeyDatabase = SupabaseConfig.anonKeySupabase;
  //conexion al supabase
  Future<void> supabaseConnection() async {
    await Supabase.initialize(url: urlDatabase, anonKey: anonKeyDatabase);
  }
  static final _supabase = Supabase.instance.client;
  //registri de usuaerio al supabase
  Future<void> registrarUsuario({
    required String name,
    required String lastName,
    required String email,
    required String password,
  }) async {

    await _supabase.from('Usuarios').insert({
      'email': email,
      'name': name,
      'last_name': lastName,
      'password': password,
    });
  }
  Future<Map<String, dynamic>?> iniciarSesion({
    required String email,
    required String password,
  }) async {


    try {
      // Usamos .match() para obligar a que AMBOS campos coincidan a la vez
      final inicioSesion = await _supabase
          .from('Usuarios')
          .select()
          .match({
            'email': email,
            'password': password,
          })
          .maybeSingle();

      //Comprbamos si de verdad estan igual, pa que no de fallos (o te meta solo con uno de los dos que ma estao pasando)
      if (inicioSesion != null) {
        if (inicioSesion['email'] == email && inicioSesion['password'] == password) {
          return inicioSesion; 
        } else {
          return null; 
        }
      }

      return null; 
      
    } catch (e) {
      debugPrint('Error en la consulta de login: $e');
      return null;
    }
  }
}