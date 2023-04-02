%% Function GetMoments: Compute all moments
function [Ix, Iy, Dxy, IxE, IyE, DxyE, I1, I2, alpha, z1, z2, zE] = GetMoments(mask, maskA, cM, cMW, scale, anV)
    
    X = 1:size(mask, 2);

    % Set the parameters to compute the moments
    se = strel('disk', 1);
    imgMaskI = mask;
    
    %% Compute the Ix, Iy and Dxy
    Dxy = 0;
    Ix = 0;
    Iy = 0;
    
    while(~isempty(nonzeros(imgMaskI)))
        
        % Erode the mask and compute the difference image
        imgMaskIEr = imerode(imgMaskI, se);
        imgDiff = imgMaskI - imgMaskIEr;
    
        % Get the xy coordinates of the non-zero points and recompute them
        [y, x] = find(imgDiff);
        x = (cM(1) - x + 1) * (scale^2);
        y = (cM(2) - size(imgDiff, 1) + y + 1) * (scale^2);
    
        % Compute the moments Dyz, Iy and Iz
        Dxy = Dxy + sum(y.*x);
        Iy = Iy + sum(x.^2);
        Ix = Ix + sum(y.^2);
    
        % Assign the eroded image to the mask
        imgMaskI = imgMaskIEr;
    end
    
    %% Compute the main moments
    I1 = 0.5 * (Ix + Iy) + 0.5 * sqrt((Ix - Iy)^2 + 4 * Dxy^2);
    I2 = 0.5 * (Ix + Iy) - 0.5 * sqrt((Ix - Iy)^2 + 4 * Dxy^2);

    % Compute the rotation of the main moments
    alphaT = (I1 - Ix)/Dxy;
    alpha = atand(alphaT);

    %% Compute the moments rotated to anV (excentricity angle)
    IxE = Ix*cosd(anV)^2 + Iy*sind(anV)^2 + Dxy*sind(2*anV);
    IyE = Ix*sind(anV)^2 + Iy*cosd(anV)^2 - Dxy*sind(2*anV);
    DxyE = 0.5*(Iy - Ix)*sind(2*anV) + Dxy*cosd(2*anV);

    %% Compute z
    
    % Horizontal direction - z1
    k1 = alphaT;
    q1 = cM(2) - k1*cM(1);
    [z1, xV1, yV1] = GetZDistance(mask, cM, k1, q1, scale, 'left');

    plot(xV1, yV1, 'g.' , 'MarkerSize', 20);
    hold on;
    text(xV1, yV1, 'z1')
    hold on

    Y1 = k1*X + q1;
    plot(X, Y1, 'g')
    hold on
    
    % Horizontal direction - z2
    k2 = -1/k1;
    q2 = cM(2) - k2*cM(1);
    [z2, xV2, yV2] = GetZDistance(mask, cM, k2, q2, scale, 'right');

    plot(xV2, yV2, 'g.' , 'MarkerSize', 20);
    hold on;
    text(xV2, yV2, 'z2')
    hold on

    Y2 = k2*X + q2;
    plot(X, Y2, 'g')
    hold on
    
    % Excentricity vector direction - zE
    kE = tan(anV);
    qE = cM(2) - kE*cM(1);
    [zE, xVE, yVE] = GetZDistance(mask, cM, kE, qE, scale, 'right');

    plot(xVE, yVE, 'b.' , 'MarkerSize', 20);
    hold on
    text(xVE, yVE, 'E')
    hold on

    YE = kE*X + qE;
    plot(X, YE, 'b')
    hold on
    
    % Rotate the points
    rot = [cos(alpha) -sin(alpha); sin(alpha) cos(alpha)];

    cMWR = scale*rot*(cMW - cM)';
    disp("   E1:   " + cMWR(1) + " m");
    disp("   E2:   " + cMWR(2) + " m");

    ER = scale*rot*[xVE - cM(1); yVE - cM(2)];
    disp("   C:   " + ER(2) + " m");
    disp("   D:   " + ER(1) + " m");
    
%     % Calculate the paralel lines
%     i1sq = I1/maskA;
%     i2sq = I2/maskA;
%     
%     % Opacny smer jako excentricita!!
%     n1 = (-i2sq/cMWR(1))*scale;
%     n2 = (-i1sq/cMWR(2))*scale;
% 
%     pn1 = rot*[cM(1) + n1; cM(2)];
%     pn2 = rot*[cM(1); cM(2) + n2];
% 
%     plot(pn1(1), pn1(2), 'm.' , 'MarkerSize', 20);
%     hold on
%     plot(pn2(1), pn2(2), 'm.' , 'MarkerSize', 20);
%     hold on
end