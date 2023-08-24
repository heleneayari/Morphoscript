function varargout = FourierAnalysis(varargin)
% FOURIERANALYSIS MATLAB code for FourierAnalysis.fig
%      FOURIERANALYSIS, by itself, creates a new FOURIERANALYSIS or raises the existing
%      singleton*.
%
%      H = FOURIERANALYSIS returns the handle to a new FOURIERANALYSIS or the handle to
%      the existing singleton*.
%
%      FOURIERANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FOURIERANALYSIS.M with the given input arguments.
%
%      FOURIERANALYSIS('Property','Value',...) creates a new FOURIERANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FourierAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FourierAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FourierAnalysis

% Last Modified by GUIDE v2.5 24-Sep-2020 11:43:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FourierAnalysis_OpeningFcn, ...
    'gui_OutputFcn',  @FourierAnalysis_OutputFcn, ...
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

% --- Executes just before FourierAnalysis is made visible.
function FourierAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
set(handles.figure1,'toolbar','figure');

p = inputParser;
addParameter(p, 'ImageFileName', pwd, @isstr); %should be required..
addParameter(p, 'MaskFileName', 'bla', @isstr); %should be required..
addParameter(p, 'SaveDir', pwd, @isstr);
addParameter(p, 'Mode', 'Hand', @(x) any(validatestring(x, {'Auto','Hand'})));
addParameter(p, 'Scale', 0, @isnumeric);
addParameter(p, 'WindowSize', 15, @isnumeric);
addParameter(p, 'Threshold', 0.1, @isnumeric);
parse(p, varargin{:});
handles.Mode = p.Results.Mode;
handles.ImageFileName = p.Results.ImageFileName;
handles.MaskFileName = p.Results.MaskFileName;
handles.SaveDir = p.Results.SaveDir;
handles.results = [];
handles.sc=p.Results.Scale;
handles.compt=0;
handles.ResDir = [p.Results.SaveDir '/results/'];
handles.ws = p.Results.WindowSize;%en ?m
handles.Threshold = p.Results.Threshold;

if ~isdir(handles.ResDir)
    mkdir(handles.ResDir)
end

temp_cellstr = {'Pixels';'µm';};
set(handles.popupmenu1,'String',temp_cellstr);
set(handles.popupmenu1,'Value',2);

handles.imo = double(imread(handles.ImageFileName));

if size(handles.imo, 3) > 1
    handles.img = handles.imo(:, :, 2);
else
    handles.img = handles.imo;
end

load(handles.MaskFileName);
if exist('sc','var')
    handles.sc=sc;
end
handles.Mask = mask;
handles.Image = handles.img;
handles.Image(~mask) = 0;

if handles.sc==0
    
    info=imfinfo([handles.ImageFileName]);
    dd='Enter the pixel size  in \mum';
    
    if isempty(info.XResolution)
        aa.Interpreter='tex';
        x = inputdlg(dd,'PixelSize',1,{'1'},aa);
        handles.sc=str2double(x{1});
    else
        handles.sc=1/info.XResolution;
    end
elseif handles.sc==1
    set(handles.popupmenu1,'Value',1);
    handles.ws=round(min(size(handles.imo))/10);
    set(handles.edit_windowsize,'String',num2str(handles.ws));
end
set(handles.edit_pixelsize,'String',num2str(handles.sc,'%0.3f'));


handles.WindowSize = round(handles.ws/handles.sc) + ~bitget(abs(round(handles.ws/handles.sc)),1);

set(handles.edit_windowsize,'String',num2str(handles.ws));
handles.overlap = 0.5;
set(handles.edit_overlap,'String',num2str(handles.overlap));

set(handles.edit_threshold,'String',num2str(handles.Threshold));

handles = makeGrid(handles);
guidata(hObject, handles);



if strcmp(handles.Mode,'Auto')
    pushbutton_RunModel_Callback(hObject, eventdata,handles) ;
    %     handles.closeFigure = true;
    handles=guidata(hObject);
    
    
    pushbutton_save_Callback(hObject,eventdata,handles) ;
else
    set(handles.pushbutton_save, 'Enable','off');
    if isfield(handles,'h')
        set(handles.h,'color','r')
        figure(handles.h)
        uiwait(handles.h)
    end
    guidata(hObject, handles);
    uiwait(handles.figure1);
    
end



% UIWAIT makes FourierAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function varargout = FourierAnalysis_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

