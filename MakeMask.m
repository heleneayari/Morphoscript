function varargout = MakeMask(varargin)
% MAKEMASK MATLAB code for MakeMask.figf
%      MAKEMASK, by itself, creates a new MAKEMASK or raises the existing
%      singleton*.
%
%      H = MAKEMASK returns the handle to a new MAKEMASK or the handle to
%      the existing singleton*.
%
%      MAKEMASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAKEMASK.M with the given input arguments.
%
%      MAKEMASK('Property','Value',...) creates a new MAKEMASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MakeMask_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MakeMask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MakeMask

% Last Modified by GUIDE v2.5 12-Apr-2021 15:19:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MakeMask_OpeningFcn, ...
    'gui_OutputFcn',  @MakeMask_OutputFcn, ...
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

% --- Executes just before MakeMask is made visible.
function MakeMask_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

p = inputParser;
addParameter(p, 'pathname', pwd, @isstr); %should be required..
addParameter(p, 'filename', 'bla', @isstr); %should be required..
addParameter(p, 'savedir', pwd, @isstr);
%addParameter(p, 'mode', 'auto', @(x) any(validatestring(x, {'auto','hand'})));
parse(p, varargin{:});
handles.pathname = p.Results.pathname;
handles.filename = p.Results.filename;
handles.savedir = p.Results.savedir;
handles.maskdir = [p.Results.savedir '/masks/'];
%handles.mode = p.Results.mode;
handles.results = [];

if ~isdir(handles.maskdir)
    mkdir(handles.maskdir)
end

handles.imo = imread([handles.pathname handles.filename]);
if size(handles.imo, 3) > 1
    handles = all_channels(handles);
    
    set(handles.pushbutton_red, 'Enable','on');
    set(handles.pushbutton_green, 'Enable','on');
    set(handles.pushbutton_blue, 'Enable','on');
    set(handles.pushbutton_all, 'Enable','off');
    
else
    handles.im = handles.imo;
    
    set(handles.pushbutton_red, 'Enable','off');
    set(handles.pushbutton_green, 'Enable','off');
    set(handles.pushbutton_blue, 'Enable','off');
    set(handles.pushbutton_all, 'Enable','off');
end

%% get scale

info=imfinfo([handles.pathname handles.filename]);
dd='Enter the pixel size  in µm';

if isempty(info.XResolution)
    x = inputdlg(dd,'PixelSize',1,{'1'});
    handles.sc=str2double(x{1});
else
    handles.sc=1/info.XResolution;
end
%%%%%


handles.Lx = size(handles.im, 2); handles.Ly = size(handles.im, 1); handles.L = max([handles.Lx, handles.Ly]);

%%%%%%%%%
cla(handles.axes);
handles.h_im=imshow(handles.im,[],'parent',handles.axes);
%%%%%%%%%

set(handles.listbox, 'String', {'choose a method:'});
set(handles.listbox, 'Max', 2, 'Value', []);
%set(handles.listbox, 'Value', []);
handles.minsize =1000;
handles.strelsize=10;
guidata(hObject, handles);
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = MakeMask_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --- Executes on button press in pushbutton_red.
function pushbutton_red_Callback(hObject, eventdata, handles)
handles.im = handles.imo(:, :, 1);

set(handles.pushbutton_red, 'Enable','off');
set(handles.pushbutton_green, 'Enable','on');
set(handles.pushbutton_blue, 'Enable','on');
set(handles.pushbutton_all, 'Enable','on');

%%%%%%%%%
cla(handles.axes);
handles.h_im=imshow(handles.im,[],'parent',handles.axes);
%%%%%%%%%
guidata(hObject, handles);

% --- Executes on button press in pushbutton_green.
function pushbutton_green_Callback(hObject, eventdata, handles)
handles.im = handles.imo(:, :, 2);

set(handles.pushbutton_red, 'Enable','on');
set(handles.pushbutton_green, 'Enable','off');
set(handles.pushbutton_blue, 'Enable','on');
set(handles.pushbutton_all, 'Enable','on');

%%%%%%%%%
cla(handles.axes);
handles.h_im=imshow(handles.im,[],'parent',handles.axes);
%%%%%%%%%
guidata(hObject, handles);

% --- Executes on button press in pushbutton_blue.
function pushbutton_blue_Callback(hObject, eventdata, handles)
handles.im = handles.imo(:, :, 3);

set(handles.pushbutton_red, 'Enable','on');
set(handles.pushbutton_green, 'Enable','on');
set(handles.pushbutton_blue, 'Enable','off');
set(handles.pushbutton_all, 'Enable','on');

%%%%%%%%%
cla(handles.axes);
handles.h_im=imshow(handles.im,[],'parent',handles.axes);
%%%%%%%%%
guidata(hObject, handles);


% --- Executes on button press in pushbutton_all.
function pushbutton_all_Callback(hObject, eventdata, handles)
handles = all_channels(handles);

