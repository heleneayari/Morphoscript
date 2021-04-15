%% prepare a neat environment
clear
clc
close all

%% set the default folder where images are stored and the threshold above which a sarcomeric 
% organization will be detected

dossier='Test_images'
th=0.1;

%[filenames, pathname, filterindex] = uigetfile( {  '*.tif; *.tiff; *.TIF', 'TIF-files'; '*.tif; *.tiff; *.TIF; *.png; *.jpeg','All Images (tif, png, jpeg)'; '*.*',  'All Files (*.*)'}, 'Pick a file', 'MultiSelect', 'on', dossier);


 SelectFiles(dossier,'Threshold',th);