# Multistatic Radar Project

This project focuses on the development of a multistatic radar system, undertaken as part of the MSc and BSc theses by Iosif Vardakis.

## Project Overview

The multistatic radar system is designed to process radar data and track targets using a combination of passive radar techniques. The project is organized into several folders, each serving a specific purpose.

### Folder Structure

1. **RangeDoppler**

    - **PR.m**: This script constitutes the basic passive radar code. It generates the Amplitude-Range-Doppler (ARD) matrices for a given dataset. The resulting matrices are stored in a specified file (e.g., `wf_malaxa_2.mat`).
    - **Input Parameters**:
        - Input sample rate of the dataset
        - Center frequency of the dataset
        - Frequency of the station (channelFreq)
        - Decimation factor (along with blocksize) to determine the Coherent Processing Interval (CPI)
        - Choice of adaptive filter

2. **bistatic_tracker**

    - **multitarget_target_tracker.m**: This tracker receives the ARD surfaces as input. It employs an initiation logic (M/N, e.g., 3/7) and tracks targets using a Kalman Filter. The output includes bistatic range and bistatic velocity information for the targets. This data is saved for use in the cartesian tracker.

3. **cartesian_tracker**

    - **fusion_center.m**: The fusion center combines the bistatic tracks created in the bistatic tracker to form a 3D cartesian tracker of the targets. The process involves the following steps:
        - **Initial Target Position**: The Spherical Intersection (SX) localization method is used to initiate an initial target position.
        - **Sequential Updates**: Each bistatic measurement sequentially updates the estimate using an Extended Kalman Filter (EKF).

## Usage

1. Clone this repository to your local machine.
2. Navigate to the relevant folder (e.g., `RangeDoppler`, `bistatic_tracker`, or `cartesian_tracker`).
3. Follow the instructions provided in the respective script files to process data and track targets.

Feel free to explore and adapt the code to suit your specific radar application! 🛰️📡🎯
