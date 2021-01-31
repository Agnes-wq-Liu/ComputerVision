%RANSAC for homography stitching
[im1,f1,vf1] =readandget('room1.jpg');
[im2,f2,vf2] =readandget('room2.jpg');
indexPair = matchFeatures(f1,f2);
mf1 = vf1(indexPair(:,1));
mf2 = vf2(indexPair(:,2));
% figure, showMatchedFeatures(im1,im2,mf1,mf2);
[m1,m2] = deal(mf1.Location,mf2.Location);
M1 = normM(m1);
M2 = normM(m2);
m1 = norm(m1);
m2 = norm(m2);
%i thought the locations were (y,x)... so flip them
points = [m1(:,2) m1(:,1) m2(:,2) m2(:,1)];
csbiggest =[];
Hbiggest = [];
% 1. randomly choose 4 tuples from all
for j=1:100
    cand = zeros(4,4);
    for i=1:4
        cand(i,:) = points(randi(size(points,1)),:);
    end
    % fit to get homography
    A = generate(cand);
    [V,~] = eig(A'*A);
    H = reshape(V(:,1),[3,3])';
    H = H/H(end);
    H = inv(M2)*(H * M1);
    cset =[];
    for i=1:size(points,1)
        if any(cand(:)==points(i))
            continue
        else
    %       compute the distance
            newpt = H*[points(i,2),points(i,1),1].';
            xhat = newpt(1)/newpt(3);
            yhat = newpt(2)/newpt(3);
            dist = sqrt((xhat-points(i,4)).^2+(yhat-points(i,3)).^2);
            if dist < 2000
                cset= [cset;points(i,:)];
            end
        end
    end 
    if size(cset)>size(csbiggest)
        csbiggest = cset;
        Hbiggest = H;
    end
end

% % 2. create matrix A with all pts from csbiggest
A = generate(csbiggest);

% refit H using svd(A)
[V,~] = eig(A'*A);
H = reshape(V(:,1),[3,3])';
H = H/H(end);
H = inv(M2)*(H * M1);
% 3. create composite image: R for im1 and BG for im2
ps = round(max(size(im1))/2);
redout = padarray(im1,[ps,ps],0,'both');
bgout = zeros(size(redout));
for y =1:(size(bgout,1))
    for x = 1:(size(bgout,2))
        % use the original image for mapping
        pt = [x-ps,y-ps,1];
        newpt = H*pt.';
        x2 = round(newpt(1)/newpt(3));
        y2 = round(newpt(2)/newpt(3));
        % mapped to the original pixels
        % if in range, update with the original coordinates
        if y2<=size(im2,1) && x2<=size(im2,2) && y2>0 && x2>0
            bgout(y,x) = im2(y2,x2);
        else
            continue
        end
    end
end

raw = cat(3,redout,bgout,bgout);
figure, imshow(raw);


%   define M1,M2
function m = normM(arr)
    n = size(arr,1);
    avg1 = mean(arr(:,1));
    avg2 = mean(arr(:,2));
    diff1 = (arr(:,1)-avg1).^2;
    diff2 = (arr(:,2)-avg2).^2;
    sig1 = sqrt(sum(diff1,'all')/(2*n));
    sig2 = sqrt(sum(diff2,'all')/(2*n));
    nom = [1 0 -avg1; 0 1 -avg2; 0 0 1];
    denom = [1/sig1 0 0; 0 1/sig2 0; 0 0 1];
    m = denom * nom;
end
function arr = norm(arr)
    n = size(arr,1);
    avg1 = mean(arr(:,1));
    avg2 = mean(arr(:,2));
    diff1 = (arr(:,1)-avg1).^2;
    diff2 = (arr(:,2)-avg2).^2;
    sig1 = sqrt(sum(diff1,'all')/(2*n));
    sig2 = sqrt(sum(diff2,'all')/(2*n));
    arr(:,1) = (arr(:,1)-avg1)./sig1;
    arr(:,2) = (arr(:,2)-avg2)./sig2;
end
% generate array
function A = generate(cand)
    s = size(cand,1)*2;
    [A1,A2,A3,A4,A5,A6,A7,A8,A9] = deal(zeros(s,1));
    [A1(1:2:s-1),A2(1:2:s-1),A4(2:2:s),A5(2:2:s)] = deal(cand(:,2),cand(:,1),cand(:,2),cand(:,1));
    [A3(1:2:s-1),A6(2:2:s)] = deal(1.0);
    [A9(1:2:s-1),A9(2:2:s)] = deal(-cand(:,4),-cand(:,3));
    [A7(1:2:s-1),A8(1:2:s-1)] = deal(-cand(:,4).*cand(:,2),-cand(:,4).*cand(:,1));
    [A7(2:2:s),A8(2:2:s)] = deal(-cand(:,3).*cand(:,2),-cand(:,3).*cand(:,1));
    A = [A1 A2 A3 A4 A5 A6 A7 A8 A9];
end

function [im,f,vf] =readandget(name)
    im = rgb2gray(im2double(imread(name)));
    p = detectSURFFeatures(im);
    [f,vf] = extractFeatures(im,p);
end
    