function [inner,outer]=segmentgut_zoom(im,imname,pathname);

choice = questdlg('How would you like to segment?', ...
	'segmentation type', ...
    'manual','load','load');
% Handle response
% [pathname,'inner_',imname]
switch choice
    case 'manual'
        
        msgbox('define inner boundary (double click on last point)');
        [innerpoly,innerx,innery] = roipoly(im); %draw inner boundary on dapi image
        inner_pixlist=line2pix(innerx(1:(end-1)),innery(1:end-1));
        inneredge=zeros(size(im));
        for i=1:length(inner_pixlist(:,1))
            inneredge(inner_pixlist(i,2),inner_pixlist(i,1))=1;
        end
%         figure, imshow(inneredge,[])
        
        msgbox('define outer boundary (double click on last point)');
        [outerpoly,outerx,outery] = roipoly(im);
%         [outerpoly,outerx,outery] = roipoly(im2); %draw outer boundary on eroded image    
        outer_pixlist=line2pix(outerx(1:(end-1)),outery(1:end-1));
        outeredge=zeros(size(im));
        for i=1:length(outer_pixlist(:,1))
            outeredge(outer_pixlist(i,2),outer_pixlist(i,1))=1;
        end
        
        inner.inneredge=inneredge;
        inner.innerpixlist=inner_pixlist;
        outer.outeredge=outeredge;
        outer.outerpixlist=outer_pixlist;
        save([pathname,'inner_',imname(1:(end-4)),'.mat'],'inner')
        save([pathname,'outer_',imname(1:(end-4)),'.mat'],'outer')
    case 'load'
        load([pathname,'inner_',imname(1:(end-4)),'.mat']);
        load([pathname,'outer_',imname(1:(end-4)),'.mat']);
end
