# 🚥 Letrero LED Pro (Estilo LedArt / LED Scroller)

> Aplicación móvil profesional de letreros y pancartas LED para **Android** e **iOS**, con efectos realistas de matriz de diodos, brillo neón y pipeline de integración continua con **GitHub Actions**.

---

## 🌟 Características Principales

* 🟢 **Simulación Real de Matriz LED**:
  * **Puntos LED (Dot Matrix)**: Diodos circulares con rejilla de fondo apagada idéntica a los paneles físicos.
  * **Matriz SMD**: Diodos cuadrados de alta densidad (estilo valla publicitaria / estadio).
  * **Neón Puro / Glow**: Tubos de luz vibrantes con resplandor difuminado (*bloom*).
  * **Arcade 8-Bit**: Estilo retro vintage.
* ⚡ **Control Total de Velocidad**:
  * Slider de velocidad ultra-suave desde **0.0 (Pausado/Fijo)** hasta **10.0 (Ultra Rápido)**.
* ↔️ **Direcciones de Movimiento**:
  * Derecha a Izquierda (estándar letrero).
  * Izquierda a Derecha.
  * Arriba a Abajo.
  * Abajo a Arriba.
  * Fijo / Centrado.
* 🎨 **Personalización Cromática Completa**:
  * **14 Colores Neón Preset**: Verde Matrix, Azul Cyber, Magenta Eléctrico, Rojo Fuego, Ámbar, Blanco Frío, etc.
  * **Selector de Color Completo**: Rueda HSV/RGB para cualquier tono imaginable.
  * **Modo Arcoíris RGB Dinámico**: Ciclo de espectro multicolor animado en tiempo real.
  * Color de fondo del panel personalizable.
* 🚨 **Efectos Especiales**:
  * **Parpadeo / Flash**: Desactivado, Lento, Medio, Rápido y Modo Estroboscópico (*Strobe*).
  * **Modo Espejo (Retrovisor)**: Invierte horizontalmente el texto para que pueda leerse a través del retrovisor del auto.
  * **Brillo / Resplandor regulable**: Control de halo y luminosidad de los LEDs.
* 📱 **Experiencia de Pantalla Completa Inmersiva**:
  * Oculta automáticamente barras de estado y navegación del sistema.
  * **Wakelock Integrado**: La pantalla nunca se apaga ni se suspende mientras el letrero esté activo.
  * **HUD Táctil Discreto**: Un toque muestra la barra de pausa/velocidad; doble toque regresa al editor.
  * **Orientación Automática**: Forzado horizontal (Landscape) ideal para conciertos, vertical o automático.
* 💾 **Plantillas y Favoritos**:
  * Presets listos para usar: *Concierto 🎸, Taxi 🚕, Aeropuerto ✈️, Cumpleaños 🎂, Oferta 🔥, SOS 🚨*.
  * Guarda tus propios textos y configuraciones en memoria local (`SharedPreferences`).

---

## 🚀 Cómo Probar la Aplicación en Local

### Requisitos:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión 3.20+ recomendada).

### Pasos:
```bash
# 1. Obtener dependencias
flutter pub get

# 2. Ejecutar análisis y pruebas
flutter analyze
flutter test

# 3. Probar en dispositivo conectado o emulador
flutter run
```

---

## 📦 Subir a GitHub y Generar APK (Android) e IPA (iOS)

Este proyecto ya viene con **GitHub Actions** configurado en `.github/workflows/` para compilar **Android e iOS en la nube automáticamente**.

### 1. Inicializar y subir a tu repositorio en GitHub

Ejecuta en tu terminal:

```bash
# 1. Agregar todos los archivos al commit
git add .
git commit -m "feat: Letrero LED Pro completo para Android e iOS"

# 2. Configurar la rama principal
git branch -M main

# 3. Enlazar con tu repositorio de GitHub (cambia la URL por la tuya)
git remote add origin https://github.com/TU_USUARIO/TU_REPOSITORIO.git

# 4. Subir el proyecto
git push -u origin main
```

---

## 🤖 Workflows de GitHub Actions Incluidos

El proyecto cuenta con 3 flujos de trabajo automatizados en la carpeta `.github/workflows/`:

| Archivo | Plataforma | Descripción |
| :--- | :--- | :--- |
| `build_android.yml` | 🤖 **Android** | Compila el `.apk` de lanzamiento y el `.aab` (Bundle para Play Store) en runners Ubuntu de GitHub. |
| `build_ios.yml` | 🍎 **iOS** | Compila en un runner **macOS gratuito de GitHub** la app de iOS (`--no-codesign`), empaquetando el `.ipa` sin necesidad de tener una Mac física. |
| `ci_release.yml` | 🌐 **Android + iOS** | Se ejecuta al crear una etiqueta (ej. `v1.0.0`) y publica automáticamente un **Release** de GitHub con los ejecutables listos para descargar. |

### ¿Dónde descargas los instalables compilados por GitHub?

1. Entra a tu repositorio en GitHub en el navegador.
2. Haz clic en la pestaña **Actions** (en la parte superior).
3. Selecciona la última ejecución (ej. *Build Android APK* o *Build iOS App*).
4. En la parte inferior bajo la sección **Artifacts**, descarga:
   * 📲 `letrero-led-android-apk`: El archivo `app-release.apk` listo para instalar en cualquier Android.
   * 🍏 `letrero-led-ios-ipa`: El paquete `LetreroLED-iOS-unsigned.ipa` para sideloading (AltStore, Sideloadly, TrollStore) o firma con certificado de desarrollador de Apple.

---

## 🛠️ Estructura del Código

```text
lib/
├── models/
│   └── led_config.dart            # Modelo de datos, presets, enum de dirección y estilos
├── services/
│   └── storage_service.dart       # Persistencia local con SharedPreferences
├── widgets/
│   ├── led_matrix_painter.dart    # CustomPainter: rejilla de diodos LED y máscara perforada
│   ├── led_display_widget.dart    # Motor de animación de marquesina, parpadeo y arcoíris
│   ├── color_picker_sheet.dart    # Selector de 14 tonos neón + rueda HSV completa
│   └── preset_selector_chips.dart # Chips rápidos para conciertos, taxi, aeropuerto, etc.
├── screens/
│   ├── studio_screen.dart         # Editor principal con vista previa en vivo y controles
│   └── fullscreen_led_screen.dart # Pantalla completa inmersiva, bloqueo de rotación y HUD táctil
└── main.dart                      # Configuración de tema cyberpunk/dark y arranque
```

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Puedes usarlo, distribuirlo y modificarlo libremente para tus propios letreros LED o subirlo a las tiendas de aplicaciones.
