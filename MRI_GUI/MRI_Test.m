for f=range(1):range(2)
     handles.I(:,:,f-range(1)+1) = double(imread('test.tif'));
end
N = size(handles.I,3);
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
%     waitbar(f/N);
end
handles.mask_muscle = bwareaopen(V,300,4);
BW = find2circles(tmp,100,7000);
%% Seg
maskfile = fullfile('test_range.mat');
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
%% volume computation - muscle
volume = sum(sum(handles.mask_muscle),3);
ind = find(volume(200:end)==0,1,'first');
volume_muscle = [sum(volume(1:199+ind))*0.09375*0.09375*0.5,...
    sum(volume(199+ind:end))*0.09375*0.09375*0.5];
% set(handles.tVolume,'String',num2str(volume))
%% volume computation - bones
volume = sum(sum(handles.mask_bones),3);
ind = find(volume(200:end)==0,1,'first');
volume_bones = [sum(volume(1:199+ind))*0.09375*0.09375*0.5,...
    sum(volume(199+ind:end))*0.09375*0.09375*0.5];
% set(handles.tBoneVolume,'String',num2str(volume))
%% volume computation - legs
volume = sum(sum(handles.mask_legs),3);
[~,ind] = min(volume(191:290));
volume_legs = [sum(volume(1:190+ind))*0.09375*0.09375*0.5,...
    sum(volume(190+ind:end))*0.09375*0.09375*0.5];
% set(handles.tLegVolume,'String',num2str(volume))


