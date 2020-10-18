[FileName,PathName,FilterIndex] = uigetfile('*.raw;*.yuv', 'Image', '');
filename = fullfile(PathName, FileName);

width  = 1920;
height = 1080;

fileID = fopen(filename);

Y = fread(fileID, height * width, '*uint8');
Y = reshape(Y, width, height);
Y = double(permute(Y, [2 1])) / 255;

null = fread(fileID, 15360);

UV1 = fread(fileID, height * width, '*uint8');

fclose(fileID);

UV = reshape(UV1, 2, width / 2, height);
UV = permute(UV, [1 3 2]);

U = reshape(UV(1, :, :), height, width / 2);
V = reshape(UV(2, :, :), height, width / 2);

U = (double(imresize(U, size(Y), 'nearest')) - 128) / 255;
V = (double(imresize(V, size(Y), 'nearest')) - 128) / 255;

yuv = cat(3,Y,U,V) / 255;

% T = [1, 0, 1.13983;
%      1, -0.39465, -0.58060;
%      1, 2.03211, 0];
T = [1.164   0.000   1.596;
     1.164  -0.392  -0.813;
     1.164   2.017   0.000];
% ITU-R BT.601, RGB limited range, results in the following transform matrix:
%  T = [1.000   0.000   1.402;
%  1.000  -0.344  -0.714;
%  1.000   1.772   0.000];
% ITU-R BT.709, RGB limited range, results in the following transform matrix:
%  T = [1.000   0.000   1.570   
%      1.000  -0.187  -0.467
%     1.000   1.856   0.000];

RGB(:,:,1) = T(1) * Y + T(4) * U + T(7) * V;
RGB(:,:,2) = T(2) * Y + T(5) * U + T(8) * V;
RGB(:,:,3) = T(3) * Y + T(6) * U + T(9) * V;

rImage = uint8(RGB * 255);

figure,imshow(rImage);

[filepath, name, ext] = fileparts(filename);
filename = sprintf('%s\\%s.png', filepath, name);
imwrite(rImage, filename, 'png');
