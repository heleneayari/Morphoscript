function varargout = GUIfft2D(varargin)
% GUIFFT2D MATLAB code for GUIfft2D.fig
%      GUIFFT2D, by itself, creates a new GUIFFT2D or raises the existing
%      singleton*.
%
%      H = GUIFFT2D returns the handle to a new GUIFFT2D or the handle to
%      the existing singleton*.
%
%      GUIFFT2D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIFFT2D.M with the given input arguments.
%
%      GUIFFT2D('Property','Value',...) creates a new GUIFFT2D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIfft2D_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIfft2D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIfft2D

% Last Modified by GUIDE v2.5 18-Nov-2019 18:26:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUIfft2D_OpeningFcn, ...
    'gui_OutputFcn',  @GUIfft2D_OutputFcn, ...
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


% --- Executes just before GUIfft2D is made visible.
function GUIfft2D_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

set(0, 'defaultAxesTickLabelInterpreter','latex'); 
set(0, 'defaultLegendInterpreter','latex');
set(0, 'defaultTextInterpreter','latex');

%sz=get(groot,'ScreenSize');

set(handles.figure1,'Units','pixel')
set(handles.figure1,'Position',[100 200 900 800])
set(handles.figure1,'InnerPosition',[100 100 900 800])
set(handles.figure1,'toolbar','figure');
set(handles.figure1,'visible','off');

p = inputParser;
addRequired(p, 'Image', @isnumeric);
addParameter(p, 'Resolution',[1, 1] ,@isnumeric);
addParameter(p, 'SaveDir', pwd, @isstr);
addParameter(p, 'SaveName', datestr(now, 30), @isstr);
addParameter(p, 'Mode', 'Auto', @(x) any(validatestring(x, {'Auto','Hand'})));

parse(p, varargin{:});
handles.Mode = p.Results.Mode;

handles.results = [];
% delete(findall(handles.figure1,'type','annotation'))
% figure(handles.figure1)
% handles.dim1=[0.58 0.25 0.2 0.2];
% handles.a1=annotation('textbox',handles.dim1,'String','','FitBoxToText','on','Interpreter','latex','LineWidth',0.5);
% 
% handles.dim2=[0.1 0.25 0.2 0.2];
% handles.a2=annotation('textbox',handles.dim2,'String','','FitBoxToText','on','Interpreter','latex','LineWidth',0.5);


handles.FIA = FourierImageAnalysisModel(varargin{:});
handles.FIA.performFft;
handles.FIA.interpolateFft;
handles.FIA.calculateDirection;
handles.FIA.calculateMainAnisotropicSize;
handles.FIA.calculateOrthogonalAnisotropicSize;
handles.FIA.calculateIsotropicSize;


handles.h=zoom(handles.figure1);
zoom(handles.figure1,8)

if ~exist(handles.FIA.SaveDir,'dir')
    mkdir(handles.FIA.SaveDir);
end

set(handles.pushbutton_ortho, 'enable', 'off');

handles.wavelength_color = [0.8 0 0.4];
handles.w=handles.FIA.OrthogonalWavelength;
handles = showImage(handles);

handles = showFft(handles);

handles = showDirection(handles);

handles = showOrthoAnisotropicSize(handles);

if strcmp(handles.Mode,'Auto')
    handles.closeFigure = true;
    guidata(hObject, handles);
    pushbutton_save_Callback(hObject, eventdata, handles);
else






    guidata(hObject, handles);
    uiwait(handles.figure1);
end

function varargout = GUIfft2D_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
varargout{2} = handles.results;

if (isfield(handles,'closeFigure') && handles.closeFigure)
  figure1_CloseRequestFcn(hObject, eventdata, handles)

end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, ~, ~)
delete(hObject);

%%%%%%%%%% PUSHBUTTONS %%%%%%%%%%
function pushbutton_size_Callback(hObject, ~, handles)
% there is something wrong with not using qr
% fix the button colors
% maybe an output button?

axes(handles.axes_size);
[x,~] = ginput(1);
if strcmp(get(handles.pushbutton_iso, 'enable'),'off')
    handles.FIA.calculateIsotropicSize(x);
    handles.wavelength_color = [0.8 0.4 0];
    handles.w=handles.FIA.IsotropicWavelength;
    handles = showIsotropicSize(handles);
    