if (isfield(handles,'closeFigure') && handles.closeFigure)
    figure1_CloseRequestFcn(hObject, eventdata, handles)
end

function figure1_CloseRequestFcn(hObject, ~, ~)
delete(hObject);

function edit_windowsize_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_windowsize_Callback(hObject, ~, handles)
handles.ws = str2double(get(hObject,'string'));
if isnan(handles.ws)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return
else
    
    handles.WindowSize = round(handles.ws/handles.sc) + ~bitget(abs(round(handles.ws/handles.sc)),1);
    
end
handles = makeGrid(handles);
guidata(hObject, handles);

function edit_pixelsize_Callback(hObject, ~, handles)
% hObject    handle to edit_pixelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pixelsize as text
%        str2double(get(hObject,'String')) returns contents of edit_pixelsize as a double
handles.sc = str2double(get(hObject,'string'));
if isnan(handles.sc)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return
else
    
    handles.WindowSize = round(handles.ws/handles.sc) + ~bitget(abs(round(handles.ws/handles.sc)),1);
    
    
    handles = makeGrid(handles);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_pixelsize_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_pixelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_overlap_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_overlap_Callback(hObject, ~, handles)
input = str2double(get(hObject,'string'));
if isnan(input)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return
elseif input < 0 || input > 1
    errordlg('You must enter a value between 0 and 1','Invalid Input','modal')
    uicontrol(hObject)
    return
else
    handles.overlap = input;
end
handles = makeGrid(handles);
guidata(hObject, handles);

function edit_threshold_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_threshold_Callback(hObject, ~, handles)
input = str2double(get(hObject,'string'));
if isnan(input)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return
else
    handles.Threshold = input;
end
if isfield(handles,'WavelengthAmplitude')
    handles = displayAngles(handles);
    handles = calculateHistogram(handles);
end
guidata(hObject, handles);

function edit_Max_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton_runauto.
function pushbutton_runauto_Callback(hObject, ~, handles)
for w = 1 : length(handles.X(:))
    imc = handles.Image(handles.Y(w) - (handles.WindowSize - 1)/2 : handles.Y(w) + (handles.WindowSize - 1)/2, handles.X(w) - (handles.WindowSize - 1)/2 : handles.X(w) + (handles.WindowSize - 1)/2);
    loc = regexp(handles.MaskFileName, '\.');
    SaveName = [handles.MaskFileName(length(handles.SaveDir)+8:loc(end) - 1) '_' num2str(w)]; %not great programming
    [hfft, fft2D] = GUIfft2D(imc, 'SaveDir', handles.ResDir, 'SaveName', SaveName, 'Mode', 'Auto','Resolution',[handles.sc handles.sc]);
    
    handles.Wavelength(w) = fft2D.OrthogonalWavelength;
    handles.Angle(w) = fft2D.MainAngle;
    handles.WavelengthAmplitude(w) = fft2D.OrthogonalWavelengthAmplitude;
    clear g;
end
handles = calculateHistogram(handles);
handles = displayAngles(handles);
set(handles.pushbutton_save, 'Enable','on');
guidata(hObject, handles)

function pushbutton_runhand_Callback(hObject, ~, handles)
for w = 1 : length(handles.X(:))
    imc = handles.Image(handles.Y(w) - (handles.WindowSize - 1)/2 : handles.Y(w) + (handles.WindowSize - 1)/2, handles.X(w) - (handles.WindowSize - 1)/2 : handles.X(w) + (handles.WindowSize - 1)/2);
    loc = regexp(handles.MaskFileName, '\.');
    SaveName = [handles.MaskFileName(length(handles.SaveDir)+8:loc(end) - 1) '_' num2str(w)]; %not great programming
    [~, fft2D] = GUIfft2D(imc, 'SaveDir', handles.ResDir, 'SaveName', SaveName, 'Mode', 'Hand','Resolution',[handles.sc handles.sc]);
    if isfield(fft2D, 'cancel') %to make sure we don't get an error after the cancel button is pushed
        return
    end
    handles.Wavelength(w) = fft2D.OrthogonalWavelength;
    handles.Angle(w) = fft2D.MainAngle;
    handles.WavelengthAmplitude(w) = fft2D.OrthogonalWavelengthAmplitude;
    
    %%%%%%%%%%
    dl = (handles.WindowSize - 1)/2;
    if fft2D.OrthogonalWavelengthAmplitude > handles.Threshold
        handles.l(w) = line([handles.X(w) - dl/2 * cos(fft2D.MainAngle), handles.X(w) + dl/2 * cos(fft2D.MainAngle)], [handles.Y(w) - dl/2 * sin(fft2D.MainAngle), handles.Y(w) + dl/2 * sin(fft2D.MainAngle)], 'Color', [1 0 1], 'LineStyle', '-', 'LineWidth', 2, 'Parent', handles.axes);
    else
        handles.l(w) = line([handles.X(w) - dl/2 * cos(fft2D.MainAngle), handles.X(w) + dl/2 * cos(fft2D.MainAngle)], [handles.Y(w) - dl/2 * sin(fft2D.MainAngle), handles.Y(w) + dl/2 * sin(fft2D.MainAngle)], 'Color', [1 0 1], 'LineStyle', ':', 'LineWidth', 2, 'Parent', handles.axes);
    end
    clear g;