set(handles.pushbutton_red, 'Enable','on');
set(handles.pushbutton_green, 'Enable','on');
set(handles.pushbutton_blue, 'Enable','on');
set(handles.pushbutton_all, 'Enable','off');

%%%%%%%%%
cla(handles.axes);
handles.h_im=imshow(handles.im,[],'parent',handles.axes);
%%%%%%%%%
guidata(hObject, handles);

% --- Executes on button press in pushbutton_auto.
function pushbutton_auto_Callback(hObject, eventdata, handles)
handles = keep_log(handles, '----- auto -----'); drawnow;


handles = auto_method(handles, handles.im,1);

choice = questdlg('Are you satisfied?', 'Cell Outline', 'No, other method','Yes','Yes');
switch choice
    case 'No, other method'
        handles = keep_log(handles, 'try new method');
        handles = rmfield(handles, 'cell');
        h = findobj(gca,'Type','line');
        delete(h); drawnow;

   
    case 'Yes'
        handles = keep_log(handles, 'making masks...'); drawnow;
        handles = auto_mask(handles);
        handles = keep_log(handles, [num2str(handles.numCells) ' masks saved']);
        handles = rmfield(handles, 'cell');
        uiresume(handles.figure1);
end
guidata(hObject, handles);


% --- Executes on button press in pushbutton_manual.
function pushbutton_manual_Callback(hObject, eventdata, handles)
handles = keep_log(handles, '----- manual -----'); drawnow;

h = findobj(gca,'Type','line');
delete(h); drawnow;

go = 1;
n = 1;
handles = keep_log(handles, ['trace cell ' num2str(n)]);
hold(handles.axes,'on');
while go == 1
    h1 = imfreehand(handles.axes);

    set(gcf, 'WaitStatus','waiting');

    handles.cell(n).p = h1.getPosition;
    handles.BW{n} = createMask(h1,handles.h_im);
    
    delete(h1);
    h2 = plot(handles.cell(n).p(:, 1), handles.cell(n).p(:,2), 'r.', 'LineWidth', 2, 'MarkerSize', 10);
    
    choice = questdlg('Are you satisfied?', 'Cell Outline', 'No, redo','Yes, next cell','Yes, Im done','Yes, next cell');
    switch choice
        case 'No, redo'
            delete(h2);
            handles = keep_log(handles, ['trace cell ' num2str(n)]);
        case 'Yes, next cell'
            n = n + 1;
            handles = keep_log(handles, ['trace cell ' num2str(n)]);
        case 'Yes, Im done'
            handles = keep_log(handles, 'saving masks...'); drawnow;
            
            handles = manual_mask(handles);
            handles = keep_log(handles, [num2str(length(handles.cell)) ' masks saved']);
            handles = rmfield(handles, 'cell');
            uiresume(handles.figure1);
            
            go = 0;
    end
end

hold(handles.axes,'off');
guidata(hObject, handles);

% --- Executes on button press in pushbutton_combi.
function pushbutton_combi_Callback(hObject, ~, handles)
handles = keep_log(handles, '----- combi -----'); drawnow;

h = findobj(gca,'Type','line');
delete(h); drawnow;

go = 1;
n = 1;
handles = keep_log(handles, ['crude trace cell ' num2str(n)]);
hold(handles.axes,'on');
while go == 1
    h1 = imfreehand;
     set(gcf, 'WaitStatus','waiting');
    cell(n).p = h1.getPosition;
    handles.BW{n} = createMask(h1,handles.h_im);
    delete(h1);
    h2 = plot(cell(n).p(:, 1), cell(n).p(:,2), 'r.', 'LineWidth', 2, 'MarkerSize', 10);
    if ~exist('handles.bw_ent_close')
    handles = auto_method(handles, handles.im,0);
end
for c = 1 : length(cell)
    
    mask=handles.BW{c}&handles.bw_ent_close;
    
    
    imt = handles.im;
    imt(~mask) = 0;
    [B,L,N,A] = bwboundaries(mask);
    for k = 1:length(B)
        boundary = B{k};
        hp(k)=plot(boundary(:,2), boundary(:,1), 'y.', 'LineWidth', 2);
    end
    
end

   % choice = questdlg('Are you satisfied?', 'Cell Outline', 'No, redo','Yes, next cell','Yes, Im done','Other method','Yes, next cell');
    choice = questdlg('Are you satisfied?', 'Cell Outline', 'No, redo','Yes, next cell','Yes, Im done','Yes, next cell');
    switch choice
        case 'No, redo'
            delete(h2);
            for ii=1:length(hp)
                delete(hp(k))
            end
            handles = keep_log(handles, ['crude trace cell ' num2str(n)]);
        case 'Yes, next cell'
            n = n + 1;
            handles = keep_log(handles, ['crude trace cell ' num2str(n)]);
            handles = save_masks(handles, c, mask, imt);
        case 'Yes, Im done'
            handles = keep_log(handles, 'making masks...'); drawnow;
                    handles = save_masks(handles, c, mask, imt);
        hold(handles.axes,'off');
        handles = keep_log(handles, [num2str(c) ' masks saved']);
        handles = rmfield(handles, 'cell');
            go = 0;
            uiresume(handles.figure1);
            % add one more possibility later because need of changing
            % questiondlg for something else as only two or three buttons
            % accepted
