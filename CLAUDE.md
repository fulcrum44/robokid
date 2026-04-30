# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RoboKid is an Android app that lets children program robots using a visual block editor. The system has three components that work together:

1. **Flutter app** (`app/`) — Android UI with Firebase auth, project persistence, and a WebView that hosts the Blockly editor
2. **Blockly workspace** (`blockly_workplace/`) — JavaScript block editor built with Vite, generates Arduino C++ code from visual blocks
3. **Compilation server** (`compilator_server/`) — Node.js/Express server (git submodule) running inside Docker with Arduino CLI, compiles C++ to `.bin` firmware

The compilation flow: user arranges blocks → Blockly generates C++ → Flutter sends code to server via `POST /compile` → server compiles with Arduino CLI → returns `.bin` → app uploads firmware to Arduino D1 WiFi (ESP8266) via OTA.

## Build & Run Commands

### Blockly workspace
```bash
cd blockly_workplace
npm install
npm run dev          # Dev server at localhost:5173
npm run build        # Production build to dist/
npm run build:flutter # Build + copy single-file HTML to app/assets/blockly_editor.html
```

### Flutter app
```bash
cd app
flutter clean	     # Cleans flutter dependencies and configurations
flutter pub get
flutter run          # Run on connected device/emulator
flutter analyze      # Dart static analysis
flutter test         # Run tests
```

### Compilation server
```bash
cd compilator_server
docker build -t compilador_robokid .
docker run -p 3000:3000 compilador_robokid
```

## Architecture

### Flutter ↔ Blockly bridge
The Blockly editor is bundled as a single HTML file (`app/assets/blockly_editor.html`) via `vite-plugin-singlefile` and loaded in an Android WebView. Communication uses a `FlutterChannel` JavaScriptChannel:

- **JS → Dart**: `FlutterChannel.postMessage(JSON)` with message types: `blocklyReady`, `arduinoCode`, `workspaceState`
- **Dart → JS**: `WebViewController.runJavaScript()` calling global functions: `requestCode()`, `requestWorkspaceState()`, `loadWorkspace(json)`, `clearWorkspace()`

After modifying Blockly source, run `npm run build:flutter` to regenerate the asset.

### Arduino code generation
Custom Blockly generator in `blockly_workplace/src/generators/arduino_generator.js`. Block definitions live in `src/blocks/`, generator implementations in `src/generators/`. The generator uses `definitions_` (includes/globals) and `setups_` (setup() body) dictionaries to assemble a complete Arduino sketch with `setup()` and `loop()`.

### Navigation
The app uses `NavegationScreen` with a `BottomNavigationBar` and `IndexedStack` for three tabs: Bloques (block editor), Historial (saved projects), Ajustes (settings). Routes are defined in `app/lib/routes/app_routes.dart`.

### Firebase
- **Auth**: email/password via `FirebaseServices` in `app/lib/services/firebase_services.dart`
- **Firestore**: projects stored in `Proyectos` collection, CRUD in `app/lib/services/firebase_proyectos.dart`. Each project stores `userId`, `nombre`, `workspaceJson` (serialized Blockly state), and `codigoArduino`.

### Target hardware
ESP8266 Arduino D1 WiFi board (`esp8266:esp8266:d1` FQBN). The Docker image installs Servo, NewPing, and AccelStepper libraries. Motor blocks target 28BYJ-48 stepper motors via AccelStepper.

## Key Conventions

- The codebase is written in Spanish and English (variable names, comments, UI strings)
- The compilation server URL in `blocks_user_screen.dart` (`_servidorUrl`) must be updated when the server deployment changes (currently uses ngrok and it's changes are not expected)
- Theme is managed via a static `ValueNotifier<ThemeMode>` on `MyApp` and persisted with `SharedPreferences`
- The `compilator_server/` directory is a git submodule pointing to `github.com/fulcrum44/compilador_robokid`