end
handles = calculateHistogram(handles);
handles = displayAngles(handles);
set(handles.pushbutton_save, 'Enable','on');
guidata(hObject, handles)

function pushbutton_edit_Callback(hObject, ~, handles)
axes(handles.axes);
[x, y] = ginput(1);
[~, ind] = min((handles.Y(:)-y).^2 + (handles.X(:)-x).^2);
r = rectangle('Position', [handles.X(ind) - (handles.WindowSize - 1)/2, handles.Y(ind) - (handles.WindowSize - 1)/2, handles.WindowSize, handles.WindowSize], 'EdgeColor', [0 1 0], 'LineWidth', 2, 'FaceColor', [0 1 0]);
imc = handles.Image(handles.Y(ind) - (handles.WindowSize - 1)/2 : handles.Y(ind) + (handles.WindowSize - 1)/2, handles.X(ind) - (handles.WindowSize - 1)/2 : handles.X(ind) + (handles.WindowSize - 1)/2);
loc = regexp(handles.MaskFileName, '\.');
SaveName = [handles.MaskFileName(length(handles.SaveDir)+8:loc(end) - 1) '_' num2str(ind)]; %not great programming
[~, fft2D] = GUIfft2D(imc, 'SaveDir', handles.ResDir, 'SaveName', SaveName, 'Mode', 'Hand','Resolution',[handles.sc handles.sc]);
if isfield(fft2D, 'cancel') %to make sure we don't get an error after the cancel button is pushed
    delete(r);
    clear g;
    return
end
if isfield(fft2D, 'out') % for not good results
    handles.WavelengthAmplitude(ind) =0;
    delete(r);
    clear g;
    handles = calculateHistogram(handles);
    handles = displayAngles(handles);
    set(handles.pushbutton_save, 'Enable','on');
    guidata(hObject, handles)
    return
end

handles.Wavelength(ind) = fft2D.OrthogonalWavelength;
handles.Angle(ind) = fft2D.MainAngle;
if fft2D.OrthogonalWavelengthAmplitude<handles.Threshold
    handles.WavelengthAmplitude(ind)=100;
else
    handles.WavelengthAmplitude(ind) = fft2D.OrthogonalWavelengthAmplitude;
end

delete(r);
clear g;
handles = calculateHistogram(handles);
handles = displayAngles(handles);
set(handles.pushbutton_save, 'Enable','on');
guidata(hObject, handles)

function pushbutton_RunModel_Callback(hObject, ~, handles)
oldpointer = get(handles.figure1, 'pointer');
set(handles.figure1, 'pointer', 'watch');
drawnow;

for w = 1 : length(handles.X(:))
    imc = handles.Image(handles.Y(w) - (handles.WindowSize - 1)/2 : handles.Y(w) + (handles.WindowSize - 1)/2, handles.X(w) - (handles.WindowSize - 1)/2 : handles.X(w) + (handles.WindowSize - 1)/2);
    loc = regexp(handles.MaskFileName, '\.');
    SaveName = [handles.MaskFileName(length(handles.SaveDir)+8:loc(end) - 1) '_' num2str(w)]; %not great programming
    
    FIA = FourierImageAnalysisModel(imc, 'SaveDir', handles.ResDir, 'SaveName', SaveName,'Resolution',[handles.sc handles.sc 1] );
    FIA.performFft;
    FIA.interpolateFft;
    FIA.calculateDirection;
    FIA.calculateMainAnisotropicSize;
    FIA.calculateOrthogonalAnisotropicSize;
    FIA.calculateIsotropicSize;
    handles.compt=handles.compt+FIA.modif;
    handles.Wavelength(w) = FIA.OrthogonalWavelength;
    handles.Angle(w) = FIA.MainAngle;
    handles.WavelengthAmplitude(w) = FIA.OrthogonalWavelengthAmplitude;
    clear g;
