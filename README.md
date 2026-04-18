# Voice Biometric Identification System
A MATLAB implementation of automatic speaker recognition based on the Reynolds (2002) pipeline.

## Overview
This project implements a **Text-Independent Speaker Identification System** as described in the paper:
> Reynolds, D.A. — "An Overview of Automatic Speaker Recognition Technology" (ICASSP 2002).

## Features
- **Feature Extraction:** 13-coefficient MFCC + Pitch (F0)
- **Modeling:** Vector Quantization (VQ) using the LBG Algorithm
- **Performance Evaluation:** FAR, FRR, and EER analysis
- **Comparison:** Performance benchmarking between VQ and Dynamic Time Warping (DTW)

## Setup Requirements
- MATLAB (R2021b or later recommended)
- **Audio Toolbox** (for `mfcc`, `pitch`, and `audioreader`)

## Project Structure
- `/code`: MATLAB scripts for processing and modeling
- `/data/train`: Enrollment audio files (5-10 per speaker)
- `/data/test`: Verification audio files (2-3 per speaker)
- `/results`: Generated DET curves and accuracy reports
