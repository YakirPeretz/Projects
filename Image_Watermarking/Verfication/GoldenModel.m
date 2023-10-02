clc;
clear;
for k=1:1:12
filename = sprintf('primary_image_%d.jpg',k);
I = imread(filename);
Nx = randi([200 720]);
I = imresize(I,[Nx Nx]);
W = imread('watermark_image.png');
if (numel(size(I))==3)
I = rgb2gray(I);
end
W = rgb2gray(W);
Amax_min = 0.90;
Amax_max = 0.99;
Amax = Amax_min+rand(1)*(Amax_max-Amax_min);
Amax = round(Amax,2);
Amin_min = 0.80;
Amin_max = Amax;
Amin = Amin_min+rand(1)*(Amin_max-Amin_min);
Amin = round(Amin,2);
Bmax_min = 0.30;
Bmax_max = 0.40;
Bmax = Bmax_min+rand(1)*(Bmax_max-Bmax_min);
Bmax = round(Bmax,2);
Bmin_min = 0.20;
Bmin_max = Bmax;
Bmin = Bmin_min+rand(1)*(Bmin_max-Bmin_min);
Bmin = round(Bmin,2);
Bthr = randi([0 20]);
Np = (size(I));
Np = Np(1);
Nw = (size(W));
Nw = Nw(1);
N = Np;
M = randi([1 round(N/10)]);
while ((mod(N,M)))
M = randi([1 round(N/10)]);
end
Iw = uint8(zeros(N,N));
Iwk = uint8(zeros(M,M));
I = double(imresize(I,[N N]));
I_new = I(:);
Ik = double(zeros(M,M));
W = double(imresize(W,[N N]));
W_new = W(:);
Wk = double(zeros(M,M));
sigma = 0.0;
sigmau = 0.0;
sigmas = 0.0;
Guk = 0.0;
uk = 0.0;
sk = 0.0;
ak = 0.0;
bk = 0.0;
for r=1:1:(N/M)
for c=1:1:(N/M)
%%%% 1 - Fill Block
for rows=1:1:M
for cols=1:1:M
Ik(rows,cols) = I_new(rows + (cols-1)*N + (r-1)*M + (c-1)*M*N);
Wk(rows,cols) = W_new(rows + (cols-1)*N + (r-1)*M + (c-1)*M*N);
end
end
%%%% 2 - Edge Detector
for rows=1:1:M
for cols=1:1:M
if ((rows == M) && (cols == M))
sigma = sigma + 2*Ik(rows,cols);
elseif (rows == M)
sigma = sigma + Ik(rows,cols) + abs(Ik(rows,cols) - Ik(rows,cols+1));
elseif (cols == M)
sigma = sigma + abs(Ik(rows,cols) - Ik(rows+1,cols)) + Ik(rows,cols);
else
sigma = sigma + abs(Ik(rows,cols) - Ik(rows+1,cols)) + abs(Ik(rows,cols) - Ik(rows,cols+1));
end
end
end
Guk = round(sigma / (M*M));
%%%% 3 - Parameters Calculator
if (Guk >= Bthr)
for rows=1:1:M
for cols=1:1:M
Iw((r-1)*M + rows,(c-1)*M + cols) = round(Amax*Ik(rows,cols) + Bmin*Wk(rows,cols));
end
end
else % (guk < bthr)
for rows=1:1:M
for cols=1:1:M
sigmau = sigmau + Ik(rows,cols);
sigmas = sigmas + abs(Ik(rows,cols) - 128);
end
end
uk = round(sigmau / (M*M*256));
sk = round((2*sigmas) / (M*M*256));
ak = round(Amin + ((Amax - Amin)*(2^(-(uk-0.5)^2)))/(sk));
bk = round(Bmin + (sk)*((Bmax - Bmin)*(1-2^(-(uk-0.5)^2))));
for rows=1:1:M
for cols=1:1:M
Iw((r-1)*M + rows,(c-1)*M + cols) = round(ak*Ik(rows,cols) + bk*Wk(rows,cols));
end
end
end
end
end
figure;
imshow(Iw);
imagname = sprintf('watermarked_image(result)_%d.jpg',k);
imwrite(Iw,imagname);
% Primary Image
outname = sprintf('primary_image_%d.txt',k);
fid = fopen(outname, 'wt');
fprintf(fid, '%d\n', N); % decimal writing of image row/cols size
fprintf(fid, '%d\n', I); % decimal writing of pixels value
disp('Text file write done');disp(' ');
fclose(fid);
% Watermark Image
outname = sprintf('watermark_image_%d.txt',k);
fid = fopen(outname, 'wt');
fprintf(fid, '%d\n', N); % decimal writing of image row/cols size
fprintf(fid, '%d\n', W); % decimal writing of pixels value
disp('Text file write done');disp(' ');
fclose(fid);
% Watermarked Image (Result)
outname = sprintf('watermarked_image(result)_%d.txt',k);
fid = fopen(outname, 'wt');
fprintf(fid, '%d\n', N); % decimal writing of image row/cols size
fprintf(fid, '%d\n', Iw); % decimal writing of pixels value
disp('Text file write done');disp(' ');
fclose(fid);
% Paramters Random Values
outname = sprintf('parameters_random_value_%d.txt',k);
fid_ai = fopen(outname, 'wt');
fprintf(fid_ai, '%d %d %d %d %d %d\n', M, Bthr, round(Amin*100), round(Amax*100), round(Bmin*100), round(Bmax*100)); % decimal writing of parameters value
disp('Text file write done');disp(' ');
fclose(fid_ai);
end