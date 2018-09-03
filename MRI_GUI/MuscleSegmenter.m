function varargout = MuscleSegmenter(varargin)
% MUSCLESEGMENTER MATLAB code for MuscleSegmenter.fig
%      MUSCLESEGMENTER, by itself, creates a new MUSCLESEGMENTER or raises the existing
%      singleton*.
%
%      H = MUSCLESEGMENTER returns the handle to a new MUSCLESEGMENTER or the handle to
%      the existing singleton*.
%
%      MUSCLESEGMENTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MUSCLESEGMENTER.M with the given input arguments.
%
%      MUSCLESEGMENTER('Property','Value',...) creates a new MUSCLESEGMENTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MuscleSegmenter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MuscleSegmenter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MuscleSegmenter

% Last Modified by GUIDE v2.5 21-Sep-2017 10:19:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MuscleSegmenter_OpeningFcn, ...
                   'gui_OutputFcn',  @MuscleSegmenter_OutputFcn, ...
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


function MuscleSegmenter_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
axes(handles.axes1);
axis off
axes(handles.axes2);
axis off
% Update handles structure
guidata(hObject, handles);


function varargout = MuscleSegmenter_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function sFrame_Callback(hObject, eventdata, handles)
val = round(get(hObject,'Value'));
set(handles.eFrame,'String',num2str(val))
show_image(handles)


function sFrame_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function pb3Dbone_Callback(hObject, eventdata, handles)
axes(handles.axes2);
cla(handles.axes2,'reset')

if get(handles.cbSmoothing,'Value')
     M1 = logical(smooth3(handles.mask_bones,'gaussian',[3 3 3],0.03));
     M1 = uint8(M1*255);
else
     M1=uint8(handles.mask_bones*255);
end
p1 = patch(isosurface(M1, 5),'FaceColor',[1 75/255 75/255],...
    'EdgeColor','none');
p2 = patch(isocaps(M1, 5),'FaceColor','interp',...
    'EdgeColor','none');
view(3)
axis tight
daspect([1,1,.4])
colormap(gray(100))
camlight left
camlight
lighting gouraud

function pb3Dleg_Callback(hObject, eventdata, handles)
axes(handles.axes2);
cla(handles.axes2,'reset')

if get(handles.cbSmoothing,'Value')
     M1 = logical(smooth3(handles.mask_legs,'gaussian',[3 3 3],0.03));
     M1 = uint8(M1*255);
else
     M1=uint8(handles.mask_legs*255);
end
p1 = patch(isosurface(M1, 5),'FaceColor',[1 75/255 75/255],...
    'EdgeColor','none');
p2 = patch(isocaps(M1, 5),'FaceColor','interp',...
    'EdgeColor','none');
view(3)
axis tight
daspect([1,1,.4])
colormap(gray(100))
camlight left
camlight
lighting gouraud


function pbNext_Callback(hObject, eventdata, handles)
axes(handles.axes2);
cla(handles.axes2,'reset')

if get(handles.cbSmoothing,'Value')
     M1 = logical(smooth3(handles.mask_muscle,'gaussian',[3 3 3],0.03));
     M1 = uint8(M1*255);
else
     M1=uint8(handles.mask_muscle*255);
end
p1 = patch(isosurface(M1, 5),'FaceColor',[1 75/255 75/255],...
    'EdgeColor','none');
p2 = patch(isocaps(M1, 5),'FaceColor','interp',...
    'EdgeColor','none');
view(3)
axis tight
daspect([1,1,.4])
colormap(gray(100))
camlight left
camlight
lighting gouraud




% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
%% load file
[handles.FileName,handles.PathName,~] = uigetfile('*.tif');
rangefile = fullfile(handles.PathName,[handles.FileName(1:end-4),'range.mat']);
if exist(rangefile,'file')==2
    load(rangefile)
else
    range = [1 32];
end

for f=range(1):range(2)
     handles.I(:,:,f-range(1)+1) = double(imread([handles.PathName, '', handles.FileName],f));
end
N = size(handles.I,3);
set(handles.sFrame,'Max',N)
set(handles.sFrame,'Min',1)
set(handles.sFrame,'Value',1)

%% segment muscle
V = zeros(480,480,N);
handles.mask_legs = zeros(480,480,N);
handles.mask_muscle = zeros(480,480,N);
handles.mask_bones = zeros(480,480,N);

