%1. calling detectSURFFeatures and extractFeatures
[im1,f1,vf1] =readandget('Q21.jpg');
[im2,f2,vf2] =readandget('Q22.jpg');


%2.
indexPair = matchFeatures(f1,f2);
mf1 = vf1(indexPair(:,1));
mf2 = vf2(indexPair(:,2));
[f,inliers] = estimateFundamentalMatrix(mf1.Location,mf2.Location,'Method','RANSAC','NumTrials',20);
index = zeros(14,1);
for i=1:14
    j = randi(size(inliers,1));
    index(i) = j;
end
figure,imshow(im1)
hold on;
eset1 = getepi(im1,f,mf1.Location,mf2.Location,index);
e1 = linsolve(eset1(:,1:2),-eset1(:,3));
title(sprintf('epipole in image 1 is (x,y) =(%s,%s)',e1(2,1),e1(1,1)));
hold off;

figure,imshow(im2)
hold on;
eset2 = getepi(im2,f,mf2.Location,mf1.Location,index);
e2 = linsolve(eset2(:,1:2),-eset2(:,3));
title(sprintf('epipole in image 2 is (x,y) =(%s,%s)',e2(2,1),e2(1,1)));
hold off;

%3.
[t1,t2] = estimateUncalibratedRectification(f,mf1,mf2,size(im1));
[I1Rect,I2Rect] = rectifyStereoImages(im1,im2,t1,t2);
% figure,imshow(stereoAnaglyph(I1Rect,I2Rect));

dispRange = [-56,56];
dispMap = disparitySGM(I1Rect,I2Rect,'DisparityRange',dispRange,'UniquenessThreshold',10);
figure, imshow(dispMap,dispRange)
title('Disparity Map(UniquenessThreshold=10)')
colormap default
colorbar;
function [im,f,vf] =readandget(name)
    im = rgb2gray(im2double(imread(name)));
%     im = imresize(im,0.4);
    p = detectSURFFeatures(im);
    [f,vf] = extractFeatures(im,p);
end

function eset = getepi(im,f,mfp,mfl,index)
    color = ['b' 'g' 'y' 'c' 'm' 'r' 'w' 'k'];
    eset = [];
    for j = 1:size(index,1)
        c = round(j/1.95);
        impt2 =mfl(index(j),:);
        plot(mfp(index(j),1),mfp(index(j),2),'-s','MarkerSize',15,'LineWidth',5,'Color',color(c));
        epipolar = f*[impt2,ones(size(impt2,1),1)]';
        epipolar = epipolar';
        eset = [eset;epipolar];
        e = lineToBorderPoints(epipolar,size(im));
        line(e(:,[1,3])',e(:,[2,4])','LineStyle','--','Color',color(c),'LineWidth',1.5);
    end
end