end
handles = calculateHistogram(handles);

handles = displayAngles(handles);
set(handles.figure1, 'pointer', oldpointer);
set(handles.pushbutton_save, 'Enable','on');
guidata(hObject, handles)

function pushbutton_save_Callback(hObject, ~, handles)

loc = regexp(handles.MaskFileName, '\.');
SaveName = handles.MaskFileName(length(handles.SaveDir)+8:loc(end) - 1); %not great programming
hgexport(handles.figure1, [handles.ResDir SaveName '_FourierAnalysis.png'], hgexport('factorystyle'), 'Format', 'png');

handles = saveHistogram(handles);

handles.results.Wavelength = handles.Wavelength;
handles.results.Angle = handles.Angle;
handles.results.WavelengthAmplitude = handles.WavelengthAmplitude;
handles.results.Windowsize = handles.WindowSize;
handles.results.Threshold = handles.Threshold;
handles.results.X = handles.X;
handles.results.Y = handles.Y;

handles.results.Distribution = handles.Distribution;
%handles.results.Distribution90 = handles.Distribution90;
handles.results.Order = handles.Order;
handles.results.Wavelengthmean = handles.Wavelengthmean;
handles.results.Wavelengthmed = handles.Wavelengthmed;
FIA = handles.results;
save([handles.ResDir SaveName '_FourierAnalysis.mat'], 'FIA');

handles.closeFigure = true;
uiresume(handles.figure1);
guidata(hObject, handles);

%%%%%%%%%% MY FUNCTIONS %%%%%%%%%%

function handles = makeGrid(handles)
cla(handles.axes);
imshow(handles.Image,[],'parent',handles.axes);
hold(handles.axes,'on');
Lx = size(handles.Image, 2) ;
Ly = size(handles.Image, 1);
L = max(Lx, Ly);
x = round((handles.WindowSize + 1)/2 : (1 - handles.overlap) * handles.WindowSize : Lx - (handles.WindowSize + 1)/2);
y = round((handles.WindowSize + 1)/2 : (1 - handles.overlap) * handles.WindowSize : Ly - (handles.WindowSize + 1)/2);

b = handles.Mask(y, x);
[X, Y] = meshgrid(x, y); X = X(:); Y = Y(:);
X(~b) = [];
Y(~b) = [];
plot(X, Y, 'm.', 'MarkerSize', 10, 'parent', handles.axes);

if isempty(X)&&isempty(Y)
    
    handles.h=msgbox('No window size fits in the next mask if you absolutely want to include this mask please consider using a smaller window size','problem');
    
    %uialert(handles.figure1,'No window size fits in the mask if you absolutely want to include this mask please consider using a smaller window size','problem');
    
else
    set(handles.axes, 'Xlim', [min(X(:)) - handles.WindowSize   max(X(:)) + handles.WindowSize]);
    set(handles.axes, 'Ylim', [min(Y(:)) - handles.WindowSize max(Y(:)) + handles.WindowSize]);
    cmap =[  0    0.4470    0.7410
        0.8500    0.3250    0.0980
        0.9290    0.6940    0.1250
        0.4940    0.1840    0.5560
        0.4660    0.6740    0.1880
        0.3010    0.7450    0.9330
        0.6350    0.0780    0.1840];
    vis = {'on', 'off', 'off', 'off'};
    for w = 1 : length(X(:))
        handles.r(w) = rectangle('Position', [X(w) - (handles.WindowSize - 1)/2, Y(w) - (handles.WindowSize - 1)/2, handles.WindowSize, handles.WindowSize], 'EdgeColor', cmap(mod(w,size(cmap,1))+1,:), 'LineWidth', 2, 'parent', handles.axes);
        handles.r(w).EdgeColor(4) = rand(1)/2 + 0.5;
        %rect([X(w) - handles.WindowSize/2, Y(w) - handles.WindowSize/2, handles.WindowSize, handles.WindowSize],'Color', cmap(mod(w,size(cmap,1))+1,:), 'Alpha', rand(1), 'LineWidth', 2,'parent',handles.axes);
    end
    hold(handles.axes,'off');
    handles.X = X;
    handles.Y = Y;
    