h = waitbar(0,'Please wait...');
for f=1:N
    handles.mask_legs(:,:,f) = find2circles(handles.I(:,:,f),7000,100000);
    handles.mask_legs(:,:,f) = imerode(handles.mask_legs(:,:,f),strel('disk',3));
    tmp = 255-handles.I(:,:,f).*handles.mask_legs(:,:,f);
    handles.mask_bones(:,:,f) = find2circles(tmp,100,7000);
    thr = multithresh(handles.I(:,:,f),2);
    V(:,:,f) = (handles.I(:,:,f)>thr(1)-12 & handles.I(:,:,f)<thr(2)).*...
        handles.mask_legs(:,:,f).*~handles.mask_bones(:,:,f);
    V(:,:,f) = imopen(V(:,:,f),strel('square',2));
    waitbar(f/N);
end
handles.mask_muscle = bwareaopen(V,300,4);

%% if segmentation exists
maskfile = fullfile(handles.PathName,[handles.FileName(1:end-4),'.mat']);
if exist(maskfile,'file')==2
    load(maskfile)
    if size(BW,3)==N
        handles.mask_muscle = BW;
    else
        handles.mask_muscle = BW(:,:,range(1):range(2));
    end
end
handles.backupCounter = 1;
handles.backup{1} = handles.mask_muscle;
close(h)





guidata(hObject, handles);
show_image(handles)


function bpAdd_Callback(hObject, eventdata, handles)
currentFrame = round(get(handles.sFrame,'Value'));
h = imfreehand(handles.axes1);
axes(handles.axes1);
h_im = imshow(handles.I(:,:,currentFrame));
BW = createMask(h,h_im);
handles.mask_muscle(:,:,currentFrame) = handles.mask_muscle(:,:,currentFrame) | BW;

handles.backup{handles.backupCounter+1} = handles.mask_muscle;
handles.backupCounter = handles.backupCounter+1;
guidata(hObject, handles);
show_image(handles)


function pbDelete_Callback(hObject, eventdata, handles)
currentFrame = round(get(handles.sFrame,'Value'));
axes(handles.axes1);
[x,y] = getpts(handles.axes1);
%[x,y] = ginput(1);
BW = bwselect(handles.mask_muscle(:,:,currentFrame),x,y,8);
handles.mask_muscle(:,:,currentFrame) = handles.mask_muscle(:,:,currentFrame) & ~BW;

handles.backup{handles.backupCounter+1} = handles.mask_muscle;
handles.backupCounter = handles.backupCounter+1;
guidata(hObject, handles);
show_image(handles)


function pbLine_Callback(hObject, eventdata, handles)
currentFrame = round(get(handles.sFrame,'Value'));
h = imline(handles.axes1);
axes(handles.axes1);
h_im = imshow(handles.I(:,:,currentFrame));
BW = createMask(h,h_im);
handles.mask_muscle(:,:,currentFrame) = handles.mask_muscle(:,:,currentFrame) &...
    ~bwmorph(BW,'dilate');


handles.backup{handles.backupCounter+1} = handles.mask_muscle;
handles.backupCounter = handles.backupCounter+1;
guidata(hObject, handles);
show_image(handles)


function pbSave_Callback(hObject, eventdata, handles)
BW = handles.mask_muscle;
save([handles.PathName, handles.FileName(1:end-4),'.mat'],'BW');
msgbox('Done saving')


function cbSmoothing_Callback(hObject, eventdata, handles)


function pbUndo_Callback(hObject, eventdata, handles)
handles.mask_muscle = handles.backup{max(1,handles.backupCounter-1)};
handles.backupCounter = max(1,handles.backupCounter-1);
guidata(hObject, handles);
show_image(handles)


function pbEraserBox_Callback(hObject, eventdata, handles)
axes(handles.axes1);
rect = getrect(handles.axes1);
rect = round(rect);
currentFrame = round(get(handles.sFrame,'Value'));
handles.mask_muscle(rect(2):rect(2)+rect(4)-1,rect(1):rect(1)+rect(3)-1,currentFrame) = true;
 
handles.backup{handles.backupCounter+1} = handles.mask_muscle;
handles.backupCounter = handles.backupCounter+1;
guidata(hObject, handles);
show_image(handles)


function pbDeleteStack_Callback(hObject, eventdata, handles)
currentFrame = round(get(handles.sFrame,'Value'));
axes(handles.axes1);
[x,y] = getpts(handles.axes1);
BW = bwselect(handles.mask_muscle(:,:,currentFrame),x,y,8);
handles.mask_muscle(:,:,currentFrame) = handles.mask_muscle(:,:,currentFrame) & ~BW;