elseif strcmp(get(handles.pushbutton_main, 'enable'),'off')
    handles.wavelength_color = [0.4 0 0.8];
    handles.FIA.calculateMainAnisotropicSize(x);
    handles.w=handles.FIA.MainWavelength;
    handles = showMainAnisotropicSize(handles);
    
elseif strcmp(get(handles.pushbutton_ortho, 'enable'),'off')
    handles.wavelength_color = [0.8 0 0.4];
    handles.FIA.calculateOrthogonalAnisotropicSize(x);
    handles.w=handles.FIA.OrthogonalWavelength;
    handles = showOrthoAnisotropicSize(handles);
end
handles = showImage(handles);
axes(handles.axes_fft)
handles = showFft(handles);

guidata(hObject, handles);

function pushbutton_angle_Callback(hObject, ~, handles)
axes(handles.axes_angle);

[x,~] = ginput(1);

handles.FIA.calculateDirection(x);

handles = showDirection(handles);
handles.FIA.calculateMainAnisotropicSize;
handles.FIA.calculateOrthogonalAnisotropicSize;

handles.w=handles.FIA.OrthogonalWavelength;
handles = showOrthoAnisotropicSize(handles);
handles = showFft(handles);
handles = showImage(handles);
guidata(hObject, handles);

function pushbutton_iso_Callback(hObject, ~, handles)
handles.FIA.calculateIsotropicSize;

handles.wavelength_color = [0.8 0.4 0];
handles.w=handles.FIA.IsotropicWavelength;
handles = showIsotropicSize(handles);
handles = showImage(handles);
handles = showFft(handles);
set(handles.pushbutton_iso, 'enable', 'off');
set(handles.pushbutton_main, 'enable', 'on');
set(handles.pushbutton_ortho, 'enable', 'on');
guidata(hObject, handles);

function pushbutton_main_Callback(hObject, ~, handles)
handles.FIA.calculateMainAnisotropicSize;

handles.wavelength_color = [0.4 0 0.8];
handles = showMainAnisotropicSize(handles);
handles.w=handles.FIA.MainWavelength;
handles = showImage(handles);
handles = showFft(handles);
set(handles.pushbutton_iso, 'enable', 'on');
set(handles.pushbutton_main, 'enable', 'off');
set(handles.pushbutton_ortho, 'enable', 'on');
guidata(hObject, handles);

function pushbutton_ortho_Callback(hObject, ~, handles)
handles.FIA.calculateOrthogonalAnisotropicSize;

handles.wavelength_color = [0.8 0 0.4];
handles = showOrthoAnisotropicSize(handles);
handles.w=handles.FIA.OrthogonalWavelength;
handles = showImage(handles);
handles = showFft(handles);
set(handles.pushbutton_iso, 'enable', 'on');
set(handles.pushbutton_main, 'enable', 'on');
set(handles.pushbutton_ortho, 'enable', 'off');
guidata(hObject, handles);

function pushbutton_cancel_Callback(hObject, ~, handles)
handles.results.cancel = 'cancelled';
uiresume(handles.figure1);
guidata(hObject, handles);

function pushbutton_save_Callback(hObject, ~, handles)
handles.results.MainWavelength = handles.FIA.MainWavelength;
handles.results.MainWavelengthAmplitude = handles.FIA.MainWavelengthAmplitude;
handles.results.OrthogonalWavelength = handles.FIA.OrthogonalWavelength;
handles.results.OrthogonalWavelengthAmplitude = handles.FIA.OrthogonalWavelengthAmplitude;
handles.results.IsotropicWavelength = handles.FIA.IsotropicWavelength;
handles.results.IsotropicWavelengthAmplitude = handles.FIA.IsotropicWavelengthAmplitude;
handles.results.MainAngle = handles.FIA.MainAngle;
handles.results.MainAngleAmplitude = handles.FIA.MainAngleAmplitude;
fft2D = handles.results;

loc = regexp(handles.FIA.SaveName, '_');
if ~isdir([handles.FIA.SaveDir 'fft2D_' handles.FIA.SaveName(1:loc(end)-1) '/'])
    mkdir([handles.FIA.SaveDir 'fft2D_' handles.FIA.SaveName(1:loc(end)-1) '/'])
