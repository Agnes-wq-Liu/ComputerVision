%Agnes Liu 260713093
% Read in the image, convert to grayscale, and detect edges.
% Creates an array edges where each row is    (x, y, cos theta, sin theta)   

im = imread('road.jpg');
figure("Name","original"), imshow(im)
truesize([300,300]);
im = imresize(rgb2gray(im), 0.5);

Iedges = edge(im,'canny');
%  imgradient computes the gradient magnitude and gradient direction
%  using the Sobel filter.  
[~,grad_dir]=imgradient(im);
%  imgradient defines the gradient direction as an angle in degrees
%  with a positive angle going (CCW) from positive x axis toward
%  negative y axis.   However, the (cos theta, sin theta) formulas from the lectures define theta
%  positive to mean from positive x axis to positive y axis.  For this
%  reason,  I will flip the grad_dir variable:
grad_dir = - grad_dir;

figure("Name","edges"),imshow(Iedges)
truesize([300,300]);
%Now find all the edge locations, and add their orientations (cos theta,sin theta). 
%  row, col is  y,x
[row, col] = find(Iedges);
% Each edge is a 4-tuple:   (x, y, cos theta, sin theta)   
edges = [col, row, zeros(length(row),1), zeros(length(row),1) ];
for k = 1:length(row)
     edges(k,3) = cos(grad_dir(row(k),col(k))/180.0*pi);
     edges(k,4) = sin(grad_dir(row(k),col(k))/180.0*pi);
end
%for each edge: vote for all vanishing pt pos consistent with the edge
%ie: pts lie along line containing the edge

%vertical: iterate y pos 
%horizontal: x pos
%because perpendicular: when get angle by cos, if angle is within x range
%then we iterate over all y, and generate line with angle perp to this
%first, initialize a matrix of image size
[y,x] = size(im);
vote = zeros(y,x);
for i = 1:length(edges)
    g_angle = acos(edges(i,3));%first, get angle
    ag = mod((g_angle+1/2*pi),pi);%angle <180
    k = abs(tan(ag));%slope of eq
    b = edges(i,2)-tan(ag)*edges(i,1);%b = y-kx
    if (g_angle<(1/4*pi)&&g_angle>(0.75*pi))%if angle in x
    %perpendicular: iterate over all y
        for ii = 1:y
            x1 = floor((ii-b)/k);
            if x1<=x && x1>=1
                vote(ii,x1) = vote(ii,x1)+1;
            end
        end
    else
        for jj = 1:x
           y1 = floor(k*jj+b);
           if y1<=y && y1>=1
               vote(y1,jj) = vote(y1,jj)+1;
           end
        end
    end
end
%now make my vote an image and visualize
ma = max(vote,[],"all");
mi = min(vote,[],"all");
thresh = 0.45*(ma-mi);
vote = vote-thresh;
figure("Name","voted"), imshow(vote)
truesize([300,300]);
