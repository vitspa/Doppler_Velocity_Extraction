clc
close all
%Image parameters

%% Mask to segment the TAMEAN in turqoise color
[BW,maskedRGBImage] = DopplerMask(RGB);
[BW1,maskedRGBImage_ECG] = ECGMask(RGB);

Original_image = RGB;

Size1 = size(RGB, 1);
Size2 = size(RGB, 2);
figure ('Color','w');
image(Original_image);
axis off;


%Doppler parameters
GrayStart = 39;        % Starting pixel of the Doppler in the image in the horizontal axis
GrayEnd =   567;          % End pixel of the Doppler in the image

VerticalPixelDoppler_start = 155;  %Starting pixel of the Doppler in the image in the vertical axis
VerticalPixelDoppler_end =  299;    % End pixel of the Doppler in the image set this at baseline height
Doppler_Flip = VerticalPixelDoppler_end - VerticalPixelDoppler_start;

%ECG parameters
VerticalPixelECG_start = 332;  %Starting pixel of the Doppler in the image in the vertical axis
VerticalPixelECG_end  =  390;  % End pixel of the Doppler in the image set this at baseline height
ECG_Flip = VerticalPixelECG_end-VerticalPixelECG_start;

%Thresholds
Gray_threshold1 =     50;% Amplitude threshold You can reduce thresholds to find hard to find green pixels.
Gray_threshold2 =     10;% ECG In reality they can be omitted 

DopplerEnvThreshold = 0.70;     % Threshold to find doppler envelope
ECGenvThreshold =     0.80;     % Threshold to find ECG envelope


%Scale conversion
y_conversion_factor = 100/ 134;   %  velocity/pixels 10 cm/s corresponds to 12 pixels

%Given diameter of the vessel in cm
diameter_cm = 0.59; % cm


%% ROI                        
Original_image_Doppler = Original_image(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:);
Original_image_ECG = Original_image(VerticalPixelECG_start:VerticalPixelECG_end,:,:);

figure;
subplot(2,1,1)
image(Original_image_Doppler);
xlabel('Pixel');
ylabel('Pixel');
title('Doppler Spectrum ROI')
set(gca,'Fontsize',30);
axis off;
subplot(2,1,2)
image(Original_image_ECG);
xlabel('Pixel');
ylabel('Pixel');
title('Doppler ECG ROI');
set(gca,'Fontsize',30);
axis off;

%Initialization 
GrayFoundArray = zeros(Size1, Size2);
avg_intensity = zeros(Size1, Size2);
A_double_format = double(maskedRGBImage); %double precision to make the calculations more accurate

up_env = zeros(Size1, Size2);
lo_env = zeros(Size1,Size2);
mean_env = zeros(Size1,Size2);

GrayFoundArrayECG = zeros(Size1, Size2);
avg_intensityECG = zeros(Size1, Size2);
A_double_formatECG = double(maskedRGBImage_ECG); %double precision to make the calculations more accurate

up_env_ECG = zeros(Size1, Size2);
lo_env_ECG = zeros(Size1,Size2);
mean_env_ECG = zeros(Size1,Size2);




%% Identifies and marks pixels in the image that have an average intensity above the specified threshold
for i1 = VerticalPixelDoppler_start:VerticalPixelDoppler_end
    for i2 = 1:Size2
       avg_intensity(i1, i2) = (A_double_format(i1, i2, 1) + A_double_format(i1, i2, 2) + A_double_format(i1, i2, 3)) / 3;
       if (avg_intensity(i1, i2) > Gray_threshold1)
           GrayFoundArray(i1, i2) = avg_intensity(i1, i2); % bright gray
       end       
    end
end


%%Same for the ECG
for i3 = VerticalPixelECG_start:VerticalPixelECG_end
    for i4 = 1:Size2
       avg_intensityECG(i3, i4) = (A_double_formatECG(i3, i4, 1) + A_double_formatECG(i3, i4, 2) + A_double_formatECG(i3, i4, 3)) / 3;
       if (avg_intensityECG(i3, i4) > Gray_threshold2)
           GrayFoundArrayECG(i3, i4) = avg_intensityECG(i3, i4); % bright gray
       end       
    end
end

