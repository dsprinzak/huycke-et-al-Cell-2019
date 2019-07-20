% gutanalysis
pixel2um=0.2635; %um per pixel

%% load images

[filename, pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif;*.lsm','All Image Files';...
          '*.*','All Files' },'mytitle',...
          'D:\My Documents\Dropbox (TAU Storage)\Tabin lab\gut analysis\MAX_controlish_red.tif');
cd(pathname)
infoimg=imfinfo(filename);
[filepath,name,ext] = fileparts(filename);

channels = questdlg('How many channels in the image?', ...
	'# of channels', ...
    '1','2','3','3');

% analysis of several slices in a z-stack (.tif files)
zedges=inputdlg('first slice, last slice (separate by comma)', ...
    'which slices to include?',[1 50]);
zedges=str2num(zedges{1});

first=(zedges(1)*3)-2;
last=(zedges(2)*3)-2;

extracted_data=[];
count=0;

% loop goes through each slice
for i=first:3:last; 
    count=count+1;
switch channels
    case '1'
        im1 = imread(filename,i);
        nchannels=1;
        imstructin.im1=im1;
    case '2'
        im1 = imread(filename,i);
        im2 = imread(filename,i+1);
        nchannels=2;
        imstructin.im1=im1;
        imstructin.im2=im2;
    case '3'
        im1 = imread(filename,i);
        im2 = imread(filename,i+1);
        im3 = imread(filename,i+2);
        nchannels=3;       
        imstructin.im1=im1;
        imstructin.im2=im2;
        imstructin.im3=im3;
        figure
        imall=cat(2,im1,im2,im3);
        imshow(imall,[])

%Decide which image is used for segmentation
%chooses image in middle of stack, dapi channel 2
if nchannels==3
    segim=imread(filename,mean(first,last)+1); % change to +2 for dapi channel 3
elseif nchannels==2
    segim=imread(filename,mean(first,last)+1);
else
    segim=imread(filename,mean(first,last));
end


if count==1;
choice = questdlg('What kind of gut image is it?', ...
	'image type', ...
    'full','zoom','full');
switch choice
    case 'full'
        zoom=0;
    case 'zoom'
        zoom=1;
end
else
end

%% segment gut

if count==1;
if zoom
    
%     % create eroded image to segment outer boundary
%     segimbin=imbinarize(segim,'adaptive','Sensitivity',0.9);
%     segimfill=imfill(segimbin,'holes');
%     se=strel('disk',6);
%     segimerode=imerode(segimfill,se);
%     segim2=immultiply(segimerode,segim);
    
%     figure, imshow(segimerode)
%     figure, imshow(segim2)
    
    [inner,outer]=segmentgut_zoom(segim,filename,pathname);
    
    edges=inner.inneredge+outer.outeredge;
    %figure; imshow(edges)
else
    figure, imshow(segim);
    [inner,outer]=segmentgut(segim,filename,pathname);

    ringim=outer.*(~inner);
    %figure; imshow(ringim)
end 
else
end

%% analyze profile
imstructin.pixel2um=pixel2um; %conversion from pixels to um
if zoom
    imstructin.im=segim;
    imstructin.outeredge=outer.outeredge;
    imstructin.inneredge=inner.inneredge;
    imstructin.innerpixlist=inner.innerpixlist;
    imstructin.outerpixlist=outer.outerpixlist;
    imstruct=extract_profile_zoom(imstructin);
else
    imstructin.im=segim;
    imstructin.inner=inner;
    imstructin.outer=outer;
    imstruct=extract_profile(imstructin);
end

%% extract nuclei mask

mask=nucleimask(segim);

overlay=imfuse(segim,mask,'diff');
figure;
imshow(overlay)
imstruct.mask=mask;

%% extracting the data

numrings=max(max(imstruct.Lrings));
if nchannels==1
    for i=1:numrings
        pixelind=find(imstruct.Lrings==i);
        imstruct.ringmeans1(i)=mean(imstruct.im1(pixelind));
        
        %apply mask
        imstruct.maskedrings=imstruct.Lrings.*imstruct.mask;
        pixelindmask=find(imstruct.maskedrings==i);
        imstruct.ringmeans1m(i)=mean(imstruct.im1(pixelindmask));
    end
elseif nchannels==2
    for i=1:numrings
        pixelind=find(imstruct.Lrings==i);
        imstruct.ringmeans1(i)=mean(imstruct.im1(pixelind));
        imstruct.ringmeans2(i)=mean(imstruct.im2(pixelind));
        
        %apply mask
        imstruct.maskedrings=imstruct.Lrings.*imstruct.mask;
        pixelindmask=find(imstruct.maskedrings==i);
        imstruct.ringmeans1m(i)=mean(imstruct.im1(pixelindmask));
        imstruct.ringmeans2m(i)=mean(imstruct.im2(pixelindmask));
    end
