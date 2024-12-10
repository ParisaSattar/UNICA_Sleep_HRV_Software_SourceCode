function phase_segmented_ecg=HannleExtractingECG(all_segments)
global ECG fs 
all_segments=cell2mat(all_segments);
if isempty(all_segments)
    phase_segmented_ecg=[];
    return;
else
    Phase_start=[];
    Phase_end=[];
    
    Phase_start=all_segments(:,1);
    Phase_end=all_segments(:,2);
    loop1=[];
    loop1=size(all_segments);
    for i=1:loop1(1)
        t=[Phase_start(i) Phase_end(i)];
        t=t*fs;
        if t(1)<=0
            t(1)=1;
        end
        if t(2)>length(ECG)
            t(end)=length(ECG);
        end
        if  t(1)==1
            phase_segmented_ecg{i,1}=ECG(t(1):t(2),1);
        else
            phase_segmented_ecg{i,1}=ECG(t(1):t(2)-1,1);
        end
        
    end
end
end
%Anno