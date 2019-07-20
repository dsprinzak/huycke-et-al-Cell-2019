function outstruct=extract_profile(imstruct)


outstruct=imstruct;
inner=imstruct.inner;
outer=imstruct.outer;
numrings = 10; % number of concentric rings to measure
theta_step = 10; %angular resolution in degrees
sim=size(imstruct.im); %size of image

% figure; imshow(inner)
% figure; imshow(outer)

o_cent=regionprops(outer);
i_cent=regionprops(inner);
xcent=i_cent.Centroid(1);
ycent=i_cent.Centroid(2);

r=sqrt((o_cent.BoundingBox(3)/2)^2+(o_cent.BoundingBox(4)/2)^2); %diagonal of bounding box

xc=round(xcent);
yc=round(ycent);
x2=round(xcent);
y2=yc+r;


ringim=outer.*(~inner);
% figure; imshow(ringim)
numrays=360/theta_step;

for i=0: theta_step: 360-theta_step
    
    theta=(i/180)*pi;
    x2r=xc+r*sin(theta);
    y2r=yc+r*cos(theta);
    
    yvals=round(linspace(yc,y2r,round(r+1)));
    xvals=round(linspace(xc,x2r,round(r+1)));
    
    
    for j=1:length(xvals)
        if yvals(j)>length(outer);
            yvals(j)=length(outer);
        elseif yvals(j)<1
            yvals(j)=1
        end
        if xvals(j)>length(outer);
            xvals(j)=length(outer);
        elseif xvals(j)<1
            xvals(j)=1
        end
        outer(yvals(j),xvals(j))=0;
    end

end

ringim1=outer.*(~inner);
%figure; imshow(ringim1)

L=bwlabel(ringim1,4);
%figure; imshow(L)
RGB = label2rgb(L);
%figure, imshow(RGB)

% generate rays

rays=zeros(size(L));
rays(L==0)=1;
rays=rays.*ringim;
figure; imshow(rays)
Lrays=bwlabel(rays);
RGBrays = label2rgb(Lrays);
figure, imshow(RGBrays)

% find inner and outer points

ringedges=edge(ringim,'log');
figure; imshow(ringedges)
Lringedges=bwlabel(ringedges);
RGBedges = label2rgb(Lringedges);
figure, imshow(RGBedges)

outeredge=zeros(size(Lringedges));
outeredge(Lringedges==1)=1;
inneredge=zeros(size(outeredge));
inneredge(Lringedges==2)=1;

se = strel('disk',1);
douteredge=imdilate(outeredge,se); %dilate outer 
dinneredge=imdilate(inneredge,se); %dilate inner

endpoints=bwmorph(rays,'endpoints');
Lraystart=Lrays.*endpoints.*dinneredge;
Lraysend=Lrays.*endpoints.*douteredge;
% 
imRGB=zeros(size(rays));
imRGB(:,:,1)=rays;
imRGB(:,:,2)=Lraystart;
imRGB(:,:,3)=Lraysend;

figure; imshow(imRGB)

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

for i=numdisks:-1:1

% CODE FROM EXTRACT PROFILE ZOOM (ALTERNATIVE TO CONVHULL) - GIVES ERROR
%     K1=line2pix(xringsall(i,:),yringsall(i,:)); %gets the points for disk i 
%     K2=line2pix(xringsall(i-1,:),yringsall(i-1,:)); %gets the points for disk i 
%     fK2=flip(K2);
%     mask=poly2mask([K1(:,2);fK2(:,2)],[K1(:,1);fK2(:,1)],sim(1),sim(2));
% %     imshow(mask)
% %     pause
%     Lrings(mask==1)=i-1;
    

% old code with convex hull
    K=convhull(xringsall(i,:),yringsall(i,:)); %gets the points of a convex hull and they are organized in a counter clockwise direction!!!
    Kx=xringsall(i,K);
    Ky=yringsall(i,K);    
    mask=poly2mask(Ky,Kx,sim(1),sim(2));
    if i<numdisks
        ringmask=oldmask.*(~mask);
%         imshow(ringmask)
%         pause
        Lrings(ringmask==1)=i;
    end
    oldmask=mask;

    
    edgemask=edge(mask,'log');
    Ledgerings(edgemask==1)=1;
end


% RGBrings = label2rgb(Lrings);
% figure, imshow(RGBrings,'border','tight')
% figure, imshow(Ledgerings)
%figure, imshow(Lrings)

% Extracting data from each ring

% for i=1:numrings
%     pixelind=find(Lrings==i);
%     P1mean(i)=mean(imstruct.im(pixelind));
% end

%extracting the mean radius of each ring
s = regionprops(Lrings,'EquivDiameter');
radi=[s(:).EquivDiameter];

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
outstruct.imrings=imrings;
outstruct.radi=radi;
% outstruct.ringmeans=P1mean;
outstruct.Lrings=Lrings;
outstruct.Ledgerings=Ledgerings;