%         case 'Other method'
%                     handles = keep_log(handles, 'try new method');
%         handles = rmfield(handles, 'cell');
%         h = findobj(gca,'Type','line');
%         delete(h); drawnow;
%         go=0;
            
    end
    
end


 
guidata(hObject, handles);





% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox


% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%% MY FUNCTIONS %%%%%%%%%%

function handles = all_channels(handles)
imr = handles.imo(:, :, 1);
minr = min(imr(:));
maxr = max(imr(:));
img = handles.imo(:, :, 2);
ming = min(img(:));
maxg = max(img(:));
imb = handles.imo(:, :, 3);
minb = min(imb(:));
maxb = max(imb(:));
handles.im = ((imr - minr) / (3*(maxr - minr)) + (img - ming) / (3*(maxg - ming)) + (imb - minb) / (3*(maxb - minb)));
% handles.im = imr  +img+ imb;

function handles = keep_log(handles, message)
log = get(handles.listbox, 'String');
%log{length(log)+1} = message;
log(2:length(log)+1) = log;
log{1} = message;
set(handles.listbox, 'String', log);

function handles = auto_method(handles, im,pl)
oldpointer = get(handles.figure1, 'pointer');
set(handles.figure1, 'pointer', 'watch')
drawnow;

im_ent = mat2gray(entropyfilt(im));
level = graythresh(im_ent);
bw_ent = im2bw(im_ent, level);
%bw_ent = imbinarize(im_ent, 'adaptive', 'ForegroundPolarity','dark');
%% remove small components smaller than 1000 pixels
handles.minsize
isfloat(handles.minsize)
bw_ent_open = bwareaopen(bw_ent ,handles.minsize);

%% close the mask (fill holes) using a disk of radius 10
handles.strelsize
se = strel('disk', handles.strelsize);
handles.bw_ent_close = imclose(bw_ent_open,se);
handles.cell = bwboundaries(handles.bw_ent_close);
hold(handles.axes,'on');
handles.step = zeros(1, length(handles.cell));
if pl
    for n = 1 : length(handles.cell)
        handles.step(n) = ceil(length(handles.cell{n}(:,1))/100);
        plot(handles.cell{n}(1:handles.step(n):end, 2), handles.cell{n}(1:handles.step(n):end, 1), 'y.', 'LineWidth', 2, 'MarkerSize', 10);
    end
    hold(handles.axes,'off');
end

set(handles.figure1, 'pointer', oldpointer);

function handles = auto_mask(handles)
oldpointer = get(handles.figure1, 'pointer');
set(handles.figure1, 'pointer', 'watch')
drawnow;

[L, num] = bwlabel(handles.bw_ent_close);
handles.numCells = num;
for l = 1 : handles.numCells
    mask = L == l;
    imt = handles.im;
    imt(~mask) = 0;
    
    handles = save_masks(handles, l, mask, imt);
end

set(handles.figure1, 'pointer', oldpointer);

function handles = manual_mask(handles)
oldpointer = get(handles.figure1, 'pointer');
set(handles.figure1, 'pointer', 'watch')
drawnow;


for c = 1 : length(handles.cell)
    
    imt = handles.im;
    imt(~handles.BW{c}) = 0;
    handles = save_masks(handles, c, handles.BW{c}, imt);
end

set(handles.figure1, 'pointer', oldpointer);

function handles = save_masks(handles, c, mask, imt)
oldpointer = get(handles.figure1, 'pointer');
set(handles.figure1, 'pointer', 'watch')
drawnow;
sc=handles.sc;
loc = regexp(handles.filename, '\.');
savename = handles.filename(1:loc(end) - 1);
ftemp = figure;
imshow(imt, [], 'InitialMagnification',5e4/handles.L);
set(gca,'Position',[0 0 1 1])
drawnow;
hgexport(ftemp,[handles.maskdir savename '_mask' num2str(c) '.png'],hgexport('factorystyle'),'Format','png');
close(ftemp);

save([handles.maskdir savename '_mask' num2str(c) '.mat'],'mask','sc');

set(handles.figure1, 'pointer', oldpointer);



function strel_Callback(hObject, eventdata, handles)
% hObject    handle to strel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strel as text
%        str2double(get(hObject,'String')) returns contents of strel as a double
handles.strelsize = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function strel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mincell_Callback(hObject, eventdata, handles)
% hObject    handle to mincell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mincell as text
%        str2double(get(hObject,'String')) returns contents of mincell as a double
handles.minsize = (str2double(get(hObject,'String')));
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function mincell_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mincell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
