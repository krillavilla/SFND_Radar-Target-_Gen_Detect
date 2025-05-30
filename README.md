# Radar Target Generation and Detection

This MATLAB project simulates an FMCW radar system to detect a moving target by generating, processing, and visualizing radar signals using FFT and CFAR techniques.

## ✅ Implementation Steps

### 1. FMCW Waveform Design
- **Bandwidth (B)** calculated from range resolution:  
  `B = c / (2 * range_res)`
- **Chirp Time (Tchirp)** ensures echoes from max range return:  
  `Tchirp = 5.5 * 2 * max_range / c`
- **Chirp Slope** calculated as:  
  `slope = B / Tchirp ≈ 2e13`

### 2. Signal Generation & Target Simulation
- Transmit signal `Tx` and delayed received signal `Rx` generated.
- Beat signal `Mix = Tx .* Rx` computed for FFT processing.

### 3. 1D FFT for Range Measurement
- Beat signal reshaped into `Nr × Nd` matrix.
- FFT performed along range bins (`Nr`).
- Half the spectrum retained, and a clear peak is visible at the target range of **~110 meters** within ±10 meters.

### 4. 2D FFT for Doppler Processing
- 2D FFT generates the Range Doppler Map (`RDM`).
- The map is log-scaled in dB and plotted with appropriate axis labels.

### 5. 2D CFAR Detection
- **Training Cells**: 10 (range), 8 (doppler)
- **Guard Cells**: 4 (range), 4 (doppler)
- **Offset**: 6 dB
- The algorithm:
  - Slides a CUT across the `RDM`.
  - Averages surrounding training cells (excluding guard cells) after converting dB to linear using `db2pow`.
  - Applies offset and compares the CUT against the threshold.
  - Marks detection with 1 or 0 based on comparison.
- Edge cells are excluded from processing and padded with 0s to maintain size.

### 📦 Submission Contents
- `Radar_Target_Generation_and_Detection.m`
- `README.md` (this file)
- `screenshots`


---