end
save([handles.FIA.SaveDir 'fft2D_' handles.FIA.SaveName(1:loc(end)-1) '/' handles.FIA.SaveName '_fft2D.mat'],'fft2D');
hgexport(handles.figure1,[handles.FIA.SaveDir 'fft2D_' handles.FIA.SaveName(1:loc(end)-1) '/' handles.FIA.SaveName '_fft2D.png'],hgexport('factorystyle'),'Format','png');

uiresume(handles.figure1);
guidata(hObject, handles);


%%%%%%%%%% MY FUNCTIONS %%%%%%%%%
function handles = showImage(handles)
%%%%%%%%%

axes(handles.axes_image);
imshow(handles.FIA.Image,[],'parent',handles.axes_image);
hold(handles.axes_image,'on');
%lineangle(handles.FIA.Angle, handles.FIA.ImageSize(1)/2, handles.FIA.ImageCenter(2), handles.FIA.ImageCenter(1), 'Color',[0.4 0.8 0],'LineWidth',2, 'parent', handles.axes_image);
line([handles.FIA.ImageCenter(2) - handles.FIA.ImageSize(2)/4 * cos(handles.FIA.MainAngle), handles.FIA.ImageCenter(2) + handles.FIA.ImageSize(2)/4 * cos(handles.FIA.MainAngle)], [handles.FIA.ImageCenter(1) - handles.FIA.ImageSize(1)/4 * sin(handles.FIA.MainAngle), handles.FIA.ImageCenter(1) + handles.FIA.ImageSize(1)/4 * sin(handles.FIA.MainAngle)], 'Color',[0.4 0.8 0],'LineWidth',2, 'parent', handles.axes_image);
circle(handles.FIA.ImageCenter(2), handles.FIA.ImageCenter(1),handles.w/2/ handles.FIA.Resolution(1), 'Color', handles.wavelength_color, 'LineWidth', 2, 'parent', handles.axes_image);
hold(handles.axes_image,'off');



%setAllowAxesZoom(handles.h,handles.axes_image,false);


%%%%%%%%%
function handles = showFft(handles)
%%%%%%%%%%
axes(handles.axes_fft)
imshow(log(imgaussfilt(handles.FIA.FftImage)),[],'parent',handles.axes_fft);

hold(handles.axes_fft,'on');
line([handles.FIA.ImageCenter(2) - handles.FIA.ImageSize(2)/4 * cos(handles.FIA.MainAngle), handles.FIA.ImageCenter(2) + handles.FIA.ImageSize(2)/4 * cos(handles.FIA.MainAngle)], [handles.FIA.ImageCenter(1) - handles.FIA.ImageSize(1)/4 * sin(handles.FIA.MainAngle), handles.FIA.ImageCenter(1) + handles.FIA.ImageSize(1)/4 * sin(handles.FIA.MainAngle)], 'Color',[0.4 0.8 0],'LineWidth',2, 'parent', handles.axes_fft);
%lineangle(handles.angle, handles.L/2, handles.xc, handles.yc, 'Color',[0.4 0.8 0],'LineWidth',2, 'parent', handles.axes_fft);
circle(handles.FIA.ImageCenter(2), handles.FIA.ImageCenter(1), (handles.FIA.ImageSize(1) == handles.FIA.ImageSize(2)) * handles.FIA.ImageSize(1)*handles.FIA.Resolution(1)/handles.w, 'Color', handles.wavelength_color, 'LineWidth', 2, 'parent', handles.axes_fft);

%circle(handles.xc, handles.yc, (handles.Lx == handles.Ly) * handles.Lx/handles.wavelength, 'Color', handles.wavelength_color, 'LineWidth', 2, 'parent', handles.axes_fft);
hold(handles.axes_fft,'off');
zoom(4)











%%%%%%%%%

