# ─── RoboKid Makefile ─────────────────────────────────────────
# Automatiza el build del proyecto
# ──────────────────────────────────────────────────────────────

# ─── Configuración del servidor ───
SERVER_URL = https://democrat-hence-safehouse.ngrok-free.dev
API_TOKEN  = robokid-token-2026
DART_DEFINES = --dart-define=SERVER_URL=$(SERVER_URL) --dart-define=API_TOKEN=$(API_TOKEN)

# ─── Blockly ───
build-blockly:
	cd blockly_workplace && npm run build:flutter

# ─── Flutter ───
run: build-blockly
	cd app && flutter run $(DART_DEFINES)

apk: build-blockly
	cd app && flutter build apk $(DART_DEFINES)

# ─── Servidor de compilación ───
docker-build:
	cd compilator_server && docker build -t compilador_robokid .

docker-run:
	cd compilador_server && docker run -p 3000:3000 compilador_robokid

# ─── Ngrok ───
ngrok:
	ngrok http 3000 --url=democrat-hence-safehouse.ngrok-free.dev

# ─── Instalar dependencias ───
install:
	cd blockly_workplace && npm install
	cd app && flutter pub get
	cd compilator_server && npm install