% remove parts of the image that would not contain Doppler
GreenFoundArray1 = GrayFoundArray(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:);
GreenFoundArray2 = GrayFoundArrayECG(VerticalPixelECG_start:VerticalPixelECG_end,:);

 
%% Velocity envelope extraction
for i2 = GrayStart:GrayEnd
    for i1 = 1:Size1
        if avg_intensity(i1, i2) < DopplerEnvThreshold * max(avg_intensity(VerticalPixelDoppler_start:VerticalPixelDoppler_end, i2))
            avg_intensity(i1, i2) = 0;
        end
    end
    k = find(avg_intensity(VerticalPixelDoppler_start:VerticalPixelDoppler_end, i2) > 0);
    up_env(i2) = min(k);
    lo_env(i2) = max(k);
    mean_env(i2) = mean(k);

    
end


up_env = Doppler_Flip - up_env;
up_env = up_env(GrayStart:GrayEnd);

lo_env = Doppler_Flip - lo_env;
lo_env = lo_env(GrayStart:GrayEnd);

mean_env = Doppler_Flip - mean_env;
mean_env = mean_env(GrayStart:GrayEnd);

%% ECG envelope extraction
for i4 = GrayStart:GrayEnd
    for i3 = 1:Size1
        if avg_intensityECG(i3, i4) < ECGenvThreshold * max(avg_intensityECG(VerticalPixelECG_start:VerticalPixelECG_end, i4))
            avg_intensityECG(i3, i4) = 0;
        end
    end
    k1 = find(avg_intensityECG(VerticalPixelECG_start:VerticalPixelECG_end, i4) > 0);

    up_env_ECG(i4) = min(k1);
    lo_env_ECG(i4) = max(k1);
    mean_env_ECG(i4) = mean(k1);
end

up_env_ECG = ECG_Flip - up_env_ECG;
up_env_ECG = up_env_ECG(GrayStart:GrayEnd);

lo_env_ECG = ECG_Flip - lo_env_ECG;
lo_env_ECG = lo_env_ECG(GrayStart:GrayEnd);

mean_env_ECG = ECG_Flip - mean_env_ECG;
mean_env_ECG = mean_env_ECG(GrayStart:GrayEnd);



%%

% Create a figure with a white background
fig = figure('Color', 'w');

% Plot your signal
plot(up_env, 'c', 'LineWidth', 2.5);
ylim([-100, 100]);
axis off;

% Set the figure's background to be transparent
set(gca, 'color', 'none');

% Save the figure as a PNG with transparent background
exportgraphics(gca, 'signal_ecg_pres.png', 'ContentType', 'vector', 'BackgroundColor', 'none');


% Convert pixels to seconds for the x-axis
x_time_vector = linspace(0, 12, GrayEnd - GrayStart + 1); % linspace(a,b,n) creates a row vector of n evenly spaced points between a and b, inclusive. In your case, GrayEnd - GrayStart + 1 determines the number of points you want between -12 and 0, inclusive of both endpoints.

% Convert pixels to cm/s for the y-axis
y_up_env_cm_per_sec = up_env * y_conversion_factor;

% Plot the converted data with the appropriate axis labels
figure;

subplot(4,1,1); 
image(GreenFoundArray1); 
title('Grey Scale Doppler ROI');
ylabel('Pixel');
xlabel('Pixel');
set(gca, 'FontSize', 20);

subplot(4,1,2); 
image(GreenFoundArray2); 
title('Grey Scale ECG ROI');
ylabel('Pixel');
xlabel('Pixel');
set(gca, 'FontSize', 20);

subplot(4,1,3); 
plot(x_time_vector, y_up_env_cm_per_sec, 'r','LineWidth',2.5); 
ylabel('Velocity [cm/s]');
%ylim([0,200])
xlabel('Time [s]');
title('Velocity Profile')
set(gca, 'FontSize', 20);

subplot(4,1,4); 
plot(x_time_vector, up_env_ECG, 'g','LineWidth',2.5); 
ylabel('Pixel');
xlabel('Time [s]');
title('ECG')
set(gca, 'FontSize', 20);

% Plotting the Doppler envelopes on the ECHO image
figure(1);
imshow(Original_image);
hold on; 
plot(GrayStart:GrayEnd, VerticalPixelDoppler_end - 1 - up_env, 'r', 'DisplayName', 'TAMEAN','LineWidth', 3); 
%plot(GrayStart:GrayEnd, VerticalPixelDoppler_end - 1 - lo_env, 'b', 'DisplayName', 'Lower Envelope','LineWidth', 3); 
%plot(GrayStart:GrayEnd, VerticalPixelDoppler_end - 1 - mean_env, 'k', 'DisplayName', 'Mean Velocity Envelope','LineWidth', 3); 
plot(GrayStart:GrayEnd, VerticalPixelECG_end - 1 - up_env_ECG, 'g', 'DisplayName', 'ECG','LineWidth', 3); 
%plot(GrayStart:GrayEnd, VerticalPixelECG_end - 1 - lo_env_ECG, 'b', 'DisplayName', 'Lower Envelope','LineWidth', 3); 
%plot(GrayStart:GrayEnd, VerticalPixelECG_end - 1 - mean_env_ECG, 'y', 'DisplayName', 'Mean Envelope','LineWidth', 2); 
legend('Location', 'northeast'); 
set(gca, 'FontSize', 20);
hold off;