function handles = showDirection(handles)
%%%%%%%%%%
figure(handles.figure1)
axes(handles.axes_angle);
plot(handles.FIA.qth*180/pi, handles.FIA.Mdir,'Color',[0.4 0.8 0],'LineWidth', 2, 'parent', handles.axes_angle); hold on
hold(handles.axes_angle,'on');
plot(handles.FIA.MainAngle*180/pi, handles.FIA.MainAngleAmplitude, 's', 'Color', 0.8 * [0.4 0.8 0], 'MarkerFaceColor', [0.4 0.8 0], 'MarkerSize', 10, 'parent', handles.axes_angle);
xlabel('angle ($^o$)');
ylabel('mean intensity');
hold(handles.axes_angle,'off');

handles.a2.String=[num2str(handles.FIA.MainAngle*180/pi,'%0.0f') '$^o$'];

%setAllowAxesZoom(handles.h,handles.axes_angle,false);
%%%%%%%%%%%

function handles = showIsotropicSize(handles)
%%%%%%%%%%
figure(handles.figure1)
axes(handles.axes_size);

plot(1./handles.FIA.qr, handles.FIA.Msz ,'Color',handles.wavelength_color, 'LineWidth',2, 'parent', handles.axes_size); hold on
%plot(qrt, Mszt ,'+','Color',handles.wavelength_color, 'parent', handles.axes_size); hold on

hold(handles.axes_size,'on');
plot(handles.FIA.IsotropicWavelength, handles.FIA.IsotropicWavelengthAmplitude, '^', 'Color', 0.8 * handles.wavelength_color, 'LineWidth', 2, 'MarkerFaceColor', handles.wavelength_color, 'MarkerSize', 10,'parent', handles.axes_size);
xlabel('wavelength ($\mu $m)');
ylabel('mean intensity');
hold(handles.axes_size, 'off');

handles.a1.String=[num2str(handles.FIA.IsotropicWavelength,'%0.2f') ' $\mu m$'];

%setAllowAxesZoom(handles.h,handles.axes_size,false);
%%%%%%%%%%

function handles = showMainAnisotropicSize(handles)
%%%%%%%%%%
figure(handles.figure1)
axes(handles.axes_size);


plot(1./handles.FIA.qr, handles.FIA.MAS,'+-','Color',handles.wavelength_color,'LineWidth',2,'parent', handles.axes_size);

hold(handles.axes_size,'on');
plot(handles.FIA.MainWavelength, handles.FIA.MainWavelengthAmplitude, '^', 'Color', 0.8 * handles.wavelength_color, 'LineWidth', 2, 'MarkerFaceColor', handles.wavelength_color, 'MarkerSize', 10,'parent', handles.axes_size);
xlabel('wavelength ($\mu m$)');
ylabel('mean intensity');

handles.a1.String=[num2str(handles.FIA.MainWavelength,'%0.2f') ' $\mu m$'];

hold(handles.axes_size, 'off');
%setAllowAxesZoom(handles.h,handles.axes_size,false);
%%%%%%%%%%

function handles = showOrthoAnisotropicSize(handles, varargin)
%%%%%%%%%%
figure(handles.figure1)
axes(handles.axes_size);

%plot(handles.FIA.vec, handles.FIA.OAS,'+-','Color',handles.wavelength_color,'LineWidth',2,'parent', handles.axes_size);
plot(1./handles.FIA.qr, handles.FIA.OAS,'+-','Color',handles.wavelength_color,'LineWidth',2,'parent', handles.axes_size);

hold(handles.axes_size,'on');
plot(handles.FIA.OrthogonalWavelength, handles.FIA.OrthogonalWavelengthAmplitude, '^', 'Color', 0.8 * handles.wavelength_color, 'MarkerFaceColor', handles.wavelength_color, 'LineWidth', 2, 'MarkerSize', 10,'parent', handles.axes_size);
xlabel('wavelength ($\mu m$)');
ylabel('mean intensity');

handles.a1.String=[num2str(handles.FIA.OrthogonalWavelength,'%0.2f') ' $\mu m$'];
hold(handles.axes_size, 'off');
%set(handles.text_size, 'String', [num2str(handles.FIA.OrthogonalWavelength,'%0.2f') ' $\mu m$']);
%setAllowAxesZoom(handles.h,handles.axes_size,false);

%%%%%%%%%%


% --- Executes on button press in notgood.
function notgood_Callback(hObject, eventdata, handles)
% hObject    handle to notgood (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.results.out = 'out';
uiresume(handles.figure1);
guidata(hObject, handles);


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
