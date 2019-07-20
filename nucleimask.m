function binL=nucleimask(im)

% V1 make dapi mask
im=imgaussfilt(im,0.5);
bin=imbinarize(im,'adaptive','Sensitivity',0.6,'ForegroundPolarity','bright');
fill=imfill(bin,'holes');
clean=bwareaopen(fill,40);

se=strel('disk',1);
binL=imdilate(clean,se);





% V2 make dapi mask
% dapi=imread('dapi_original.tif'); 
% figure;
% imshow(dapi)
% im=imgaussfilt(im,0.5);
% bin=imbinarize(im,'adaptive','Sensitivity',0.8,'ForegroundPolarity','bright');
% figure;
% imshow(bin)
% 
% D=-bwdist(~bin);
% D(~bin)=-Inf;
% L=watershed(D);
% mask=label2rgb(L,'jet','w');
% 
% binL=zeros(size(L));
% binL(L>1)=1;
% binL=bin;

% figure;
% imshow(mask)

% overlay=imfuse(dapi,mask,'diff');
% figure;
% imshow(overlay)

