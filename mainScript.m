%% Clean up
clc
clear all;
close all;

%% Define the function parameters

% Paths of the sample and mask folders
dataFolder = 'foto';
maskFolder = 'mask';

% Density of filament and fibers [kg/m3], image scale [px/mm]
weights = [1300, 2600];
scale = 13E-3;
winSz = 7;

%% Load and process the images
fileList = dir(fullfile(dataFolder, '*.png'));
maskList = dir(fullfile(maskFolder, '*.png'));
flLength = size(fileList, 1);

% Plot the results
figure(1)

for i = 1:flLength

    % Get image name and path
    imPath = strcat(fileList(i).folder, '\', fileList(i).name);
    msPath = strcat(maskList(i).folder, '\', fileList(i).name);
    
    disp("Sample: " + fileList(i).name)

    % Load and grayscale the image
    img = im2double(imread(imPath));
    mask = im2gray(im2double(imread(msPath)));

    % Cut off the header
    img = img(1:end-90, :);
    mask = mask(1:end-90, :);
    imSize = size(img);
    
    % Get mask and its area
    [mask, maskA] = GetMask(img, mask, scale, 'auto');

    subplot(2, 2, i)
    imshow(img)
    hold on

    % Get centroid coordinates, excentricity and its angle
    [cM, cMW, szV, anV, imgRes] = GetCentroids(img, mask, weights, winSz, scale);
    
    % Get the moments
    [Ix, Iy, Dxy, IxE, IyE, DxyE, I1, I2, alpha, z1, z2, zE] = GetMoments(mask, maskA, cM, cMW, scale, anV);
    
    %% Plot the results
    
    % Weights
%     figure(3)
%     subplot(2, flLength/2, i)
%     imshow(imgRes, [])

    disp("   Shift vector: " + szV + " m, " + rad2deg(anV) + " °")
    disp("   Mask area:    " + maskA + " m2")
    disp("   Dxy:  " + Dxy + " Nm");
    disp("   Ix:   " + Ix + " Nm");
    disp("   Iy:   " + Iy + " Nm");
    disp("   I1:   " + I1 + " Nm");
    disp("   z1:   " + z1 + " m");
    disp("   I2:   " + I2 + " Nm");
    disp("   z2:   " + z2 + " m");
    disp("   alpha: " + alpha + " °");
    disp("   DxyE: " + DxyE + " Nm");
    disp("   IxE:  " + IxE + " Nm");
    disp("   IyE:  " + IyE + " Nm");
    disp("   zE:   " + zE + " m");
end
