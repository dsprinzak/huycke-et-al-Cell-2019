function outstruct=extract_profile_zoom(imstruct)


outstruct=imstruct;
inneredge=imstruct.inneredge;
outeredge=imstruct.outeredge;
innerpixlist=imstruct.innerpixlist;
outerpixlist=imstruct.outerpixlist;
numrings=20; % number of concentric rings to measure
numrays = 10; %angular resolution in degrees
sim=size(imstruct.im); %size of image

% figure; imshow(inner)
% figure; imshow(outer)


edges=inneredge+outeredge;
% figure; imshow(edges)
linner=length(innerpixlist(:,1));
louter=length(outerpixlist(:,1));
Lrays=zeros(sim);

ind_inner=round(linspace(1,linner,numrays));
ind_outer=round(linspace(1,louter,numrays));

for i=1:numrays  
    x1=innerpixlist(ind_inner(i),1);
    y1=innerpixlist(ind_inner(i),2);
    x2=outerpixlist(ind_outer(i),1);
    y2=outerpixlist(ind_outer(i),2);
    
    raypix=line2pix([x1 x2], [y1 y2]);
    
    for j=1:length(raypix(:,1))
        Lrays(raypix(j,2),raypix(j,1))=i;
    end
end

% RGBrays = label2rgb(Lrays);
% figure, imshow(RGBrays)

% find inner and outer points

endpoints=bwmorph(Lrays,'endpoints');
Lraystart=Lrays.*endpoints.*inneredge;
Lraysend=Lrays.*endpoints.*outeredge;
% 
% imRGB=zeros(size(Lrays));
% imRGB(:,:,1)=Lrays;
% imRGB(:,:,2)=Lraystart;
% imRGB(:,:,3)=Lraysend;
% 
% figure; imshow(imRGB)

numdisks=numrings+1;

xringsall=zeros(numdisks,numrays);
yringsall=zeros(numdisks,numrays);

for i=1:numrays
    [xstart(i),ystart(i)]=find(Lraystart==i);
    [xend(i),yend(i)]=find(Lraysend==i);
    xringsall(:,i)=round(linspace(xstart(i),xend(i),numdisks));
    yringsall(:,i)=round(linspace(ystart(i),yend(i),numdisks));
end 

% figure
Lrings=zeros(sim);
Ledgerings=zeros(sim);


for i=numdisks:-1:2
    K1=line2pix(xringsall(i,:),yringsall(i,:)); %gets the points for disk i 
    K2=line2pix(xringsall(i-1,:),yringsall(i-1,:)); %gets the points for disk i 
    fK2=flip(K2);
    mask=poly2mask([K1(:,2);fK2(:,2)],[K1(:,1);fK2(:,1)],sim(1),sim(2));
%     imshow(mask)
%     pause
    Lrings(mask==1)=i-1;
    edgemask=edge(mask,'log');
    Ledgerings(edgemask==1)=1;
end


RGBrings = label2rgb(Lrings);
%figure, imshow(RGBrings,'border','tight')
% figure, imshow(Ledgerings)
%figure, imshow(Lrings)

% Extracting data from each ring

% for i=1:numrings
%     pixelind=find(Lrings==i);
%     P1mean(i)=mean(imstruct.im(pixelind));
% end

%extracting the mean radius of each ring

for i=1:(numdisks-1)
    x1 = xringsall(i,:);
    x2 = xringsall(i+1,:);
    y1 = yringsall(i,:);
    y2 = yringsall(i+1,:);
    r = sqrt((x2-x1).^2 + (y2-y1).^2);
    if i==1
        radi(i)=mean(r)/2;
    else
        radi(i)=radi(i-1)+mean(r);
    end
        
end

radi=radi.*imstruct.pixel2um;
% plotting rings over image

P1RGB(:,:,1)=imstruct.im;
P1RGB(:,:,2)=imstruct.im;
P1RGB(:,:,3)=imstruct.im;
imrings=P1RGB;
imrings(:,:,1)=double(imstruct.im).*double(~Ledgerings);
imrings(:,:,2)=double(imstruct.im).*double(~Ledgerings);
imrings(:,:,3)=double(imstruct.im).*double(~Ledgerings)+255*double(Ledgerings);

% figure; imshow(imrings)
% figure; imshow(P1RGB)


% showing the results
% 
% figure; plot(radi,P1mean,'*-')
% xlabel('mean radius [pixels]')
% ylabel('mean Patched level [AU]')

outstruct.radi=radi;
% outstruct.ringmeans=P1mean;
outstruct.Lrings=Lrings;
outstruct.Ledgerings=Ledgerings;
