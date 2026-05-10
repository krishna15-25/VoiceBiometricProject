# Voice Biometric Identification System 🎙️
An automated speaker recognition platform implemented in MATLAB, based on the **Reynolds (2002)** processing pipeline.

## 📌 Overview
This system is **pre-trained** and ready for immediate use. It uses a state-of-the-art **Gaussian Mixture Model (GMM)** engine to identify speakers with high precision.

---

## 🚀 Quick Start (No Setup Required)

The "Brain" of the AI is already included in this repository. You can launch the applications immediately in MATLAB:

### 1. Secure Biometric Login
Experience the voice-authenticated login portal:
```matlab
VoiceLoginApp
```

### 2. Live Biometric Detector
Identify any voice sample or record a live snippet:
```matlab
BiometricDetector
```

---

## 📊 Performance Benchmarks
The system has been rigorously tested against 20 speakers from the LibriSpeech corpus.

| AI Model | Accuracy (EER) | Technology |
|----------|----------------|------------|
| **GMM**  | **1.25%**       | **Probabilistic (State-of-the-Art)** |
| VQ       | 2.43%          | Statistical Clustering |
| DTW      | 22.43%         | Temporal Alignment |

---

## ⚙️ The Technical Pipeline
Even though it is pre-trained, the system executes a full 5-stage biometric process in real-time:
1.  **Normalization:** 16kHz Mono audio conversion.
2.  **Highlighting:** Pre-emphasis filtering of vocal resonances.
3.  **Extraction:** 13-coefficient MFCC "Voice Barcodes."
4.  **Cleaning:** Voice Activity Detection (VAD) to ignore silence.
5.  **Matching:** Maximum Likelihood estimation against stored Gaussian clouds.

## 📂 Repository Layout
*   `GMM_System/results/gmm_models.mat`: The trained AI weights.
*   `VoiceLoginApp.m`: The main software interface.
*   `Shared/code/`: Core signal processing mathematical functions.

## 📖 References
*   *Reynolds, D.A. (2002). "An Overview of Automatic Speaker Recognition Technology". Proc. IEEE ICASSP.*
