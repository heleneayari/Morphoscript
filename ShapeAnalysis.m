function varargout = ShapeAnalysis(varargin)
% SHAPEANALYSIS MATLAB code for ShapeAnalysis.fig
%      SHAPEANALYSIS, by itself, creates a new SHAPEANALYSIS or raises the existing
%      singleton*.
%
%      H = SHAPEANALYSIS returns the handle to a new SHAPEANALYSIS or the handle to
%      the existing singleton*.
%
%      SHAPEANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHAPEANALYSIS.M with the given input arguments.
%
%      SHAPEANALYSIS('Property','Value',...) creates a new SHAPEANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ShapeAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ShapeAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ShapeAnalysis

% Last Modified by GUIDE v2.5 10-Jul-2017 21:03:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ShapeAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @ShapeAnalysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function ShapeAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
set(handles.figure1,'toolbar','figure');

p = inputParser;
addParameter(p, 'ImageFileName', pwd, @isstr); %should be required..
addParameter(p, 'MaskFileName', 'bla', @isstr); %should be required..
addParameter(p, 'SaveDir', pwd, @isstr);
parse(p, varargin{:});
handles.ImageFileName = p.Results.ImageFileName;
handles.MaskFileName = p.Results.MaskFileName;
handles.SaveDir = p.Results.SaveDir;

handles.ResDir = [p.Results.SaveDir '/results/'];
if ~isdir(handles.ResDir)
    mkdir(handles.ResDir)
end

handles.imo = im2double(imread(handles.ImageFileName));
if size(handles.imo, 3) > 1
    handles.img = handles.imo(:, :, 2);   
else
    handles.img = handles.imo;
end

load(handles.MaskFileName);
handles.Image = handles.img;
handles.Image(~mask) = 0;
handles.Mask = mask;

if exist('sc','var')
handles.sc=sc;

else
    info=imfinfo([handles.ImageFileName]);
dd='Enter the pixel size  in µm';

    if isempty(info.XResolution)
        x = inputdlg(dd,'PixelSize',1,{'1'});
handles.sc=str2double(x{1});
    else
handles.sc=1/info.XResolution;
    end
end

% else
%     disp('no mask found');
%     handles.Image = handles.img;
%     handles.Mask = ones(size(handles.Image),'logical');
% end

handles.ImageSize = size(handles.Image);
p = regionprops(handles.Mask,'Area','Centroid', 'MajorAxisLength','MinorAxisLength', 'Orientation', 'Perimeter','Eccentricity');
handles.Area = p.Area;
handles.Centroid = p.Centroid;
handles.MajorAxisLength = p.MajorAxisLength;
handles.MinorAxisLength = p.MinorAxisLength;
handles.Orientation = p.Orientation;
handles.Perimeter = p.Perimeter;
handles.Eccentricity = p.Eccentricity;

handles = calculateOtsu(handles);
handles = calculateCompactness(handles);
handles = calculateBoundingBox(handles);
handles = calculateEllipse(handles);
handles = showOtsu(handles);

guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = ShapeAnalysis_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function pushbutton_otsu_Callback(hObject, eventdata, handles)
handles = calculateOtsu(handles);
handles = showOtsu(handles);
guidata(hObject, handles);

function pushbutton_compactness_Callback(hObject, eventdata, handles)
handles = calculateCompactness(handles);
handles = showCompactness(handles);
guidata(hObject, handles);

function pushbutton_boundingbox_Callback(hObject, eventdata, handles)
handles = calculateBoundingBox(handles);
handles = showBoundingBox(handles);
guidata(hObject, handles);

function pushbutton_ellipse_Callback(hObject, eventdata, handles)
handles = calculateEllipse(handles);
handles = showEllipse(handles);
guidata(hObject, handles);

function pushbutton_original_Callback(hObject, eventdata, handles)
handles = showImage(handles);
guidata(hObject, handles);

function pushbutton_save_Callback(hObject, eventdata, handles)
loc = regexp(handles.MaskFileName, '\.');
SaveName = handles.MaskFileName(length(handles.SaveDir)+8:loc(end) - 1); %not great programming
hgexport(handles.figure1, [handles.ResDir SaveName '_ShapeAnalysis.png'], hgexport('factorystyle'), 'Format', 'png');

handles.results.MaskPixels = handles.MaskPixels;
handles.results.OtsuPixels = handles.OtsuPixels;
handles.results.MaskMicrons = handles.MaskPixels*handles.sc^2;
handles.results.OtsuMicrons = handles.OtsuPixels*handles.sc^2;
handles.results.Coverage = handles.Coverage;
handles.results.MeanImageIntensity = handles.MeanImageIntensity;
handles.results.MaxImageIntensity = handles.MaxImageIntensity;
handles.results.MeanProteinIntensity = handles.MeanProteinIntensity;
handles.results.Compactness = handles.Compactness;
handles.results.Roundness = handles.Roundness;
handles.results.Rectangularity = handles.Rectangularity;
handles.results.Elongation = handles.Elongation;
handles.results.Ellipsoidal = handles.Ellipsoidal;
handles.results.Eccentricity = handles.Eccentricity;
handles.results.MeanBackCellIntensity = handles.MeanBackCellIntensity;
SA = handles.results;
save([handles.ResDir SaveName '_ShapeAnalysis.mat'], 'SA');

handles.closeFigure = true;
uiresume(handles.figure1);
guidata(hObject, handles);

%%%%%%%%%% MY FUNCTIONS %%%%%%%%%%
function handles = calculateOtsu(handles)
[handles.Level, handles.Effectivity] = graythresh(handles.Image); %Otsu method
handles.Otsu = im2bw(handles.Image, handles.Level);

