function all_segments=handleAutoprocess_Hypno(Phases_loc,Phase_Name,FullLength_all,fivemin_all,Oneseg_5min);
global fs  SubjectName 

%Extracting and anotating ECG segments based on the user settings
if FullLength_all.Value==1
    if isempty(Phases_loc)
        all_segments = [];
    else
    all_segments=Phases_loc(:,1:2);
    end
elseif fivemin_all.Value==1
    if isempty(Phases_loc)
        all_segments = [];
    else
    loop1=size(Phases_loc);
    for i =1:loop1(1)
        Phases_loc(i,3)=Phases_loc(i,2)-Phases_loc(i,1);
    end
    del_less=Phases_loc(:,3)<300;
    Phases_loc(del_less, :) = [];
    if isempty(Phases_loc)
        all_segments = [];
        return;
    else
        loop1=size(Phases_loc);
        duration_seg = 300; % Duration of each segment in secondsloop1
        overlap = 0.5 * duration_seg; % 50% overlap, i.e., 15 seconds
        all_segments = [];
        segments = [];
        for i =1:loop1(1)
            % Initialize segments array and starting point
            if Phases_loc(i,3)>300

                current_start = Phases_loc(i,1);
                original_end  = Phases_loc(i,2);

                % Calculate segments
                while current_start + duration_seg <= original_end + 1
                    current_end = current_start + duration_seg;
                    segments = [segments; current_start, current_end];
                    current_start = current_start + overlap;
                end
            else
                segments = [segments; Phases_loc(i,1), Phases_loc(i,2)];
            end
        end
    end
        all_segments = [all_segments; segments];
    end 
        
 
elseif Oneseg_5min.Value==1
    if isempty(Phases_loc)
        all_segments = [];
        return;
    else
    %Phases_loc=PhasePhases;
    for i =1:length(Phases_loc)
        Phases_loc(i,3)=Phases_loc(i,2)-Phases_loc(i,1);
    end
    del_less=Phases_loc(:,3)<300;
    Phases_loc(del_less, :) = [];
    if isempty(Phases_loc)
        all_segments = [];
        return;
    else
    all_segments=Phases_loc(1,1:2);
    if all_segments(2)-all_segments(1)>300
        all_segments(2)=all_segments(1)+300;
    end
    end
end
end
    

