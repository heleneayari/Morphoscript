function varargout = SelectFiles(varargin)
% SELECTFILES MATLAB code for SelectFiles.fig
%      SELECTFILES, by itself, creates a new SELECTFILES or raises the existing
%      singleton*.
%
%      H = SELECTFILES returns the handle to a new SELECTFILES or the handle to
%      the existing singleton*.
%
%      SELECTFILES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTFILES.M with the given input arguments.
%
%      SELECTFILES('Property','Value',...) creates a new SELECTFILES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectFiles_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectFiles_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectFiles

% Last Modified by GUIDE v2.5 06-Oct-2017 14:08:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectFiles_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectFiles_OutputFcn, ...
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


% --- Executes just before SelectFiles is made visible.
function SelectFiles_OpeningFcn(hObject, eventdata, handles, varargin)


handles.output = hObject;

p = inputParser;
addOptional(p, 'startdir', pwd, @isstr);
addParameter(p, 'Scale', 0, @isnumeric);
addParameter(p, 'Threshold', 0.1, @isnumeric);
addParameter(p, 'WindowSize', 15, @isnumeric);
parse(p, varargin{:});
handles.startdir = p.Results.startdir;
handles.pathnames = {};
handles.filenames = {};
handles.MaskFileName = {};
handles.ImageFileName = {};
handles.sc=p.Results.Scale;
handles.Threshold=p.Results.Threshold;
handles.WindowSize=p.Results.WindowSize;

set(handles.listbox, 'String', fullfile(handles.pathnames, handles.filenames), 'Value',1)

handles.savedir = handles.startdir;
set(handles.text_savedir,'String',handles.savedir);

set(0, 'defaultAxesTickLabelInterpreter','latex'); 
set(0, 'defaultLegendInterpreter','latex');
set(0, 'defaultTextInterpreter','latex');



guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = SelectFiles_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.pathnames;
varargout{2} = handles.filenames;


% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox


% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton_plus.
function pushbutton_plus_Callback(hObject, eventdata, handles)
[filenames, pathname, filterindex] = uigetfile( {  '*.tif; *.tiff; *.TIF', 'TIF-files'; '*.tif; *.tiff; *.TIF; *.png; *.jpeg','All Images (tif, png, jpeg)'; '*.*',  'All Files (*.*)'}, 'Pick a file', 'MultiSelect', 'on', handles.startdir);
A=iscell(filenames);
B=0;
if ~A
   if filenames~=0
       B=1;
   end
end
if A|B
handles.startdir = pathname;
handles.filenames = [handles.filenames filenames];
if A
    handles.pathnames = [handles.pathnames repmat({pathname}, [1, length(filenames)])];
else
    
    handles.pathnames = [handles.pathnames pathname];
end

%set(handles.listbox, 'String', fullfile(handles.pathnames, handles.filenames), 'Value',1);
set(handles.listbox, 'String', handles.filenames, 'Value',1);
end
guidata(hObject, handles);

% --- Executes on button press in pushbutton_min.
function pushbutton_min_Callback(hObject, eventdata, handles)
assignin ('base', 'handles', handles);
index_selected = get(handles.listbox,'Value');
handles.filenames(index_selected) = [];
handles.pathnames(index_selected) = [];
%set(handles.listbox, 'String', fullfile(handles.pathnames, handles.filenames), 'Value',1);
set(handles.listbox, 'String', handles.filenames, 'Value',1);
guidata(hObject, handles);

% --- Executes on button press in pushbutton_savedir.
function pushbutton_savedir_Callback(hObject, eventdata, handles)
savedir = uigetdir(handles.startdir);
if savedir ~= 0
    handles.savedir = savedir;
    set(handles.text_savedir, 'String', handles.savedir);
end
guidata(hObject, handles)

function pushbutton_checkMasks_Callback(hObject, eventdata, handles)
handles = findMasks(handles);
guidata(hObject, handles)


% --- Executes on button press in pushbutton_MakeMasks.
function pushbutton_MakeMasks_Callback(hObject, eventdata, handles)
%close(SelectFiles);
for i = 1 : length(handles.filenames)
    MakeMask('pathname', handles.pathnames{i}, 'filename', handles.filenames{i}, 'savedir', handles.savedir);
end
guidata(hObject, handles)

% --- Executes on button press in pushbutton_Fourier.
function pushbutton_Fourier_Callback(hObject, eventdata, handles)
handles = findMasks(handles);
for i = 1 : length(handles.ImageFileName)
    i
    if length(handles.sc)>1
    FourierAnalysis('ImageFileName', handles.ImageFileName{i}, 'MaskFileName', handles.MaskFileName{i}, 'SaveDir', handles.savedir,'Scale',handles.sc(i),...
        'Threshold',handles.Threshold,'WindowSize',handles.WindowSize);
    else
            FourierAnalysis('ImageFileName', handles.ImageFileName{i}, 'MaskFileName', handles.MaskFileName{i}, 'SaveDir', handles.savedir,'Scale',handles.sc,...
        'Threshold',handles.Threshold,'WindowSize',handles.WindowSize);

    end
    end
guidata(hObject, handles)

function pushbutton_shapeanalysis_Callback(hObject, ~, handles)
handles = findMasks(handles);
for i = 1 : length(handles.ImageFileName)
    SA = ShapeAnalysis('ImageFileName', handles.ImageFileName{i}, 'MaskFileName', handles.MaskFileName{i}, 'SaveDir', handles.savedir);
end
close(SA); clear SA;
guidata(hObject, handles)

function handles = findMasks(handles)
handles.MaskFileName = {};
handles.ImageFileName = {};
counter = 0;
for i = 1 : length(handles.filenames)
    FileName = handles.filenames{i};
    loc = regexp(FileName, '\.');
    
    if exist([handles.savedir '/masks/' FileName(1:loc(end)-1) '_mask1.mat'])
        counter = counter + 1;
        handles.MaskFileName{counter} = [handles.savedir '/masks/' FileName(1:loc(end)-1) '_mask1.mat'];
        handles.ImageFileName{counter} = [handles.pathnames{i} handles.filenames{i}];
        handles.mask{i} = 2;
        
        m = 2;
        while exist([handles.savedir '/masks/' FileName(1:loc(end)-1) '_mask' num2str(m) '.mat'])
            counter = counter +1;
            handles.MaskFileName{counter} = [handles.savedir '/masks/' FileName(1:loc(end)-1) '_mask' num2str(m) '.mat'];
            handles.ImageFileName{counter} = [handles.pathnames{i} handles.filenames{i}];
            handles.mask{i} = 3;
            m = m + 1;
        end
    else
        handles.mask{i} = 1;
    end
end

cmap = [204, 0, 0; %#CC0000
        102, 205, 170; %#66CDAA
        92, 76, 251]; %#5C4CFB    

str{length(handles.filenames)} = {};
for i = 1 : length(handles.filenames)
   str{i} = ['<HTML><FONT color="' reshape(dec2hex(cmap(handles.mask{i},:), 2 )', 1, 6) '">' handles.filenames{i} '</FONT></HTML>'];
end
set(handles.listbox, 'String', str, 'Value',1);

if counter == 0
    ed = errordlg('no masks found in savedir/masks/','Error');
    set(ed, 'WindowStyle', 'modal');
    uiwait(ed);
    return
end