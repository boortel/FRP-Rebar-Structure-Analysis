%% Function GetZ: Get the z-distance using the crosssection between mask and the line from the center
function [z, xV, yV] = GetZDistance(mask, cM, k, q, scale, direction)
    
    % Compute the line
    valX = 1:size(mask, 2);
    valY = k*valX + q;
    
    % Get the line values within the image range
    valuesY = valY(valY >= 1 & valY <= size(mask, 2));
    valuesX = valX(valY >= 1 & valY <= size(mask, 2));

    if strcmp(direction, 'left')
        iterator = 1:size(valuesX, 2);
    else
        iterator = size(valuesX, 2):-1:1;
    end

    for i = iterator
        
        x = valuesX(i);
        y = valuesY(i);

        if  mask(floor(y), floor(x)) == 1
            xV = x;
            yV = y;
            break
        end
    end

    xVz = (xV - cM(1)) * scale;
    yVz = (yV - cM(2)) * scale;

    z = sqrt(xVz^2 + yVz^2);
end