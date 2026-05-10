# Voice Biometric Identification System 🎙️
An automated speaker recognition platform implemented in MATLAB, based on the **Reynolds (2002)** processing pipeline.

## 📌 Overview
This project identifies a speaker's identity by analyzing their unique vocal characteristics. It covers the full history of biometric recognition by comparing three distinct approaches:
1.  **Dynamic Time Warping (DTW):** A temporal alignment algorithm.
2.  **Vector Quantization (VQ):** A statistical clustering approach (2.43% EER).
3.  **Gaussian Mixture Models (GMM):** The state-of-the-art probabilistic engine (**1.25% EER**).

---

## ⚙️ How It Works (The Pipeline)
The system follows a professional 5-stage biometric pipeline:
1.  **Audio Input:** Standardized 16kHz Mono recordings.
2.  **Pre-processing:** Pre-emphasis filtering to highlight vocal tract resonances.
3.  **Feature Extraction:** 13-coefficient MFCC extraction.
4.  **Modeling (The AI):**
    *   **VQ:** Uses LBG Clustering (128 centroids).
    *   **GMM:** Uses 16-mixture Expectation-Maximization (EM).
5.  **Decision:** Maximum Likelihood estimation.

---

## 📂 Project Structure
*   **`BiometricDetector.m`**: Main entry point for live identification.
*   **`VoiceLoginApp.m`**: Secure Biometric Login interface.
*   **`compare_systems.m`**: Master benchmarking script.
*   **`GMM_System/`**: High-accuracy probabilistic models.
*   **`VQ_System/`**: Optimized clustering models.
*   **`DTW_System/`**: Segmental temporal matching models.
*   **`Shared/`**: Core utilities and data ingestion tools.

---

## 🚀 Getting Started

### 1. Data Ingestion
Download the [LibriSpeech dev-clean](https://www.openslr.org/12/) dataset and run:
```matlab
cd Shared/code
ingest_librispeech % Select the dev-clean folder
```

### 2. Benchmarking
Run the full comparative study from the root folder:
```matlab
compare_systems
```

### 3. Live Demo (Login Portal)
To launch the secure biometric login interface:
```matlab
VoiceLoginApp
```

## 📊 Final Results (20 Speakers)
| Model | EER (%) | Best For |
|-------|---------|----------|
| GMM   | **1.25%** | Highest Accuracy |
| VQ    | 2.43%   | Fast Identification |
| DTW   | 22.43%  | Temporal Verification |

## 📖 References
*   *Reynolds, D.A. (2002). "An Overview of Automatic Speaker Recognition Technology". Proc. IEEE ICASSP.*
