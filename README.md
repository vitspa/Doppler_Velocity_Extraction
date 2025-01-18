Abstract from the relative project.

Stroke is an enormous global burden, six and a half-million people die from stroke annually.
Effectively monitoring blood hemodynamic parameters such as blood velocity and volume flow permits to help and cure people. 
This project aimed to calibrate a custom-made wearable system for measuring cerebral blood flow (CBF) using a photoplethysmography (PPG) sensor. 
The measurements were validated using Doppler ultrasound as a reference method. Five (N=5) subjects (age = 24±1.41 years) were selected for the project. 
The PPG and Doppler ultrasound probe were placed above the left and right common carotid arteries (CCA), respectively.
Measurements were taken simultaneously for 12 seconds each, with six consecutive measurements per subject and 2 time-synchronized ECG recordings. 
Subsequently, using an extraction algorithm the velocity envelope (TAMEAN) was extracted from the Doppler image to obtain the blood volume flow (ml/min). 
After synchronization, the PPG signal output expressed in volts was calibrated to the corresponding volume, and a calibration curve was created.
The extraction algorithm achieved remarkable results, with almost perfect correlation with the Doppler image reference, rTAMEAN=0.951 and rvolume=0.975 demonstrating its reliability. 
Challenges encountered during postprocessing and synchronization highlighted the need for careful refinement in the project framework. 
Despite successful signal processing and alignment techniques, calibration results were suboptimal due to synchronization difficulties and motion artifacts. 
Limitations included impractical measurement locations and susceptibility to movement artifacts. 
The calibration process did not yield the expected outcomes and the project aim was not achieved. 
All the linear regression models for each subject failed to accurately predict the volume flow based on the measured voltages. 
Future work could focus on refining calibration procedures, improving synchronization methods, and expanding studies to include larger cohorts. 
Although the wearable device was tested, the project’s goal was only partially achieved, underscoring the complexity of accurately measuring cerebral blood flow using PPG sensors.

                                                                         **ALGORITHM EXPLENATION**
Doppler Velocity Envelope and ECG Extraction
The process began with the Doppler images (434 x 636 pixels, RGB) being saved and exported in DICOM (Digital Imaging and Communications in Medicine) format (Fig. 2.3). The images were treated as a scalar function f (X,Y), where X ∈ x = [1, ..., 636] and Y ∈ y = [1, ..., 434]. Subsequently, using image processing techniques the key steps for acquiring the blood volume flow were as follows (the code is presented in A):

1. ROI Detection: Define the region of interest (ROI) of the image, that encompasses the yellow pixels containing the Doppler spectrum
(1 < x < 636, yup < y < ylo), where yup and ylo are respectively the upper and lower borders of the ROI, then remove pixels outside the ROI. For example, all pixels above yup=233 and below ylo=292 in Fig. 4.4 were removed. An analogue procedure was done to define the ROI that included the green pixels containing the ECG (1 < x < 636, 332 < y < 375).

2. Masking: Color thresholding functions (DopplerMask and ECGMask) are used to create 2 masks that highlight specific regions in the image associated with the Doppler and ECG signals, respectively. The functions take the RGB image as input and convert it to hue saturation value (HSV) color space using the ”rgb2hsv” function, then thresholds are defined for each channel of the HSV space. The output is a binary mask based on the defined thresholds for each HSV channel. Finally, the binary mask is applied to the RGB image to obtain the masked image where only the pixels that satisfy the color thresholds remain visible. In particular, the Doppler spectrum (yellow) is thresholded to consider only the pixels correspond to the TAMEAN curve (turquoise). The functions are available in A.1 and A.2.
   
3. Thresholding and Pixel Extraction: The masked images are iteratively processed to identify pixels corresponding to the TAMEAN and ECG waveform. This involves setting intensity thresholds (0.75 for TAMEAN and 0.50 for ECG) and extracting pixels above these thresholds, indicating the presence of signal components [57–59]. Three algorithms were developed for pixel extraction, all utilizing the same predefined thresholds and scanning the region of interest (ROI) from bottom to top. The primary distinction among these algorithms lies in their criteria for selecting pixels during extraction. To illustrate this concept using the TAMEAN curve as an example, consider a vertical line composed of three pixels (representing thickness) Fig. 3.4, the algorithms operate as follows: ”Upper Envelope” selected the last available pixel (pixel 3) in the ROI as the TAMEAN value, conversely, the ”Lower Envelope” algorithm identified the first pixel (pixel 1) in the ROI as the TAMEAN value, the ”Mean Velocity Envelope” algorithm selected the middle pixel (pixel 2) in the ROI as the TAMEAN value. Similar principles apply to the extraction of the ECG curve using these algorithms.
   
4. Conversion and Plotting: The extracted envelope data is converted into meaningful units (seconds for time and cm/s for velocity). This data is then plotted to visualize the velocity envelope in particular TAMEAN and ECG curve over time.
   
5. Volume Calculation: Using the TAMEAN curve and the vessel diameter, the code calculates the blood volume flow.
   
6. Output Display: Finally, the calculated blood volume flow and TAMEAN are displayed as output, providing quantitative insights into the hemodynamic properties captured by the Doppler ultrasound image.
