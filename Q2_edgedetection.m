%Agnes Liu 260713093
                              % a. 

%Create 20-rectangular image
biggest(1:300,1:300) = 0.2;
for c=1:30
    height = rand()*150;
    width = rand()*150;
    i20t = rand();
    x = rand()*250;
    y = rand()*250;
    biggest(5+y:y+height,5+x:x+width) = i20t;
end
crop = biggest(1:250,1:250);
recImg = cat(3,crop,crop,crop);
% figure,imshow(crop);
% imwrite(crop,"2a_rectangula.png");
% commented so that it's not updated when run;


                            %b. 
%i. implement a laplacian of gaussian filter (with fspecial)
% can I directly use fspecial's laplacian of gaussian?
log1 = fspecial('log',20,3);
figure, plot(log1)
colorbar;

% if not, here's an implementation
h = fspecial('gaussian',20,3);
f_log = zeros(20,20);
sum_log = 0;

for i = 1:20
  for j = 1:20
    d = (i-(20+1)/2)^2 + (j-(20+1)/2)^2;
    f_log(i,j) = ((d-2*3^2)*h(i,j))/((3^4));
    sum_log = sum_log+f_log(i,j);
  end
end
log = f_log - sum_log/20^2;

%ii.show image of filter with colorbar
figure, plot(log)
colorbar;
% we can see the 2 images are identical


                                %c. 


%i.Filter my rectangular image with Laplacian-Gaussian
rect = im2double(imread("2a_rectangular.png"));
frect = imfilter(rect,log1,'conv');
fr = frect*100;%just for visualization
figure, imshow(fr);
imwrite(fr,"2c_filtered_rect.jpg");

%ii. find zero crossing & create a binary image
[m,n]=size(frect);
binary = zeros(m,n);
x = 2:n-1;
y = 2:m-1;
binary(y,x) = frect(y,x-1)*frect(y,x+1)<0 | frect(y-1,x)*frect(y+1,x)<0 | frect(y-1,x-1)*frect(y+1,x+1)<0;
figure,imshow(binary);
imwrite(binary,'2c_zerocrossing.jpg');
% with circshift
fr1 = circshift(frect,1);
bin(y,x) = fr1(y,x-1)*fr1(y,x+1)<0 | fr1(y-1,x)*fr1(y+1,x)<0 | frect(y-1,x-1)*frect(y+1,x+1)<0;
figure,imshow(bin);
imwrite(bin,'2c_circshifted_zerocrossing.jpg');


                                %d 

                                
% sample noise values ~G(0,std = 1/10 of image) 
sigma = std(rect)/10;
noise = sigma.*randn(m,n);
% add this noise to my image, then repeat
newimg = imadjust(noise+rect);
imwrite(newimg,"2d_noisy.jpg");
frect = imfilter(newimg,log1,'conv');
fr = imadjust(frect);
figure, imshow(fr);
imwrite(fr,"2d_filtered_noisy.jpg");

binary(y,x) = frect(y,x-1)*frect(y,x+1)<0 | frect(y-1,x)*frect(y+1,x)<0 | frect(y-1,x-1)*frect(y+1,x+1)<0;
figure,imshow(binary);
imwrite(binary,'2d_zerocrossing.jpg');

fr1 = circshift(frect,1);
bin(y,x) = fr1(y,x-1)*fr1(y,x+1)<0 | fr1(y-1,x)*fr1(y+1,x)<0 | frect(y-1,x-1)*frect(y+1,x+1)<0;
figure,imshow(bin);
imwrite(bin,'2d_circshifted_zerocrossing.jpg');


                            %e


%use a log with sigma=6, width = 40
new_log = fspecial('log',40,6);
frect = imfilter(newimg,new_log,'conv');
fr = imadjust(frect);
figure, imshow(fr);
imwrite(fr,"2e_filtered_noisy.jpg");

binary(y,x) = frect(y,x-1)*frect(y,x+1)<0 | frect(y-1,x)*frect(y+1,x)<0 | frect(y-1,x-1)*frect(y+1,x+1)<0;
figure,imshow(binary);
imwrite(binary,'2e_zerocrossing.jpg');
