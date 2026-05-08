# Herba

A smart greenhouse temperature control system. Herba uses a relay-controlled space heater and a mobile app to maintain the perfect growing environment for your plants.

## Project Structure

This repository is divided into two main components:

* **`herba_controller/`**: The hardware logic. Contains the microcontroller code (C++/Arduino) to read sensor data and trigger the power relay for the space heater.
* **`herbaapp/`**: The mobile interface. A Flutter application used to monitor real-time temperature and set your desired thresholds.

## Features

* **Automated Heating**: Shuts the heater on and off based on real-time sensor data.
* **Hysteresis Logic**: Prevents rapid switching to protect your relay and heater.
* **Mobile Monitoring**: View current greenhouse conditions from your phone.
* **Custom Thresholds**: Set your target temperature directly via the app.

## Getting Started

### Hardware (`herba_controller`)
1.  Open the code in your preferred IDE (e.g., Arduino IDE or VS Code with PlatformIO).
2.  Connect your microcontroller (ESP32 / Arduino).
3.  Configure your Wi-Fi credentials in the source file.
4.  Upload the code to the controller.

### Mobile App (`herbaapp`)
1.  Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
2.  Navigate to the directory: `cd herbaapp`.
3.  Install dependencies: `flutter pub get`.
4.  Run the app: `flutter run`.

## Safety Note

When working with space heaters and relays:
* Ensure your relay is rated for at least **20A** (for 1500W heaters).
* Use a **waterproof enclosure** for all electronics.
* Always include a physical fail-safe in your greenhouse setup.
