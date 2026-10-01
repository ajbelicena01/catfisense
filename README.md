# CatFiSense

**IoT-based smart pond monitoring system for catfish aquaculture.**
CatFiSense tracks key water-quality parameters in real time and alerts pond owners
before conditions become harmful to their fish, even when internet access is poor.

> Capstone project, BS Information Technology (Networking), Iloilo, Philippines

---

## About the App

The CatFiSense mobile app is the pond owner's window into the sensor system.
An ESP32-based device in the pond measures the water, does the threshold
calculations on the device (edge computing), and uploads results to Firebase.
The app displays the readings, history, and alerts.

## Features

- **Live dashboard**: current pH, temperature, dissolved oxygen, and turbidity
- **History and trends**: charts of past readings per pond
- **Alerts**: push notifications (FCM) when readings leave the safe range
- **Offline SMS alerts**: the device sends SMS through its GSM/LTE module when
  internet is unavailable
- **Pond selector**: monitor multiple ponds
- **Cached data**: last known readings stay viewable offline
- ***NEW*** **Logbook**: owners/caretakers could log their activity for easier tracking
- ***NEW*** **Maintenance**: for the dissolved oxygen electrolyte and pH buffer changing. Along with topping-up the prepaid WiFi Modem and Gateway load
- ***NEW*** **Admin Dashboard**: registered admins have heightened access
- ***NEW*** **Language**: Available in English and Filipino
