%% Find2Circles
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
end