handles.MaskPixels = sum(handles.Mask(:));
handles.OtsuPixels = sum(handles.Otsu(:));
handles.Coverage = sum(handles.Otsu(:))/sum(handles.Mask(:));

handles.MeanImageIntensity = mean(handles.Image(:));
handles.MaxImageIntensity = max(handles.Image(:));
handles.MeanProteinIntensity = mean(handles.Image(handles.Otsu(:)));
handles.MeanBackCellIntensity = mean(handles.Image(handles.Mask(:)&~handles.Otsu(:)));

set(handles.text_Coverage, 'String', ['Coverage - ' num2str(handles.Coverage, '%.2f')]);
set(handles.text_Pixels, 'String', [num2str(handles.OtsuPixels) '/' num2str(handles.MaskPixels) ' pixels']);
set(handles.text_Threshold, 'String', ['Threshold - ' num2str(handles.Level, '%.2f')]);
set(handles.text_Effectivity, 'String', ['Effectivity - '  num2str(handles.Effectivity, '%.2f')]);
set(handles.text_MeanImageIntensity, 'String', ['Mean Image Intensity - ' num2str(handles.MeanImageIntensity, '%.2f')]);
set(handles.text_MaxImageIntensity, 'String', ['Max Image Intensity - ' num2str(handles.MaxImageIntensity)]);
set(handles.text_MeanProteinIntensity, 'String', ['Mean Protein Intensity - '  num2str(handles.MeanProteinIntensity, '%.2f')]);

function handles = calculateCompactness(handles)
handles.Compactness = handles.Perimeter^2/(4*pi*handles.Area);
handles.Roundness = 4*pi*handles.Area/(handles.Perimeter^2);

set(handles.text_Compactness, 'String', ['Compactness - ' num2str(handles.Compactness, '%.2f')]);
set(handles.text_Roundness, 'String', ['Roundness - ' num2str(handles.Roundness, '%.2f')]);

function handles = calculateBoundingBox(handles)
imt = imrotate(handles.Mask, -handles.Orientation);
[rows, columns] = find(imt);
[l, ~] = min(columns); 
[r, ~] = max(columns); 
[t, ~] = min(rows); 
[b, ~] = max(rows);

R = [cos(deg2rad(handles.Orientation))   sin(deg2rad(handles.Orientation)); -sin(deg2rad(handles.Orientation))   cos(deg2rad(handles.Orientation))];
xy = [l r r l l; t t b b t];
xy = xy - size(imt)'/2;
xy = R * xy;
xy = xy + handles.ImageSize'/2;

handles.BoundingBoxHeight = b - t;
handles.BoundingBoxWidth = r - l;
handles.BoundingBox = xy;

handles.Rectangularity = handles.Area/(handles.BoundingBoxHeight * handles.BoundingBoxWidth);
handles.Elongation = min(handles.BoundingBoxWidth, handles.BoundingBoxHeight)/max(handles.BoundingBoxWidth, handles.BoundingBoxHeight);

set(handles.text_Rectangularity, 'String', ['Rectangularity - ' num2str(handles.Rectangularity, '%.2f')]);
set(handles.text_Elongation, 'String', ['Elongation - ' num2str(handles.Elongation, '%.2f')]);

function handles = calculateEllipse(handles)
handles.Ellipsoidal = handles.MinorAxisLength / handles.MajorAxisLength;

set(handles.text_Ellipsoidal, 'String', ['Ellipsoidal - ' num2str(handles.Ellipsoidal, '%.2f')]);
set(handles.text_Eccentricity, 'String', ['Eccentricity - ' num2str(handles.Eccentricity, '%.2f')]);

function handles = showImage(handles)
cla(handles.axes_image);
imshow(handles.Image,[],'parent',handles.axes_image);

function handles = showOtsu(handles)
[B, ~] = bwboundaries(handles.Mask, 'noholes');
Boundary = B{1};

cla(handles.axes_image);
imshow(handles.Otsu, 'parent', handles.axes_image);
hold(handles.axes_image,'on');
plot(Boundary(:,2), Boundary(:,1), 'r', 'LineWidth', 2, 'parent', handles.axes_image)
hold(handles.axes_image,'off');

function handles = showCompactness(handles)
[B, ~] = bwboundaries(handles.Mask, 'noholes');
Boundary = B{1};

cla(handles.axes_image);
imshow(handles.Mask,[], 'parent', handles.axes_image);
hold(handles.axes_image,'on');
plot(Boundary(:,2), Boundary(:,1), 'r', 'LineWidth', 2, 'parent', handles.axes_image)
hold(handles.axes_image,'off');

function handles = showBoundingBox(handles)
cla(handles.axes_image);
imshow(handles.Mask,[], 'parent', handles.axes_image);
hold(handles.axes_image,'on');
plot(handles.BoundingBox(1, :), handles.BoundingBox(2, :), 'r', 'Linewidth', 2, 'parent', handles.axes_image);
hold(handles.axes_image,'off');

function handles = showEllipse(handles)
cla(handles.axes_image);
imshow(handles.Mask,[], 'parent', handles.axes_image);
hold(handles.axes_image,'on');

theta = 0 : 0.01 : 2*pi;
R = [cos(deg2rad(handles.Orientation)), sin(deg2rad(handles.Orientation)); -sin(deg2rad(handles.Orientation)), cos(deg2rad(handles.Orientation))];
xy = [handles.MajorAxisLength/2 * cos(theta); handles.MinorAxisLength/2 * sin(theta)];
xy = R * xy;

x = xy(1, :) + handles.Centroid(1);
y = xy(2, :) + handles.Centroid(2);
plot(x, y, 'r', 'LineWidth', 2, 'parent', handles.axes_image);
hold(handles.axes_image,'off');
