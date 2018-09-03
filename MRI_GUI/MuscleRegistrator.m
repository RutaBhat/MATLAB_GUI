function varargout = MuscleRegistrator(varargin)
% MUSCLEREGISTRATOR MATLAB code for MuscleRegistrator.fig
%      MUSCLEREGISTRATOR, by itself, creates a new MUSCLEREGISTRATOR or raises the existing
%      singleton*.
%
%      H = MUSCLEREGISTRATOR returns the handle to a new MUSCLEREGISTRATOR or the handle to
%      the existing singleton*.
%
%      MUSCLEREGISTRATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MUSCLEREGISTRATOR.M with the given input arguments.
%
%      MUSCLEREGISTRATOR('Property','Value',...) creates a new MUSCLEREGISTRATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MuscleRegistrator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MuscleRegistrator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MuscleRegistrator

% Last Modified by GUIDE v2.5 04-Mar-2017 17:01:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MuscleRegistrator_OpeningFcn, ...
                   'gui_OutputFcn',  @MuscleRegistrator_OutputFcn, ...
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


% --- Executes just before MuscleRegistrator is made visible.
function MuscleRegistrator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MuscleRegistrator (see VARARGIN)

% Choose default command line output for MuscleRegistrator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MuscleRegistrator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MuscleRegistrator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function pbLoad1_Callback(hObject, eventdata, handles)
[handles.FileName1,handles.PathName1,~] = uigetfile('*.tif');
set(handles.tLoad1,'String',[handles.PathName1,handles.FileName1])
guidata(hObject, handles);


function pbLoad2_Callback(hObject, eventdata, handles)
[handles.FileName2,handles.PathName2,~] = uigetfile('*.tif');
set(handles.tLoad2,'String',[handles.PathName2,handles.FileName2])
guidata(hObject, handles);


function pbLoad3_Callback(hObject, eventdata, handles)
[handles.FileName3,handles.PathName3,~] = uigetfile('*.tif');
set(handles.tLoad3,'String',[handles.PathName3,handles.FileName3])
guidata(hObject, handles);


function pbStart_Callback(hObject, eventdata, handles)
h = waitbar(0,'Please wait...');
for f=1:100
    try
        I1(:,:,f) = double(imread([handles.PathName1, '\', handles.FileName1],f));
%         pts1left{f}  = detectBRISKFeatures(I1(:,1:240,f));
%         [features1left{f},~] = extractFeatures(I1(:,1:240,f),pts1left{f});
%         pts1right{f}  = detectBRISKFeatures(I1(:,241:end,f));
%         [features1right{f},~] = extractFeatures(I1(:,241:end,f),pts1right{f});

    end
end
waitbar(0.1);
for f=1:100
    try
        I2(:,:,f) = double(imread([handles.PathName2, '\', handles.FileName2],f));
%         pts2left{f}  = detectBRISKFeatures(I2(:,1:240,f));
%         [features2left{f},~] = extractFeatures(I2(:,1:240,f),pts2left{f});
%         pts2right{f}  = detectBRISKFeatures(I2(:,241:end,f));
%         [features2right{f},~] = extractFeatures(I2(:,241:end,f),pts2right{f});
    end
end
waitbar(0.2);
if ~isempty(get(handles.tLoad3,'String'))
    for f=1:100
        try
            I3(:,:,f) = double(imread([handles.PathName3, '\', handles.FileName3],f));
%             pts3{f}  = detectBRISKFeatures(I3(:,:,f));
%             [features3{f},~] = extractFeatures(I3(:,:,f),pts3{f}, 'Method','BRISK');
        end
    end
end
waitbar(0.3);

[optimizer, metric]  = imregconfig('monomodal');
tform = imregtform(I2,I1,'translation',optimizer,metric);
waitbar(0.7);
shift1 = floor(tform.T(4,3));
if ~isempty(get(handles.tLoad3,'String'))
   tform = imregtform(I3,I1,'translation',optimizer,metric);
   waitbar(0.9);
   shift2 = floor(tform.T(4,3));    
   range = [max([1,1+shift1,1+shift2]),min([32,32+shift1,32+shift2])];
   save([handles.PathName1, handles.FileName1(1:end-4),'range.mat'],'range');
   range = [max([1,1-shift1,1+shift2-shift1]),min([32,32-shift1,32+shift2-shift1])];
   save([handles.PathName2, handles.FileName2(1:end-4),'range.mat'],'range');
   range = [max([1,1-shift2,1-shift2+shift1]),min([32,32-shift2,32+shift1-shift2])];
   save([handles.PathName3, handles.FileName3(1:end-4),'range.mat'],'range');
else
   range = [max(1,1+shift1),min(32,32+shift1)];
   save([handles.PathName1, handles.FileName1(1:end-4),'range.mat'],'range');
   range = [max(1,1-shift1),min(32,32-shift1)];
   save([handles.PathName2, handles.FileName2(1:end-4),'range.mat'],'range');
end

close(h)

% movingRegistered = imregister(I2,I1,'rigid',optimizer, metric);
% figure
% imshowpair(I1(:,:,16), movingRegistered(:,:,16),'Scaling','joint');
% figure
% imshowpair(I1(:,:,16), I2(:,:,16),'Scaling','joint');

% numLeft = zeros(21,1);
% numRight = zeros(21,1);
% for shift=-10:10
%     for ref=11:22
%         indexPairsLeft = matchFeatures(features1left{ref},features2left{shift+ref});
%         indexPairsRight = matchFeatures(features1right{ref},features2right{shift+ref});
%         numLeft(shift+11) = numLeft(shift+11)+numel(indexPairsLeft);
%         numRight(shift+11) = numRight(shift+11)+numel(indexPairsRight);
%     end
% end
% figure
% plot(numLeft+numRight)


% Left1 = I1(:,1:240,:);
% Right1 = I1(:,241:end,:);
% Left2 = I2(:,1:240,:);
% Right2 = I2(:,241:end,:);
% 
% for shift=-10:10
%     for ref=11:22
%         C = normxcorr2(Left1(:,:,ref),Left2(:,:,ref+shift));
%         maxLeft(shift+11,ref-10) = max(C(:));
%         C = normxcorr2(Right1(:,:,ref),Right2(:,:,ref+shift));
%         maxRight(shift+11,ref-10) = max(C(:));
%     end
% end
% figure
% imagesc(maxLeft)
% colormap gray
% figure
% imagesc(maxRight)
% colormap gray
