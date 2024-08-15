close all;
clc;
% Opening Tiff File
Directory = 'C:\Users\dilatak\Desktop\DilaAnaliz\1'; %degistir
mkdir Threshold
save_dir='C:\Users\dilatak\Desktop\DilaAnaliz\Threshold'; %degistir
Folder=Directory;
files=dir(Directory);
Tablo=[];
goruntu="on";
%% Waitbar
WW=waitbar(0,'Image Processing Starts');
N=length(files);
%% Processing Loop
for i=3:N
%% Waitbar
  rtnum=num2str(i);
  RTnum=num2str(N);
  rtnum=strcat('Current Image Number: ',{' '},rtnum);
  RTnum=strcat('Total Number of Images: ',RTnum);
  disp=string({rtnum,RTnum});
  waitbar(i/N,WW,disp)
%% File acquisition
filename = files(i);
File=filename.name;
[X1,map1] = imread(fullfile(Folder, File),'TIF',1);
[X2,map2] = imread(fullfile(Folder, File),'TIF',2);
[X3,map3] = imread(fullfile(Folder, File),'TIF',3);
[X4,map4] = imread(fullfile(Folder, File),'TIF',4);
[X5,map5] = imread(fullfile(Folder, File),'TIF',5);
[X6,map6] = imread(fullfile(Folder, File),'TIF',6);
%% Channel arrangement
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
%% Channel Extract 
redChannel6 = rgbImage6(:,:,1); % Red channel
greenChannel6 = rgbImage6(:,:,2); % Green channel
blueChannel6 = rgbImage6(:,:,3); % Blue channel
%% Channel OVERLAP 
red = cat(3,redChannel1,redChannel2,redChannel3,redChannel4,redChannel5,redChannel6);
green = cat(3,greenChannel1,greenChannel2,greenChannel3,greenChannel4,greenChannel5,greenChannel6);
blue = cat(3,blueChannel1,blueChannel2,blueChannel3,blueChannel4,blueChannel5,blueChannel6);
%% max
redmax = max(red,[],3);
greenmax = max(green,[],3);
bluemax = max(blue,[],3);
%% Gaussian Filter
sigma=2;
red_filtered = imgaussfilt(redmax,sigma);
green_filtered = imgaussfilt(greenmax,sigma);
%% Histogram
bin=50;
[red_hist]=imhist(red_filtered,bin);
[green_hist]=imhist(green_filtered,bin);
%% Triangle
red_triangle=triangle_th(red_hist,bin);
green_triangle=triangle_th(green_hist,bin);
%% Thresholded Image Generation
red_thresh=imbinarize(red_filtered,red_triangle);
green_thresh=imbinarize(green_filtered,green_triangle);
%% Create Mask
% red_mask=1 - red_thresh;
% green_mask=1 - green_thresh;
% figure
% imshow(red_mask)
%% Pixel extraction
pixel=50; % PIXEL^2 
red_cleared = bwareaopen(red_thresh,pixel);
green_cleared = bwareaopen(green_thresh,pixel);
% figure
% imshow(1-red_cleared) % EGER OLUR DA BIR GUN BEYAZ USTUNE SIYAH GEREKIRSE KI EMINIM GEREKIR
%% Display
if goruntu=="on"
    figure(1)
    subplot(2,2,1), imshow(redmax)
    subplot(2,2,2), imshow(red_cleared)
    subplot(2,2,3), imshow(greenmax)
    subplot(2,2,4), imshow(green_cleared)
    fig_name=strcat(File,'_panel','.tif');
    saveas(gcf,fullfile(save_dir,fig_name))
end
%% Image Save Cleared
im_name_red=strcat(File,'_red_triangle','.tif');
imwrite(red_cleared,fullfile(save_dir,im_name_red),'tif')
im_name_green=strcat(File,'_green_triangle','.tif');
imwrite(green_cleared,fullfile(save_dir,im_name_green),'tif')

%% Processing the Table
[labeledImage1, numBlobs1] = bwlabel(red_cleared);
props1 = regionprops(labeledImage1,red_filtered,'Area','MeanIntensity','PixelValues');
allRedAreas = [props1.Area];
allRedMeans = [props1.MeanIntensity];
TotalRedMeanPixelValues = mean(allRedMeans);
totalRedArea = sum(allRedAreas);
RedAreaPercent = totalRedArea/(512*512);
allRedIGLs = allRedAreas .* allRedMeans;
RedIntDent = sum(allRedIGLs);

[labeledImage2, numBlobs2] = bwlabel(green_cleared);
props2 = regionprops(labeledImage2, green_filtered,'Area','MeanIntensity','PixelValues');

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
close(WW)
close(figure(1))
header=["name","totalRedArea","RedAreaPercent","TotalRedMeanPixelValues","RedIntDent","totalGreenArea","GreenAreaPercent","TotalGreenMeanPixelValues", "GreenIntDent","PericyteDensity"];
Tablo=[header;Tablo];
Tablo=table(Tablo);
writetable(Tablo,strcat('Dilas_magic_table','.xls'),'Sheet',1,'Range',strcat('A1',':K4000'))
