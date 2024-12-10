function segmented_ecg= handleSegmentation(phases, ploting_segments, plot_segment_button, fs, ECG)
   global segmented_ecg 
    clear segmented_ecg
    c_list_for_segments=[];
    [col, ~]= size(phases);
    set(ploting_segments, 'string', '');
    if col == 0
        uiwait(msgbox('No Segment Available'));
        set(plot_segment_button, 'Enable', 'off');
        segmented_ecg=[];
    else
        segmented_ecg = cell(col, 1);
        c_list_for_segments = cell(1, col);
        for i = 1:col
            startEnd = phases(i, :) * fs;
            startEnd(1) = max(startEnd(1), 1);
            startEnd(2) = min(startEnd(2), length(ECG));
            segmented_ecg{i} = ECG(startEnd(1):startEnd(2)-1, 1);
            c_list_for_segments{1, i} = num2str(i);
        end
        set(ploting_segments, 'string', c_list_for_segments);
        set(plot_segment_button, 'Enable', 'on');
    end
end
