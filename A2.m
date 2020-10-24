%first generate the synthetic image
%I tried a larger size just to see how imresize affects resolution...
%have the read image resized
sizeX = 480;
sizeY = 360;
imMat = zeros(sizeY,sizeX);
imMat(1:200,1:480) = 0.1;
imMat(170:200,440:470)=0.8;
imMat(140:200,380:430)=0.7;
imMat(170:200,40:70)=0.7;
for x = 1:sizeX
    for y = 1:sizeY
        if (x-60)^2+(y-60)^2<=40^2
            imMat(y,x) = 1;
        end
        if ((x-100)/2)^2 +((y-300)/1)^2 <=30^2
            imMat(y,x) = 0.5;
        end
        if ((x-300)/2)^2 +((y-320)/1)^2 <=30^2
            imMat(y,x) = 0.5;
        end
        if ((x-150)/2)^2 +((y-320)/0.5)^2 <=30^2
            imMat(y,x) = 0.6;
        end
        if ((x-350)/2)^2 +((y-290)/0.5)^2 <=30^2
            imMat(y,x) = 0.6;
        end
        if ((x-450)/1)^2 +((y-320)/0.5)^2 <=30^2
            imMat(y,x) = 0.7;
        end
        if ((x-460)/0.4)^2 +((y-270)/0.3)^2 <=30^2
            imMat(y,x) = 0.5;
        end
        if ((x-30)/0.4)^2 +((y-320)/0.3)^2 <=30^2
            imMat(y,x) = 0.6;
        end
    end
end
synth = cat(3, imMat, imMat, imMat);
figure, imshow(synth)
title('Synthetic image');
% save to another name
imwrite(synth, "synthetic_image.jpg");                    


                        % Q1: Gaussian Scale Space
%scale from sigma0 to 16sigma0; 17 discrete slices
%sigma0 >=1
%same size as original image, don't make pyramid

%read in
% im = rgb2gray(im2double(imread('persistenceofmemory1931.jpg')));
im = rgb2gray(im2double(imread('synthetic_image.jpg')));
figure, imshow(im)
title("synthetic");
%subplot to create 4*4 slices 2~17
%use for loop
for i = 1:16
    sig = getSig(i);
    gauss = fspecial('gaussian',360,sig);
    newim = imfilter(im,gauss);
    subplot(4,4,i)
%     plot(gauss)
    imshow(newim) %plotting gaussian filter
    title(sprintf("Gaussian %i: Sigma value %f",i+1,sig));
end 


                    % Q2: Harris-Stevens operator
                    
% neighbour window sigma = 2*sig
% create M
% create loop for gaussian scale space
im = rgb2gray(im2double(imread('persistenceofmemory1931.jpg')));
% im = rgb2gray(im2double(imread('synthetic_image.jpg')));
for i = 1:16
    sig = getSig(i);
    gauss = fspecial('gaussian',360,sig);
    newim = imfilter(im,gauss);
    newM = generateM(newim);
    hso = harrisSteve(2*sig,newM);
    subplot(4,4,i)
    imagesc(hso)
    colorbar
%     imshow(newim) %plotting gaussian filter
    title(sprintf("H-S Operator %i: Sigma=%f",i+1,sig*2));
    
end



                    %Q3: Difference of Gaussians
                   
% difference of Gaussian scale space layers
% subplot and discuss zero-crossing vary across scale

im = rgb2gray(im2double(imread('persistenceofmemory1931.jpg')));
% im = rgb2gray(im2double(imread('synthetic_image.jpg')));

for i = 1:16
    sig = getSig(i);
    gauss = fspecial('gaussian',360,sig);
    lowerG = fspecial('gaussian',360,getSig(i-1));
    DOG = gauss-lowerG;
    newim = conv2(im,DOG,"same");
    newim = newim.*100;
    subplot(4,4,i)
%     plot(gauss)
    imshow(newim) %plotting gaussian filter
    title(sprintf("DOG %i:",i+1));
end 


                            %Q4: local extrema
                                                        
% brute force search DOG
% im = rgb2gray(im2double(imread('persistenceofmemory1931.jpg')));
im = rgb2gray(im2double(imread('synthetic_image.jpg')));
% make the space 3D
[y,x] = size(im);
dogSpace = zeros(y,x,17);
dogSpace(:,:,1) = im;
for i = 2:17
    sig = getSig(i);
    gauss = fspecial('gaussian',360,sig);
    lowerG = fspecial('gaussian',360,getSig(i-1));
    DOG = gauss-lowerG;
    newim = conv2(im,DOG,"same");
    dogSpace(:,:,i)=newim;
end 
% examine 3*3*3 neighbourhoods: check if the center is extrema
for i=2:16
    sig = floor(getSig(i));
    %we compute the x and y of interest for each layer (2*sig away)
    x1 = 2*sig:(x-2*sig);
    y1 = 2*sig:(y-2*sig);
    %locate the center and make comparison
    
end


        
                            %helper functions
                            
function sig = getSig(i)
    k = floor(i/4);
    m=mod(i,4);
    if mod(i,4)==0
        m=4;
        k = floor(i/4)-1; 
    end
    sig = 2^(k+m/4);
end

function newM = generateM(i)
    [sy,sx] = size(i);
    x = 1:sx;
    y = 1:sy;
    [Gy,Gx] = imgradientxy(i(y,x));
    M = [Gx.*Gx Gx.*Gy; Gx.*Gy Gy.*Gy];
    % I should interpolate the values
    [y,x] = size(M);
    newM = zeros([y,x]);
    y1 = 1:2:y-1;
    x1 = 1:2:x-1;
    y2 = 2:2:y;
    x2 = 2:2:x;
    newM(y1,x1) = M(1:y/2,1:x/2);
    newM(y1,x2) = M(1:y/2,x/2+1:x);
    newM(y2,x1) = M(y/2+1:y,1:x/2);
    newM(y2,x2) = M(y/2+1:y,x/2+1:x);
end

function hso = harrisSteve(sig,newM)
% smooth M with a gaussian of sigma = 2*sig
% then create harris stevens
    OuterGauss = fspecial('gaussian',floor(sig),sig);
    secoM = conv2(newM,OuterGauss);
    [smy,smx] = size(secoM);
    hs = zeros(smy,smx);
    hy = 1:2:smy-1; 
    hx = 1:2:smx-1;
    % we compute HS based on (hy,hx) pairs since they're M_11s
    hs(hy,hx) = secoM(hy,hx).*secoM(hy+1,hx+1)-secoM(hy,hx+1).*secoM(hy+1,hx)-0.1*(secoM(hy,hx)+secoM(hy+1,hx+1)).^2;
    newhs = hs(hy,hx);
    hso = newhs.*100;
end
    