while currentFrame>1
   currentFrame = currentFrame-1;
   tmp = BW & handles.mask_muscle(:,:,currentFrame);
   [y,x] = find(tmp,1,'first');
   BW = bwselect(handles.mask_muscle(:,:,currentFrame),x,y,8);
   handles.mask_muscle(:,:,currentFrame) = handles.mask_muscle(:,:,currentFrame) & ~BW;
end

handles.backup{handles.backupCounter+1} = handles.mask_muscle;
handles.backupCounter = handles.backupCounter+1;
guidata(hObject, handles);
show_image(handles)



function eFrame_Callback(hObject, eventdata, handles)
val = round(str2double(get(hObject,'String')));
val = min(get(handles.sFrame,'Max'),val);
val = max(get(handles.sFrame,'Min'),val);
set(handles.sFrame,'Value',val)
set(hObject,'String',num2str(val))

show_image(handles)

function eFrame_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pbExclude_Callback(hObject, eventdata, handles)
currentFrame = round(get(handles.sFrame,'Value'));
h = imfreehand(handles.axes1);
axes(handles.axes1);
h_im = imshow(handles.I(:,:,currentFrame));
BW = createMask(h,h_im);
handles.mask_muscle(:,:,currentFrame) = handles.mask_muscle(:,:,currentFrame) & ~BW;

handles.backup{handles.backupCounter+1} = handles.mask_muscle;
handles.backupCounter = handles.backupCounter+1;
guidata(hObject, handles);
show_image(handles)

function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
if eventdata.Key=='u'
    handles.mask_muscle = handles.backup{max(1,handles.backupCounter-1)};
    handles.backupCounter = max(1,handles.backupCounter-1);
    guidata(hObject, handles);
    show_image(handles)
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function show_image(handles)
val = round(get(handles.sFrame,'Value'));
axes(handles.axes1);
imshow(handles.I(:,:,val),[])
hold on
[B,~] = bwboundaries(handles.mask_legs(:,:,val),'noholes');
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
end
% [B,~] = bwboundaries(handles.mask_bones(:,:,val),'noholes');
% for k = 1:length(B)
%    boundary = B{k};
%    plot(boundary(:,2), boundary(:,1), 'Color',[0.5 0.5 0], 'LineWidth', 1)
% end

[B,~] = bwboundaries(handles.mask_muscle(:,:,val));
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 1)
end
%% volume computation - muscle
volume = sum(sum(handles.mask_muscle),3);
ind = find(volume(200:end)==0,1,'first');
volume = [sum(volume(1:199+ind))*0.09375*0.09375*0.5,...
    sum(volume(199+ind:end))*0.09375*0.09375*0.5];
set(handles.tVolume,'String',num2str(volume))
%% volume computation - bones
volume = sum(sum(handles.mask_bones),3);
ind = find(volume(200:end)==0,1,'first');
volume = [sum(volume(1:199+ind))*0.09375*0.09375*0.5,...
    sum(volume(199+ind:end))*0.09375*0.09375*0.5];
set(handles.tBoneVolume,'String',num2str(volume))
%% volume computation - legs
volume = sum(sum(handles.mask_legs),3);
[~,ind] = min(volume(191:290));
volume = [sum(volume(1:190+ind))*0.09375*0.09375*0.5,...
    sum(volume(190+ind:end))*0.09375*0.09375*0.5];
set(handles.tLegVolume,'String',num2str(volume))



function BW = find2circles(I,minArea,maxArea)
% I - image (assumption: circle is bright)
% minArea,maxArea - min and max number of pixels inside each circle
t = 254;
while t>1
    BW = I>t;
    BW = bwareaopen(BW,minArea);
    BW = BW & ~bwareaopen(BW,maxArea);
    BW = imfill(BW,'holes');
    props = regionprops(BW,'Area','Perimeter');
    val1 = numel(props);
    if val1==2
        A = [props.Area];
        P = [props.Perimeter].^2;
        [~,ind] = max(A);
        val2 = A(ind)/P(ind)*4*pi;
        A(ind)=[];
        P(ind)=[];
        [~,ind] = max(A);
        val3 = A(ind)/P(ind)*4*pi;
        if val2>0.6 && val3>0.6
            
            break
        end
        
    end
    t = t-1;
    
end
