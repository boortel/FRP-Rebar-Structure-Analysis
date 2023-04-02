%% Function GetMask: Automatic ROI segmentation
function [mask, maskA] = GetMask(img, mask, scale, mode)
    
    %% Get mask automaticaly or manualy
    if strcmp(mode, 'auto')
        % Get mask automatically

        % Opening-closing reconstruction
        se = strel('diamond', 20);
        
        Ie = imerode(img, se);
        Iobr = imreconstruct(Ie, img);
        
        Iobrd = imdilate(Iobr, se);
        Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
        Iobrcbr = imcomplement(Iobrcbr);
        
        thresh = multithresh(Iobrcbr, 4);
        trshI = imquantize(Iobrcbr, thresh);
        
        temp = (trshI) == 5;
        
        tempE = imerode(temp, strel('disk', 95));
        mask = imdilate(tempE, strel('disk', 80));
    else
        % Get mask manualy
        mask(mask ~= 1) = 0;
        mask = logical(mask);

        se = strel('disk', 2);
        
        Ie = imerode(mask, se);
        mask = imreconstruct(Ie, mask);
    end

    %% Get the mask area
    m = regionprops(mask, 'Area');
    maskA = m.Area * (scale^2);

end