end


function handles = displayAngles(handles)
axes(handles.axes);
h = findobj(gca,'Type','line');
delete(h); drawnow;
for w = 1 : length(handles.X(:))
    %%%%%%%%%%
    dl = (handles.WindowSize - 1)/2;
    if handles.WavelengthAmplitude(w) > handles.Threshold
        handles.l(w) = line([handles.X(w) - dl/2 * cos(handles.Angle(w)), handles.X(w) + dl/2 * cos(handles.Angle(w))], [handles.Y(w) - dl/2 * sin(handles.Angle(w)), handles.Y(w) + dl/2 * sin(handles.Angle(w))], 'Color', [1 0 1], 'LineStyle', '-', 'LineWidth', 2, 'Parent', handles.axes);
    else
        handles.l(w) = line([handles.X(w) - dl/2 * cos(handles.Angle(w)), handles.X(w) + dl/2 * cos(handles.Angle(w))], [handles.Y(w) - dl/2 * sin(handles.Angle(w)), handles.Y(w) + dl/2 * sin(handles.Angle(w))], 'Color', [1 0 1], 'LineStyle', ':', 'LineWidth', 2, 'Parent', handles.axes);
    end
    %%%%%%%%%%
end

function handles = calculateHistogram(handles)

%% Difference between handles.angle (the one saved) which contained all the angles and all information
% and handles.angles which is taking the angle with area whose intensity in
% Fourier space is above the treshhold (parameter not saved)
teller = 0;
handles.Angles=[];
tempw=[];
for w = 1 : length(handles.X(:))
    
    if handles.WavelengthAmplitude(w) > handles.Threshold
        teller = teller + 1;
        handles.Angles(teller) = handles.Angle(w);
        tempw(teller)=handles.Wavelength(w);
    end
end
handles.Order = teller/length(handles.X(:));
[N,edges] = histcounts(handles.Angles, 17);

[~, hi] = max(N);

handles.Wavelengthmed=nanmedian(tempw);
handles.Wavelengthmean=nanmean(tempw);
handles.angles2 = mod(handles.Angles - (edges(hi+1) + edges(hi))/2 + pi/2, pi);

handles.Distribution=std(handles.angles2);

%handles.Angles90 = mod(handles.Angles, pi/2);
%handles.Distribution90 = std(handles.Angles90);
set(handles.text_wavelength,'string',['W - ' num2str(handles.Wavelengthmean,'%.2f')]);
set(handles.text_Order, 'String', ['Order - ' num2str(handles.Order, '%.2f')]);
set(handles.text_Distribution, 'String', ['Std - ' num2str(handles.Distribution, '%.2f')]);


function handles = saveHistogram(handles)
fr = figure;

polarhistogram(handles.angles2,17);
ax = gca;
ax.ThetaLim = [0 180];
loc = regexp(handles.MaskFileName, '\.');
SaveName = handles.MaskFileName(length(handles.SaveDir)+8:loc(end) - 1); %not great programming
%hgexport(fr, [handles.ResDir SaveName '_Histogram.eps'], hgexport('factorystyle'),'Format','eps');
hgexport(fr, [handles.ResDir SaveName '_Histogram.png'], hgexport('factorystyle'),'Format','png');
close




%% 90

% h = polarhistogram(handles.Angles90, 9);
% [~, hi] = max(h.BinCounts);
% ax = gca;
% ax.ThetaLim = [0 180];
%
% angles2 = mod(handles.Angles90 - (h.BinEdges(hi+1) + h.BinEdges(hi))/2 + pi/2, pi);
% polarhistogram(angles2, 9);
% ax = gca;
% ax.ThetaLim = [45 135];
% loc = regexp(handles.MaskFileName, '\.');
% SaveName = handles.MaskFileName(length(handles.SaveDir)+8:loc(end) - 1); %not great programming
% %hgexport(fr, [handles.ResDir SaveName '_Histogram90.eps'], hgexport('factorystyle'),'Format','eps');
% hgexport(fr, [handles.ResDir SaveName '_Histogram90.png'], hgexport('factorystyle'),'Format','png');
%close(fr);





% --- Executes on button press in pushbutton_next.
function pushbutton_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.closeFigure = true;
uiresume(handles.figure1);

guidata(hObject, handles);



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
