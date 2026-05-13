# ROBOKID

## Sistema de Control de Robótica para Niños

Aplicación Android que permite programar robots mediante un editor visual de bloques. El usuario compone programas arrastrando bloques en una interfaz basada en **Blockly**, que genera código **C++** compatible con Arduino. El código se envía a un servidor de compilación autenticado y protegido que ejecuta **Arduino CLI** y devuelve el binario necesario para la placa. La app carga el firmware de forma inalámbrica mediante **OTA (Over The Air)**, preparada para Arduino D1 WiFi (ESP8266).

Incluye autenticación con **email y Google**, gestión de proyectos en la nube, **temas claro/oscuro/sistema**, monitorización de conectividad en tiempo real y detección automática de la conexión con el robot.

---

## Estructura del repositorio

```
robokid/
├── app/                    # Flutter (Android)
├── blockly/                # JavaScript (Blockly + Vite)
├── compilador_robokid/     # Node.js + Express + Docker
├── firmware/               # Plantilla OTA + config hardware (.ino)
└── Makefile                # Automatización del build pipeline
```

---

## Tecnologías utilizadas

| Tecnología | Ámbito |
|---|---|
| Flutter (Dart) | UI principal Android |
| Blockly (JavaScript) | Editor visual de bloques |
| Vite + npm | Build del workspace Blockly |
| webview_flutter | Integración JS ↔ Flutter |
| Arduino CLI | Compilación de código C++ en el servidor |
| Node.js + Express | Servidor de compilación |
| Docker | Contenedor del servidor de compilación |
| ngrok | Túnel para exponer el servidor a internet |
| Firebase Auth | Autenticación de usuarios |
| Cloud Firestore | Base de datos (usuarios y proyectos) |
| google_sign_in | Autenticación con Google |
| connectivity_plus | Monitorización de estado de red |
| SharedPreferences | Persistencia local (tema, sesión) |
| express-rate-limit | Limitación de peticiones al servidor |

---

## Requisitos previos

### General
- make (para automatización con Makefile)
- ngrok (cuenta gratuita con dominio estático)

### Para el workspace de Blockly
- Node.js 20 o superior
- npm

### Para el servidor de compilación
- Node.js 20 o superior
- npm
- Docker

### Para la app Flutter
- Flutter SDK
- Android Studio
- Dispositivo o emulador Android

---

## Puesta en marcha

### Instalación inicial

```bash
make install
```

### Desarrollo (Blockly + Flutter)

```bash
make run
```

### Generar APK de producción

```bash
make apk
```

### Servidor de compilación

```bash
make docker-build
make docker-run
```

### Exponer servidor a internet

```bash
make ngrok
```

Las variables de entorno (URL del servidor y token de autenticación) se configuran en el Makefile y se inyectan automáticamente en el APK mediante `--dart-define`.

### Comandos individuales (sin Makefile)

<details>
<summary>Workspace de Blockly</summary>

```bash
cd blockly
npm install
npm run dev            # servidor de desarrollo en http://localhost:5173
npm run build:flutter  # genera HTML single-file y copia a app/assets/
```

</details>

<details>
<summary>Servidor de compilación</summary>

```bash
cd compilador_robokid
npm install
docker build -t compilador_robokid .
docker run -p 3000:3000 compilador_robokid
```

</details>

<details>
<summary>App Flutter</summary>

```bash
cd app
flutter pub get
flutter run --dart-define=SERVER_URL=https://tu-url.ngrok-free.app --dart-define=API_TOKEN=tu-token
```

</details>

---

## Flujo de compilación y carga

1. El usuario compone un programa con bloques en Blockly
2. Blockly genera el código C++ correspondiente
3. Flutter recibe el código a través del JavaScriptChannel
4. Se inyecta automáticamente la plantilla OTA base al código
5. Flutter envía el código al servidor mediante una petición `POST /compile` con token de autenticación
6. El servidor ejecuta Arduino CLI y devuelve el binario `.bin`
7. El dispositivo se conecta al punto de acceso WiFi de la placa ("RoboKid")
8. La app detecta automáticamente la conexión con el robot y verifica que los datos móviles estén desactivados
9. El binario se envía a la placa mediante HTTP POST al servidor OTA embebido

---

## Categorías de bloques disponibles

| Categoría | Bloques |
|---|---|
| Movimiento | Mover robot (adelante, atrás, izquierda, derecha, parar), cambiar velocidad |
| Servo | Girar servo a un ángulo |
| Sensores | Leer distancia, detectar obstáculo |
| Tiempo | Esperar segundos |
| Control | Si/sino (condicional), repetir N veces, mientras/hasta |
| Matemáticas | Número, operación aritmética |
| Variables | Crear y asignar variables |
| Funciones | Definir y llamar funciones reutilizables |

---

## Usuarios del sistema

- **Invitado** — puede usar el editor de bloques y compilar, pero no guardar proyectos en la nube
- **Registrado** — acceso completo mediante email o **Google Sign-In**, puede guardar y cargar proyectos desde Cloud Firestore
- **Robot (Arduino D1 WiFi)** — recibe el firmware por OTA y ejecuta el programa

---

## Seguridad del servidor

- Autenticación por token Bearer en cada petición
- Limitación de 10 peticiones por minuto por IP
- Validación de placa contra lista blanca
- Sanitización de errores (sin rutas del servidor expuestas)
- Ejecución segura con `execFile()` (prevención de inyección de comandos)

---

## Notas

- La huella digital SHA-1 de la máquina donde se genere el APK debe estar registrada en la configuración del proyecto de Firebase para que los servicios de Google funcionen correctamente
- El servidor de compilación requiere Docker y ngrok ejecutándose en el equipo de desarrollo
- El dominio de ngrok es estático y gratuito (no cambia entre sesiones)
- Cualquier cambio en `blockly/src/` requiere ejecutar `make build-blockly` o `make run` para que se refleje en la app