%% VELOCITY
% Plot the converted data with the appropriate axis labels

TAMEAN = mean(y_up_env_cm_per_sec);
TAMEAN_values = ones(size(x_time_vector)) * TAMEAN; 

figure;
plot(x_time_vector, y_up_env_cm_per_sec, 'r','LineWidth',2.5); 
hold on;
% Create a vector of 26s matching the size of x_time_vector
plot(x_time_vector, TAMEAN_values, 'b--','LineWidth',2.5);

ylabel('Velocity [cm/s]');
%ylim([0, 200]);
xlabel('Time [s]');
set(gca, 'FontSize', 20);

title('Blood Velocity')
legend('Velocity','TAMEAN', 'Location', 'northeast'); % Add legend to differentiate the two plots

% Annotate the plot with mean volume and TAMEAN values
hold on;
text(4, 70, ...
    ['TAMEAN: ', num2str(TAMEAN), ' cm/s'], ...
    'FontSize', 20, 'Color', 'b', 'VerticalAlignment', 'top');
hold off;

%%  BLOOD VOLUME FLOW


% Calculate the cross-sectional area in square cm
cross_sectional_area_cm2 = pi/4 * (diameter_cm)^2;

% Assuming up_env represents TAMAX (time-averaged peak velocity)
% Define the maximum velocity envelope (TAMAX)
 % Replace with your actual maximum velocity envelope data

 TAMEAN = mean(y_up_env_cm_per_sec);

 
 % Calculate the blood volume flow using TAMEAN
volume_flow_TAMEAN_cm3_per_s = cross_sectional_area_cm2 * TAMEAN; 


% Calculate the blood volume flow in milliliters per second
volume_flow_TAMEAN_ml_per_s = volume_flow_TAMEAN_cm3_per_s ; % Convert cm^3 to ml 1cm3 = 1 ml


% Convert the blood volume flow to milliliters per minute
volume_flow_TAMEAN_ml_per_min = volume_flow_TAMEAN_ml_per_s  * 60; % Convert seconds to minutes

disp(['Volume (TAMEAN): ', num2str(volume_flow_TAMEAN_ml_per_min), ' ml/min']);


Volume_curve = y_up_env_cm_per_sec * cross_sectional_area_cm2 * 60; %the curve has the same trend of the velocity 



disp(['TAMEAN: ', num2str(TAMEAN), 'cm/s ']);

VolFlow_values = ones(size(x_time_vector)) * volume_flow_TAMEAN_ml_per_min; 

figure;
%subplot(2,1,2)
plot(x_time_vector,Volume_curve,'r','LineWidth',2.5);
hold on;
% Create a vector of  matching the size of x_time_vector
plot(x_time_vector, VolFlow_values, 'b--','LineWidth',2.5);
xlabel('Time [s]');
ylabel('Volume [ml/min]');
set(gca, 'FontSize', 30);
legend('Volume Curve','Volume Flow', 'Location', 'northeast'); % Add legend to differentiate the two plots
title('Blood Volume');

text(4, 1100, ...
    ['Volume Flow: ', num2str(volume_flow_TAMEAN_ml_per_min), ' ml/min'], ...
    'FontSize', 30, 'Color', 'blue', 'VerticalAlignment', 'bottom');

hold off;
subplot(2,1,1)


plot(x_time_vector, y_up_env_cm_per_sec, 'r','LineWidth',2.5); 
hold on;
% Create a vector of 26s matching the size of x_time_vector
plot(x_time_vector, TAMEAN_values, 'b--','LineWidth',2.5);

ylabel('Velocity [cm/s]');
%ylim([0, 200]);
xlabel('Time [s]');
set(gca, 'FontSize', 30);

title('Blood Velocity')
legend('Velocity','TAMEAN', 'Location', 'northeast'); % Add legend to differentiate the two plots

% Annotate the plot with mean volume and TAMEAN values
hold on;
text(1.5, 75, ...
    ['TAMEAN: ', num2str(TAMEAN), ' cm/s'], ...
    'FontSize', 30, 'Color', 'b', 'VerticalAlignment', 'top');
hold off;



