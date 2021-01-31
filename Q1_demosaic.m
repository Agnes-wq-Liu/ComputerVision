%Agnes Liu 260713093
                        %a. read in RGB 


i = im2double(imread('cuba.jpg'));
figure,imshow(i);
%sample image like Bayer pattern sample light arriving at sensor
imR = i(:,:,1);
imG = i(:,:,2);
imB = i(:,:,3);
% figure, imshow(imB); 
[y,x] = size(imR);
%gives R, G, B images with same dimensions
rmask = zeros(y,x);
ry = 2:2:y;
rx = 1:2:x;
by = 12:y;
bx = 2:2:x;
rmask(ry,rx) = imR(ry,rx);
gmask = zeros(y,x);
gmask(ry,bx) = imG(ry,bx);
gmask(by,rx) = imG(by,rx);
bmask = zeros(y,x);
bmask(by,bx) = imB(by,bx);
% figure("Name","gmask"), imshow(gmask);

%recombine to get the RAW
raw = cat(3, rmask, gmask, bmask);
imwrite(raw,'1a_mergedMasks.png');

% %executed to show a smaller neighbourhood
sub = i(150:160, 1110:1120);
subr = rmask(150:160, 1110:1120, :);
subg = gmask(150:160, 1110:1120, :);
subb = bmask(150:160, 1110:1120, :);
raw_example = cat(3,subr,subg,subb);
% figure,imshow(raw_example)
% truesize([100,100]);


                            %b. demosaic


%first filter for gmask
g_filter = [0 1/4 0; 1/4 0 1/4; 0 1/4 0];
G = conv2(gmask,g_filter,"same");
G(ry,bx) = gmask(ry,bx);
%blue and red
rb_filter = [1/4 1/2 1/4; 0 0 0 ;1/4 1/2 1/4];
B = conv2(bmask,rb_filter, "same");
B(by,bx) = bmask(by,bx);
R = conv2(rmask,rb_filter, "same");
R(ry,rx) = rmask(ry,rx);
%merge to get 
demos = cat(3, R, G, B);
figure("Name","demosaic-ed"), imshow(demos);
imwrite(demos, "1b_demosaic-ed.png");


               % c. construct a RGB image with 2 shades of gray:
               
               
synth(1:10,1:5)=0.35;
synth(1:10,6:10)=0.75;
synth_im = cat(3,synth,synth,synth);
imwrite(synth_im,"1c_synthetic.png");
figure,imshow(synth_im)
truesize([100,100]);

imR = synth_im(:,:,1);
imG = synth_im(:,:,2);
imB = synth_im(:,:,3);
% figure, imshow(imB); 
[y,x] = size(imR);
%gives R, G, B images with same dimensions
rmask = zeros(y,x);
ry = 2:2:y;
rx = 1:2:x;
by = 1:2:y;
bx = 2:2:x;
rmask(ry,rx) = imR(ry,rx);
gmask = zeros(y,x);
gmask(ry,bx) = imG(ry,bx);
gmask(by,rx) = imG(by,rx);
bmask = zeros(y,x);
bmask(by,bx) = imB(by,bx);
%recombine to get the RAW
raw = cat(3, rmask, gmask, bmask);
figure("Name","Raw"),imshow(raw)
truesize([100,100]);

% linear interpolation
A = conv2(gmask,g_filter,"same");
A(ry,bx) = gmask(ry,bx);
%blue and red
B = conv2( bmask,rb_filter,"same");
B(by,bx) = bmask(by,bx);
C = conv2( rmask,rb_filter,"same");
C(ry,rx) = rmask(ry,rx);
s_demos = cat(3, C, A, B);
imwrite(s_demos,"synthetic_demosaic.png");
figure("Name","demos"), imshow(demos)
truesize([100,100]);
