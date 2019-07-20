function pixlist=line2pix(xi,yi)

% this function gets a list of points and returns a list of pixel coordinates for the
% lines connecting the points.

numpoints=length(xi);

cumr=0;
for i=1:(numpoints-1)

    x1=xi(i);
    x2=xi(i+1);
    y1=yi(i);
    y2=yi(i+1);
    r=round(sqrt((x2-x1)^2+(y2-y1)^2)); 
    yvals(cumr+1:(cumr+r+1))=round(linspace(y1,y2,(r+1)));
    xvals(cumr+1:(cumr+r+1))=round(linspace(x1,x2,(r+1)));
    cumr=cumr+r+1;
end

pixlist=[xvals',yvals'];
pixlist=unique(pixlist,'rows','stable');

