%% Function GetCentroids: Compute centroids from the mask and weights
function [cM, cMW, szV, anV, imgRes] = GetCentroids(img, mask, weights, winSz, scale)
    
    %% Compute the normal and weighted center of the masks

    % Mask the image and get the binary tresholds
    imgM = mask.*img;

    thresh = multithresh(imgM, 3);
    
    % Treshold the filtered image
    imgT = imquantize(imgM, thresh);

    % Assign the weights in the local surrounding
    imSize = size(imgT);
    window = ones(winSz, winSz);
    overlp = floor(winSz/2);
    
    imgTP = padarray(imgT, [overlp, overlp], 'replicate');
    imgRes = zeros(imSize);
    
    % Loop through the padded image
    for i = (1 + overlp):imSize(1)
        for j = (1 + overlp):imSize(2)
    
            % Get the data under window
            temp = imgTP(i-overlp:i+overlp, j-overlp:j+overlp) .* window;
            
            % Assign the weight based on the local surrounding
            if imgTP(i, j) == 1
                imgRes(i-overlp, j-overlp) = 0;
            elseif imgTP(i, j) == max(max(temp))
                imgRes(i-overlp, j-overlp) = weights(1);
            elseif imgTP(i, j) == min(min(temp))
                imgRes(i-overlp, j-overlp) = weights(2);
            else
                %imgRes(i-overlp, j-overlp) = weights(2);
                imgRes(i-overlp, j-overlp) = 0;
            end
        end
    end

    % Get center of the mass from mask
    m = regionprops(mask, 'Centroid');
    cM = m.Centroid;
    
    % Get the weighted center of the mass from the trsh image
    m = regionprops(mask, imgRes, 'WeightedCentroid');
    cMW = m.WeightedCentroid;

    % Compute the shift vector size (excentricity) and its angle
    xV = (cMW(1) - cM(1)) * scale;
    yV = (cMW(2) - cM(2)) * scale;

    szV = sqrt(xV^2 + yV^2);
    anV = atan(yV/xV);

    % Plot centers and base axes
    plot(cM(1), cM(2), 'r.', 'MarkerSize', 20);
    hold on;

    plot(cMW(1), cMW(2), 'b.' , 'MarkerSize', 20);
    hold on;

    plot(1:size(mask, 1), ones(1, size(mask, 2))*cM(2), 'r--');
    hold on
    plot(ones(1, size(mask, 1))*cM(1), 1:size(mask, 2), 'r--');

end