else
    for i=1:numrings
        pixelind=find(imstruct.Lrings==i);
        imstruct.ringmeans1(i)=mean(imstruct.im1(pixelind));
        imstruct.ringmeans2(i)=mean(imstruct.im2(pixelind));
        imstruct.ringmeans3(i)=mean(imstruct.im3(pixelind));
        
        %apply mask
        imstruct.maskedrings=imstruct.Lrings.*imstruct.mask;
        pixelindmask=find(imstruct.maskedrings==i);
        imstruct.ringmeans1m(i)=mean(imstruct.im1(pixelindmask));
        imstruct.ringmeans2m(i)=mean(imstruct.im2(pixelindmask));
        imstruct.ringmeans3m(i)=mean(imstruct.im3(pixelindmask));
    end
end
    
%% plot results

P1RGB(:,:,1)=imstruct.im;
P1RGB(:,:,2)=imstruct.im;
P1RGB(:,:,3)=imstruct.im;
imrings=P1RGB;
imrings(:,:,1)=double(imstruct.im).*double(~imstruct.Ledgerings);
imrings(:,:,2)=double(imstruct.im).*double(~imstruct.Ledgerings);
imrings(:,:,3)=double(imstruct.im).*double(~imstruct.Ledgerings)+255*double(imstruct.Ledgerings);

figure; imshow(imrings)

figure;
if nchannels==1
    plot(imstruct.radi,imstruct.ringmeans1,'*-')
    save(['imstruct_',filename,'.mat'],'imstruct')
    extracted_data=[imstruct.radi',imstruct.ringmeans1'];
    titles={'radial position','mean value'};
    xlswrite([filename,'.xls'],titles,1,'A1')
    xlswrite([filename,'.xls'],extracted_data,1,'A2')
elseif nchannels==2
    plot(imstruct.radi,imstruct.ringmeans1,'*-')
    hold on
    plot(imstruct.radi,imstruct.ringmeans2,'*-')
    save(['imstruct_',filename,'.mat'],'imstruct')
    extracted_data=[imstruct.radi',imstruct.ringmeans1',imstruct.ringmeans2'];
    titles={'radial position','mean value channel 1','mean value channel 2'};
    xlswrite([filename,'.xls'],titles,1,'A1')
    xlswrite([filename,'.xls'],extracted_data,1,'A2')
    legend('channel 1','channel 2')
else
    plot(imstruct.radi,imstruct.ringmeans1,'*-')
    hold on
    plot(imstruct.radi,imstruct.ringmeans2,'*-')
    plot(imstruct.radi,imstruct.ringmeans3,'*-')
    plot(imstruct.radi,imstruct.ringmeans1m,'*-')
    save(['imstruct_',filename,'.mat'],'imstruct')
    extracted_data{count}=[imstruct.radi',imstruct.ringmeans1',imstruct.ringmeans2',imstruct.ringmeans3',imstruct.ringmeans1m',imstruct.ringmeans2m',imstruct.ringmeans3m'];
    titles={'radial position','mean value channel 1','mean value channel 2','mean value channel 3','mean value channel 1 masked','mean value channel 2 masked','mean value channel 3 masked'};
    xlswrite([filename,'.xls'],titles,count,'A1')
    xlswrite([filename,'.xls'],extracted_data{count},count,'A2')
    legend('channel 1 (pSMAD)','channel 2 (DAPI)', 'channel 3 (SMA)','channel 1 w mask(pSmad)')
end
 
xlabel('mean radius [um]')
ylabel('mean fluorescence level [AU]')
end
end

%% average z slices

for m=1:size(extracted_data,2);
    cat(:,:,m)=extracted_data{1,m};
end
extracted_means=mean(cat,3);
extracted_stdvs=std(cat,0,3);
extracted_sterr=extracted_stdvs./sqrt(length(extracted_means));

radialpos=extracted_means(:,1);
fig=figure;
errorbar(radialpos,extracted_means(:,5),extracted_sterr(:,5),'*-')
hold on
errorbar(radialpos,extracted_means(:,3),extracted_sterr(:,3),'*-')
errorbar(radialpos,extracted_means(:,4),extracted_sterr(:,4),'*-')
legend('channel 1 w mask (pSmad)','channel 2 (DAPI)','channel 3 (SMA)')
xlabel('mean radius [um]')
ylabel('mean fluorescence level [AU]')

saveas(gcf,name,'png')
xlswrite([name,'_z mean','.xls'],titles,1,'A1')
xlswrite([name,'_z mean','.xls'],extracted_means,1,'A2')
xlswrite([name,'_z mean','.xls'],titles,2,'A1')
xlswrite([name,'_z mean','.xls'],extracted_sterr,2,'A2')


%%save data


