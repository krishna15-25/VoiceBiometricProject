# Voice Biometric Identification System 🎙️
An automated speaker recognition platform implemented in MATLAB, based on the **Reynolds (2002)** processing pipeline.

## 📌 Overview
This project identifies a speaker's identity by analyzing their unique vocal characteristics. It compares two fundamentally different approaches to biometric recognition:
1.  **Vector Quantization (VQ):** A statistical AI approach that learns a speaker's "average" voiceprint.
2.  **Dynamic Time Warping (DTW):** A template-matching algorithm that aligns the timing of speech patterns.

---

## ⚙️ How It Works (The Pipeline)
The system follows a professional 5-stage biometric pipeline:

1.  **Audio Input:** Standardized 16kHz Mono recordings.
2.  **Pre-processing:** A **Pre-emphasis filter** boosts high frequencies to emphasize the vocal tract characteristics.
3.  **Feature Extraction:** Converts audio into **Mel-Frequency Cepstral Coefficients (MFCCs)**. This removes "what" was said and keeps "who" said it.
4.  **Modeling (The AI):**
    *   **VQ:** Uses the **LBG Algorithm** to cluster MFCCs into a 16-point "codebook."
    *   **DTW:** Uses temporal alignment to match the test sequence against reference templates.
5.  **Decision:** Calculates the **Distortion (Euclidean Distance)**. The speaker with the lowest distortion is identified as the match.

---

## 📂 Project Structure
*   **`VQ_System/`**: Contains the probabilistic clustering models.
*   **`DTW_System/`**: Contains the temporal template-matching models.
*   **`Shared/`**: Common tools for recording, distance math, and data generation.
*   **`data/`**: Organized into `train/` (Enrollment) and `test/` (Verification) folders.

---

## 🚀 Getting Started

### Prerequisites
*   MATLAB (R2021b or later)
*   **Audio Toolbox** (Required for MFCC and Pitch extraction)

### 1. Data Collection
Use the built-in recording tool to gather voice samples:
```matlab
cd Shared/code
record_voice    % Follow the prompts to record 5 samples per speaker
```

### 2. Run the Comparison
To train both systems and see a head-to-head performance report, run the master script from the root folder:
```matlab
compare_systems
```

### 3. Performance Metrics
The system automatically generates a **DET Curve** and calculates:
*   **FAR:** False Acceptance Rate (Security risk)
*   **FRR:** False Rejection Rate (Usability cost)
*   **EER:** Equal Error Rate (The "Gold Standard" for biometric accuracy)

---

## 📊 Visualizing Results
You can visualize the "Voiceprint" (Spectrogram + MFCC Heatmap) of any audio file:
```matlab
cd Shared/code
visualize_voiceprint('../../data/train/speaker1/trial1.wav')
```

## 📖 References
*   *Reynolds, D.A. (2002). "An Overview of Automatic Speaker Recognition Technology". Proc. IEEE ICASSP.*
*   *Linde, Y., Buzo, A., & Gray, R. (1980). "An Algorithm for Vector Quantizer Design".*
