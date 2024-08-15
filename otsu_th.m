close all;
clc;
clear all
% Opening Tiff File
Directory = 'C:\Users\dilatak\Desktop\DilaAnaliz\Imaging1@5.1'; %degistir
mkdir Threshold
save_dir='C:\Users\dilatak\Desktop\DilaAnaliz\Threshold'; %degistir
Folder=Directory;
files=dir(Directory);
Tablo=[];
for i=3:length(files)
filename = files(i);
File=filename.name;

[X1,map1] = imread(fullfile(Folder, File),1);
[X2,map2] = imread(fullfile(Folder, File),2);
[X3,map3] = imread(fullfile(Folder, File),3);
[X4,map4] = imread(fullfile(Folder, File),4);
[X5,map5] = imread(fullfile(Folder, File),5);
[X6,map6] = imread(fullfile(Folder, File),6);

rgbImage1 = X1;
% Extract color channels.
redChannel1 = rgbImage1(:,:,1); % Red channel
greenChannel1 = rgbImage1(:,:,2); % Green channel
blueChannel1 = rgbImage1(:,:,3); % Blue channel

rgbImage2 = X2;
% Extract color channels.
redChannel2 = rgbImage2(:,:,1); % Red channel
greenChannel2 = rgbImage2(:,:,2); % Green channel
blueChannel2 = rgbImage2(:,:,3); % Blue channel

rgbImage3 = X3;
% Extract color channels.
redChannel3 = rgbImage3(:,:,1); % Red channel
greenChannel3 = rgbImage3(:,:,2); % Green channel
blueChannel3 = rgbImage3(:,:,3); % Blue channel

rgbImage4 = X4;
% Extract color channels.
redChannel4 = rgbImage4(:,:,1); % Red channel
greenChannel4 = rgbImage4(:,:,2); % Green channel
blueChannel4 = rgbImage4(:,:,3); % Blue channel

rgbImage5 = X5;
% Extract color channels.
redChannel5 = rgbImage5(:,:,1); % Red channel
greenChannel5 = rgbImage5(:,:,2); % Green channel
blueChannel5 = rgbImage5(:,:,3); % Blue channel

rgbImage6 = X6;
% Extract color channels.
redChannel6 = rgbImage6(:,:,1); % Red channel
greenChannel6 = rgbImage6(:,:,2); % Green channel
blueChannel6 = rgbImage6(:,:,3); % Blue channel

red = cat(3,redChannel1,redChannel2,redChannel3,redChannel4,redChannel5,redChannel6);
green = cat(3,greenChannel1,greenChannel2,greenChannel3,greenChannel4,greenChannel5,greenChannel6);
blue = cat(3,blueChannel1,blueChannel2,blueChannel3,blueChannel4,blueChannel5,blueChannel6);

redmax = max(red,[],3);
% figure
% imshow(redmax)
% title('Red - Max Intensity')

greenmax = max(green,[],3);
% figure
% imshow(greenmax)
% title('Green - Max Intensity')

bluemax = max(blue,[],3);
% figure
% imshow(bluemax)
% title('Blue - Max Intensity')

reddesp = medfilt2(redmax);
% figure
% imshow(reddesp)
% title('Red - Despeckled')

greendesp = medfilt2(greenmax);
% figure
% imshow(greendesp)
% title('Green - Despeckled')

se = strel('ball', 3, 3);
redsubback = imtophat(reddesp,se);
% figure
% imshow(redsubback)
% title('Red - Background Subtraction')

se = strel('ball', 3, 3);
greensubback = imtophat(greendesp,se);
% figure
% imshow(greensubback)
% title('Green - Background Subtraction')

redlevel = graythresh(redsubback);
redotsu = imbinarize(redsubback,redlevel);
% figure
% imshow(redotsu)
% title('Red - Otsu Threshold')
%% Image Save Redotsu

im_name1=strcat(File,'_redotsu','.tif');

imwrite(redotsu,fullfile(save_dir,im_name1),'tif')
%%
greenlevel = graythresh(greensubback);
greenotsu = imbinarize(greensubback,greenlevel);
% figure
% imshow(greenotsu)
% title('Green - Otsu Threshold')
%% Image Save Greenotsu

im_name2=strcat(File,'_greenotsu','.tif');

imwrite(greenotsu,fullfile(save_dir,im_name2),'tif')
%%
[labeledImage1, numBlobs1] = bwlabel(redotsu);
props1 = regionprops(labeledImage1, redsubback,'Area','MeanIntensity','PixelValues');

% for k = 1 : numBlobs1
%     thisBlobsValues1 = props1(k).PixelValues;
%     integratedGrayValues1(k) = sum(thisBlobsValues1);
% end

allRedAreas = [props1.Area];
allRedMeans = [props1.MeanIntensity];
TotalRedMeanPixelValues = mean(allRedMeans);
totalRedArea = sum(allRedAreas);
RedAreaPercent = totalRedArea/(512*512);
allRedIGLs = allRedAreas .* allRedMeans;
RedIntDent = sum(allRedIGLs);

[labeledImage2, numBlobs2] = bwlabel(greenotsu);
props2 = regionprops(labeledImage2, greensubback,'Area','MeanIntensity','PixelValues');

% for k = 1 : numBlobs2
%     thisBlobsValues2 = props2(k).PixelValues;
%     integratedGrayValues1(k) = sum(thisBlobsValues2);
% end

allGreenAreas = [props2.Area];
allGreenMeans = [props2.MeanIntensity];
TotalGreenMeanPixelValues = mean(allGreenMeans);
totalGreenArea = sum(allGreenAreas);
GreenAreaPercent = totalGreenArea/(512*512);
allGreenIGLs = allGreenAreas .* allGreenMeans;
GreenIntDent = sum(allGreenIGLs);

PericyteDensity = (sum(allRedIGLs)/sum(allGreenIGLs));

% Writing Excel
name=string(File);


Tablo = [Tablo;name,totalRedArea, RedAreaPercent, TotalRedMeanPixelValues, RedIntDent, totalGreenArea, GreenAreaPercent, TotalGreenMeanPixelValues, GreenIntDent,PericyteDensity];

end
header=["name","totalRedArea","RedAreaPercent","TotalRedMeanPixelValues","RedIntDent","totalGreenArea","GreenAreaPercent","TotalGreenMeanPixelValues", "GreenIntDent","PericyteDensity"];
Tablo=[header;Tablo];
Tablo=table(Tablo);
writetable(Tablo,strcat('Dilas_magic_table','.xls'),'Sheet',1,'Range',strcat('A1',':K4000'))
