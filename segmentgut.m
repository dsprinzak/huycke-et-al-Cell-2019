function [inner,outer]=segmentgut(im,imname,pathname);

choice = questdlg('How would you like to segment?', ...
	'segmentation type', ...
    'auto','manual','load','load');
% Handle response
% [pathname,'inner_',imname]
switch choice
    case 'auto'
        P1=im;
        P2 = imgaussfilt(P1,2); % gaussian blur
        P3 = imbinarize(P2,'adaptive','Sensitivity',0.65); % make binary image
        P4 = bwareafilt(P3,1); % remove background noise
        
        se = strel('disk',8); % structuring element
        P5 = imclose(P4,se); % dilate/erode with structuring element
        
        P7 = bwareaopen(~P5, 3000); % remove all small "objects"
        % figure
        % imshow(~P7)
        
        % finding and plotting inner and outer boundaries
        [B] = bwboundaries(~P7);
        for k = 1:length(B)
            boundary = B{k};
            dist(k) = length(boundary);
        end
        [M, I_min]=min(dist);
        [M, I_max]=max(dist);
        xinner = B{I_min}(:,2);
        yinner = B{I_min}(:,1);
        xouter = B{I_max}(:,2);
        youter = B{I_max}(:,1);
        
%         figure
%         imshow(P1)
%         hold on
%         plot(xinner, yinner, 'r', 'LineWidth', 2) % plot inner boundary
%         plot(xouter, youter, 'r', 'LineWidth', 2) % plot outer boundary
        
        % make and save inner and outer objects
        inner = roipoly(P1,xinner,yinner);
%         figure
%         imshow(inner)
        
        outer = roipoly(P1,xouter,youter);
%         figure
%         imshow(outer)
        imwrite(inner,[pathname,'inner_',imname])
        imwrite(outer,[pathname,'outer_',imname])
    case 'manual'
        msgbox('define inner boundary');
        inner = roipoly;
        msgbox('define outer boundary');
        outer = roipoly;       
        imwrite(inner,[pathname,'inner_',imname],'tif')
        imwrite(outer,[pathname,'outer_',imname],'tif')
    case 'load'
        inner=imread([pathname,'inner_',imname],'tif');
        outer=imread([pathname,'outer_',imname],'tif');
end
