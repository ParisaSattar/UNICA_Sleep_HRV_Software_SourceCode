function handleBatchRun()
global popupFig hypno_format hypnoProp_fig fig_sleepstage caseName fs
global wakePhases N1Phases N2Phases N3Phases REMPhases ECG EDF_Info ECG_Type
global ECG_Info Setting_fig fs_fig Fs_New Main ECG SubjectName ECG_format ECG_Row_Num_fig
%This code ensures that the sub windows open on the same screen
% Get the position of the figure in pixel coordinates
figPosition = get(Main, 'Position');

% Get the screen size
screensize = get(0, 'MonitorPositions');

% Determine on which screen the figure is located
screen_number = 1;
for k = 1:size(screensize, 1)
    if screensize(k, 1) <= figPosition(1) && screensize(k, 1) + screensize(k, 3) >= figPosition(1) && ...
            screensize(k, 2) <= figPosition(2) && screensize(k, 2) + screensize(k, 4) >= figPosition(2)
        screen_number = k;
        break;
    end
end
% Get the position of the selected screen
selectedScreen = screensize(screen_number, :);

[Hypno_files, pathname_Hypno] = uigetfile({'*.xlsx;*.csv;*.txt'},...
    'Select Hypnogram File/Files','MultiSelect', 'on');
if iscell(Hypno_files)
    if isempty(Hypno_files)
        uiwait(msgbox('No hypnogram file selected'))
        return;
    end
else
    if Hypno_files==0
        uiwait(msgbox('No hypnogram file selected'))
        return;
    end
end

if ischar(Hypno_files)
    Hypno_files=cellstr(Hypno_files);
end

Rows_Hy=length(Hypno_files);
wake_final=cell(Rows_Hy, 1);N1_final=cell(Rows_Hy, 1);
N2_final=cell(Rows_Hy, 1);N3_final=cell(Rows_Hy, 1);
REM_final=cell(Rows_Hy, 1);
Hyp_name=cell(Rows_Hy, 1);
idx_Record_on= [];
idx_duration=[];
idx_Phase_Label=[];
for Hy=1:length(Hypno_files)
    % Construct full file paths
    Hypno_filenames = fullfile(pathname_Hypno, Hypno_files{Hy});

    %Hypno_filenames=strcat(pathname_Hypno,Hypno_files(Hy));
    %ECG_filename=strcat(pathname_ECG,ECG_files{Hy});
    % Check the file extension to determine the reading function
    [~, ~, ext] = fileparts(Hypno_filenames);
    if Hy==1
        figWidth = 600;
        figHeight = 190;
        figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
        figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
        hypno_format= uifigure('Name', 'Hypnogram File Formate and Structure', ...
            'Position', [figX, figY, figWidth, figHeight]);
        uicontrol('Parent', hypno_format, 'style', 'text', ...
            'string', 'Select Yes if all hypnogram files have same formate and structure', ...
            'units', 'normalized', 'FontSize', 11, ...
            'position', [0.078 0.74 0.8 0.12]);
        Hypno_Type = uicontrol('Parent',hypno_format,'style', 'popupmenu',...
            'string',{'No','Yes'},...
            'units', 'normalized','FontSize', 10,...
            'position', [0.35 0.48 0.25 0.15]);
        figdel=1;
        uicontrol('Parent',hypno_format, 'style',...
            'pushbutton','Position', [210 40 150 30], 'String', 'OK','Callback', @selectionMade);
        uiwait(hypno_format);
    end
    if ismember(ext, {'.xlsx', '.xls','.csv','.txt'})
        data_segment = readtable(Hypno_filenames);
        % Calculate the percentage of NaN values in each column
        nanPercentage = sum(ismissing(data_segment)) / height(data_segment);
        % Identify columns with more than 90% NaN values
        nanColumns = nanPercentage > 0.70;
        % Remove columns with more than 90% NaN values
        data_segment(:, nanColumns) = [];
        % Remove rows that contain any NaN values
        data_segment(any(ismissing(data_segment), 2), :) = [];
    else
        uiwait(msgbox('Unsupported file type'));
        return;
    end
    if Hypno_Type.Value==1
        idx_Record_on= [];
        idx_duration=[];
        idx_Phase_Label=[];
        %Display Content so user can select row number of labels
        figWidth = 600;
        figHeight = 400;
        figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
        figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
        popupFig = figure('Position', [figX, figY, figWidth, figHeight], ... % Adjust size and position as needed
            'Name', 'File Content', 'NumberTitle', 'off','MenuBar', 'none', ...
            'ToolBar', 'none','Resize', 'on');
        numCols = width(data_segment);
        newNames = arrayfun(@(x) sprintf('column %d', x), 1:numCols, 'UniformOutput', false);

        % Assign new names to the table
        data_segment .Properties.VariableNames = newNames;
        dispdata=data_segment(1:5,:);
        % Get the table in string form.
        TString = evalc('disp(dispdata)');
        % Use TeX Markup for bold formatting and underscores.
        TString = strrep(TString,'<strong>','\bf');
        TString = strrep(TString,'</strong>','\rm');
        TString = strrep(TString,'_','\_');
        % Get a fixed-width font.
        FixedWidth = get(0,'FixedWidthFontName');
        % Output the table using the annotation command.
        annotation(popupFig,'Textbox','String',TString,'Interpreter','Tex',...
            'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
        set(popupFig, 'WindowState', 'maximized');

        figWidth = 600;
        figHeight = 190;
        figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
        figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
        hypnoProp_fig= uifigure('Name', 'Select Hypnogram Properties', ...
            'Position', [figX, figY, figWidth, figHeight]);
        uicontrol('Parent', hypnoProp_fig, 'style', 'text', ...
            'string', 'Sleep Epoch Format', ...
            'units', 'normalized', 'FontSize', 11, ...
            'position', [0.078 0.74 0.25 0.12]);
        Phasetime_format = uicontrol('Parent',hypnoProp_fig,'style', 'popupmenu',...
            'string',{'Duration','End Time','30 Sec Epochs'} ,...
            'units', 'normalized','FontSize', 10,...
            'position', [0.08 0.552 0.25 0.15],'Callback', @setUnitDuration);
        uicontrol('Parent',hypnoProp_fig,'style', 'text',...
            'string',' Start Time Unit',...
            'units', 'normalized','FontSize', 11,...
            'position', [0.4 0.74 0.19 0.12]);
        Unit_Record_on = uicontrol('Parent',hypnoProp_fig,'style', 'popupmenu',...
            'string',{'Microsecond (μs)','Millisecond (ms)','Second (s)','HH:MM:SS'} ,...
            'units', 'normalized','FontSize', 10,...
            'position', [0.38 0.55 0.25 0.15]);
        uicontrol('Parent',hypnoProp_fig,'style', 'text',...
            'string',' End Time Unit',...
            'units', 'normalized','FontSize', 11,...
            'position', [0.695 0.74 0.19 0.12]);
        Unit_Duration = uicontrol('Parent',hypnoProp_fig,'style', 'popupmenu',...
            'string',{'Microsecond (μs)','Millisecond (ms)','Second (s)','HH:MM:SS'} ,...
            'units', 'normalized','FontSize', 10,...
            'position', [0.68 0.55 0.25 0.15]);
        figdel=2;
        uicontrol('Parent',hypnoProp_fig, 'style',...
            'pushbutton','Position', [230 40 150 30], 'String', 'OK','Callback', @selectionMade);
        uiwait(hypnoProp_fig);
        hypno_label=data_segment.Properties.VariableNames;
        figWidth = 600;
        figHeight = 300;
        figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
        figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
        Hypno_Columns = figure('Name', 'Select Labels', ...
            'Position', [figX, figY, figWidth, figHeight], ...
            'MenuBar', 'none','NumberTitle', 'off', ...
            'ToolBar', 'none');
        if Phasetime_format.Value==3
            uicontrol('parent', Hypno_Columns, 'Style', ...
                'text','string','Select Respective Column', 'FontSize', 13,...
                'Units', 'normalized', ...
                'Position', [0.3, 0.82, 0.4, 0.1]);
            uicontrol('parent', Hypno_Columns, 'Style', ...
                'text','string','Start Time', 'FontSize', 10,...
                'Units', 'normalized', ...
                'Position', [0.2, 0.7, 0.2, 0.1]);
            listbox_ST = uicontrol('Style', 'listbox', ...
                'Units', 'normalized', ...
                'Position', [0.2, 0.22, 0.22, 0.5], ...
                'String', hypno_label);
            uicontrol('parent', Hypno_Columns, 'Style', ...
                'text','string','Phase Labels', 'FontSize', 10,...
                'Units', 'normalized', ...
                'Position', [0.58, 0.7, 0.2, 0.1]);
            listbox_PL = uicontrol('Style', 'listbox', ...
                'Units', 'normalized', ...
                'Position', [0.58, 0.22, 0.22, 0.5], ...
                'String', hypno_label);
            figdel=3;
            uicontrol('Parent',Hypno_Columns, 'style',...
                'pushbutton','Position', [225 20 150 30], 'String', 'OK','Callback', @selectionMade);
            uiwait(Hypno_Columns);
            idx_Record_on= listbox_ST.Value;
            idx_Phase_Label=listbox_PL.Value;
        else
            uicontrol('parent', Hypno_Columns, 'Style', ...
                'text','string','Select Respective Column', 'FontSize', 13,...
                'Units', 'normalized', ...
                'Position', [0.3, 0.82, 0.4, 0.1]);
            uicontrol('parent', Hypno_Columns, 'Style', ...
                'text','string','Start Time', 'FontSize', 10,...
                'Units', 'normalized', ...
                'Position', [0.1, 0.7, 0.2, 0.1]);
            listbox_ST = uicontrol('Style', 'listbox', ...
                'Units', 'normalized', ...
                'Position', [0.1, 0.22, 0.22, 0.5], ...
                'String', hypno_label);
            uicontrol('parent', Hypno_Columns, 'Style', ...
                'text','string','Stop Time', 'FontSize', 10,...
                'Units', 'normalized', ...
                'Position', [0.385, 0.7, 0.2, 0.1]);
            listbox_ET = uicontrol('Style', 'listbox', ...
                'Units', 'normalized', ...
                'Position', [0.39, 0.22, 0.22, 0.5], ...
                'String', hypno_label);
            uicontrol('parent', Hypno_Columns, 'Style', ...
                'text','string','Phase Labels', 'FontSize', 10,...
                'Units', 'normalized', ...
                'Position', [0.68, 0.7, 0.2, 0.1]);
            listbox_PL = uicontrol('Style', 'listbox', ...
                'Units', 'normalized', ...
                'Position', [0.68, 0.22, 0.22, 0.5], ...
                'String', hypno_label);
            figdel=3;
            uicontrol('Parent',Hypno_Columns, 'style',...
                'pushbutton','Position', [225 20 150 30], 'String', 'OK','Callback', @selectionMade);
            uiwait(Hypno_Columns);
            idx_Record_on= listbox_ST.Value;
            idx_duration=listbox_ET.Value;
            idx_Phase_Label=listbox_PL.Value;
        end
        sleepstage_final=[];
        sleepstage_final=table2array(data_segment(:,idx_Phase_Label));
        sleepstage_options=unique(sleepstage_final);
    end
    if Hypno_Type.Value==2
        if Hy==1
            %Display Content so user can select row number of labels
            figWidth = 600;
            figHeight = 400;
            figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
            figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
            popupFig = figure('Position', [figX, figY, figWidth, figHeight], ... % Adjust size and position as needed
                'Name', 'File Content', 'NumberTitle', 'off','MenuBar', 'none', ...
                'ToolBar', 'none','Resize', 'on');
            numCols = width(data_segment);
            newNames = arrayfun(@(x) sprintf('column %d', x), 1:numCols, 'UniformOutput', false);

            % Assign new names to the table
            data_segment .Properties.VariableNames = newNames;
            dispdata=data_segment(1:5,:);
            % Get the table in string form.
            TString = evalc('disp(dispdata)');
            % Use TeX Markup for bold formatting and underscores.
            TString = strrep(TString,'<strong>','\bf');
            TString = strrep(TString,'</strong>','\rm');
            TString = strrep(TString,'_','\_');
            % Get a fixed-width font.
            FixedWidth = get(0,'FixedWidthFontName');
            % Output the table using the annotation command.
            annotation(popupFig,'Textbox','String',TString,'Interpreter','Tex',...
                'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
            set(popupFig, 'WindowState', 'maximized');

            figWidth = 600;
            figHeight = 190;
            figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
            figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
            hypnoProp_fig= uifigure('Name', 'Select Hypnogram Properties', ...
                'Position', [figX, figY, figWidth, figHeight]);
            uicontrol('Parent', hypnoProp_fig, 'style', 'text', ...
                'string', 'Sleep Epoch Format', ...
                'units', 'normalized', 'FontSize', 11, ...
                'position', [0.078 0.74 0.25 0.12]);
            Phasetime_format = uicontrol('Parent',hypnoProp_fig,'style', 'popupmenu',...
                'string',{'Duration','End Time','30 Sec Epochs'} ,...
                'units', 'normalized','FontSize', 10,...
                'position', [0.08 0.552 0.25 0.15],'Callback', @setUnitDuration);
            uicontrol('Parent',hypnoProp_fig,'style', 'text',...
                'string',' Start Time Unit',...
                'units', 'normalized','FontSize', 11,...
                'position', [0.4 0.74 0.19 0.12]);
            Unit_Record_on = uicontrol('Parent',hypnoProp_fig,'style', 'popupmenu',...
                'string',{'Microsecond (μs)','Millisecond (ms)','Second (s)','HH:MM:SS'} ,...
                'units', 'normalized','FontSize', 10,...
                'position', [0.38 0.55 0.25 0.15]);
            uicontrol('Parent',hypnoProp_fig,'style', 'text',...
                'string',' End Time Unit',...
                'units', 'normalized','FontSize', 11,...
                'position', [0.695 0.74 0.19 0.12]);
            Unit_Duration = uicontrol('Parent',hypnoProp_fig,'style', 'popupmenu',...
                'string',{'Microsecond (μs)','Millisecond (ms)','Second (s)','HH:MM:SS'} ,...
                'units', 'normalized','FontSize', 10,...
                'position', [0.68 0.55 0.25 0.15]);
            figdel=2;
            uicontrol('Parent',hypnoProp_fig, 'style',...
                'pushbutton','Position', [230 40 150 30], 'String', 'OK','Callback', @selectionMade);
            uiwait(hypnoProp_fig);
            hypno_label=data_segment.Properties.VariableNames;
            figWidth = 600;
            figHeight = 300;
            figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
            figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
            Hypno_Columns = figure('Name', 'Select Labels', ...
                'Position', [figX, figY, figWidth, figHeight], ...
                'MenuBar', 'none','NumberTitle', 'off', ...
                'ToolBar', 'none');
            if Phasetime_format.Value==3
                uicontrol('parent', Hypno_Columns, 'Style', ...
                    'text','string','Select Respective Column', 'FontSize', 13,...
                    'Units', 'normalized', ...
                    'Position', [0.3, 0.82, 0.4, 0.1]);
                uicontrol('parent', Hypno_Columns, 'Style', ...
                    'text','string','Start Time', 'FontSize', 10,...
                    'Units', 'normalized', ...
                    'Position', [0.2, 0.7, 0.2, 0.1]);
                listbox_ST = uicontrol('Style', 'listbox', ...
                    'Units', 'normalized', ...
                    'Position', [0.2, 0.22, 0.22, 0.5], ...
                    'String', hypno_label);
                uicontrol('parent', Hypno_Columns, 'Style', ...
                    'text','string','Phase Labels', 'FontSize', 10,...
                    'Units', 'normalized', ...
                    'Position', [0.58, 0.7, 0.2, 0.1]);
                listbox_PL = uicontrol('Style', 'listbox', ...
                    'Units', 'normalized', ...
                    'Position', [0.58, 0.22, 0.22, 0.5], ...
                    'String', hypno_label);
                figdel=3;
                uicontrol('Parent',Hypno_Columns, 'style',...
                    'pushbutton','Position', [225 20 150 30], 'String', 'OK','Callback', @selectionMade);
                uiwait(Hypno_Columns);
                idx_Record_on= listbox_ST.Value;
                idx_Phase_Label=listbox_PL.Value;
            else
                uicontrol('parent', Hypno_Columns, 'Style', ...
                    'text','string','Select Respective Column', 'FontSize', 13,...
                    'Units', 'normalized', ...
                    'Position', [0.3, 0.82, 0.4, 0.1]);
                uicontrol('parent', Hypno_Columns, 'Style', ...
                    'text','string','Start Time', 'FontSize', 10,...
                    'Units', 'normalized', ...
                    'Position', [0.1, 0.7, 0.2, 0.1]);
                listbox_ST = uicontrol('Style', 'listbox', ...
                    'Units', 'normalized', ...
                    'Position', [0.1, 0.22, 0.22, 0.5], ...
                    'String', hypno_label);
                uicontrol('parent', Hypno_Columns, 'Style', ...
                    'text','string','Stop Time', 'FontSize', 10,...
                    'Units', 'normalized', ...
                    'Position', [0.385, 0.7, 0.2, 0.1]);
                listbox_ET = uicontrol('Style', 'listbox', ...
                    'Units', 'normalized', ...
                    'Position', [0.39, 0.22, 0.22, 0.5], ...
                    'String', hypno_label);
                uicontrol('parent', Hypno_Columns, 'Style', ...
                    'text','string','Phase Labels', 'FontSize', 10,...
                    'Units', 'normalized', ...
                    'Position', [0.68, 0.7, 0.2, 0.1]);
                listbox_PL = uicontrol('Style', 'listbox', ...
                    'Units', 'normalized', ...
                    'Position', [0.68, 0.22, 0.22, 0.5], ...
                    'String', hypno_label);
                figdel=3;
                uicontrol('Parent',Hypno_Columns, 'style',...
                    'pushbutton','Position', [225 20 150 30], 'String', 'OK','Callback', @selectionMade);
                uiwait(Hypno_Columns);
                idx_Record_on= listbox_ST.Value;
                idx_duration=listbox_ET.Value;
                idx_Phase_Label=listbox_PL.Value;
            end
            sleepstage_final=[];
            sleepstage_final=table2array(data_segment(:,idx_Phase_Label));
            sleepstage_options=unique(sleepstage_final);
        end
    end
    if Hy>1
        sleepstage_final=[];
        sleepstage_final=table2array(data_segment(:,idx_Phase_Label));
        sleepstage_options=unique(sleepstage_final);
    end
    if ~isempty(idx_duration)
        if Unit_Record_on.Value==4 && Unit_Duration.Value==4
                duration_tm=[];
                record_on_tm=[];
                record_off_tm=[];
                time_con1=data_segment(:,idx_Record_on);
                time_con2=data_segment(:,idx_duration);
                for i=1:height(time_con1)
                    timeback{i,1}=datestr(time_con1{i,1}, 'HH:MM:SS');
                    timeback1{i,1}=datestr(time_con2{i,1}, 'HH:MM:SS');
                end
                time_con1=duration(timeback, 'InputFormat', 'hh:mm:ss');
                time_con2=duration(timeback1, 'InputFormat', 'hh:mm:ss');
                j=1;
                idx_bal1=1;
                idx_bal2=1;
                condi_str_hyp = false;
                condi_stop_hyp = false;
                for i =1: height(time_con1)
                    if ~condi_str_hyp
                        record_on_tm(j,1)=seconds(time_con1(i,1));
                        if time_con1(i+1,1)<time_con1(i,1)

                            condi_str_hyp = true; % Set the flag once the condition is met

                        end
                    end
                    if condi_str_hyp
                        if idx_bal1==1
                            record_on_tm(j,1)=seconds(time_con1(i,1));
                            idx_bal1=2;
                        else
                            record_on_tm(j,1)=seconds(time_con1(i,1)+hours(24));
                            if i==height(time_con1)-1
                                i=height(time_con1);
                                j=j+1;
                                record_on_tm(j,1)=seconds(time_con1(i,1)+hours(24));
                                j=j-1;
                                i=height(time_con1)-1;
                            end
                        end
                    end
                    if ~condi_str_hyp
                        record_off_tm(j,1)=seconds(time_con2(i,1));
                        if time_con2(i+1,1)<time_con2(i,1)
                            condi_str_hyp = true; % Set the flag once the condition is met
                        end
                    end
                    if condi_str_hyp
                        if idx_bal2==1;
                            record_off_tm(j,1)=seconds(time_con2(i,1));
                            idx_bal2=2;
                        else
                            record_off_tm(j,1)=seconds(time_con2(i,1)+hours(24));
                            if i==height(time_con2)-1
                                i=height(time_con2);
                                j=j+1;
                                record_off_tm(j,1)=seconds(time_con2(i,1)+hours(24));
                                j=j-1;
                                i=height(time_con2)-1;
                            end
                        end
                    end
                    j=j+1;
                end
                duration_tm =record_off_tm - record_on_tm;
                record_on_tm=0;
                for i =1:length(duration_tm)-1
                    record_on_tm(i+1,1)=record_on_tm(i)+duration_tm(i);
                end      
        else
            duration_tm=[];
            record_on_tm=[];
            record_off_tm=[];
            record_on_tm=table2array(data_segment(:,idx_Record_on));
            duration_tm=table2array(data_segment(:,idx_duration));     
        end
    else
        record_on_tm=[];
        duration_tm=[];
        i=length(1: height(data_segment));
        end_value = 30 * (i - 1);
        % Create the vector starting from 0 and adding 30 to each subsequent element
        record_on_tm= table2array(data_segment(:,idx_Record_on));
        duration_tm=ones(i, 1) * 30;
    end
    if Hypno_Type.Value==1
        figWidth = 650;
        figHeight = 350;
        figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
        figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
        fig_sleepstage = uifigure('Name',...
            'Sleep Phases Labels', 'Position', [figX, figY, figWidth, figHeight]);
        Instruction_label_txt = uicontrol('Parent',fig_sleepstage,'style', 'text',...
            'string',['Please select the correct' ...
            ' lable for each sleep stage all the other labels' ...
            ' will be considered as none. Note: Use Control' ...
            ' button to select multiple labels'],...
            'units', 'normalized','FontSize', 10,...
            'position', [0.05 0.8 0.8 0.15]);
        wake_label_txt = uicontrol('Parent',fig_sleepstage,'style', 'text',...
            'string','Wake',...
            'units', 'normalized','FontSize', 10,...
            'position', [0.1 0.76 0.15 0.05]);
        wake_label = uicontrol('Parent',fig_sleepstage,'style', 'listbox',...
            'string', sleepstage_options, 'Max', 2, 'Min', 0,...
            'units', 'normalized','FontSize', 8,...
            'position', [0.11 0.24 0.13 0.5]);
        N1_label_txt = uicontrol('Parent',fig_sleepstage,'style', 'text',...
            'string','N1',...
            'units', 'normalized','FontSize', 10,...
            'position', [0.25 0.76 0.15 0.05]);
        N1_label = uicontrol('Parent',fig_sleepstage,'style', 'listbox',...
            'string', sleepstage_options, 'Max', 2, 'Min', 0,...
            'units', 'normalized','FontSize', 8,...
            'position', [0.26 0.24 0.13 0.5]);
        N2_label_txt = uicontrol('Parent',fig_sleepstage,'style', 'text',...
            'string','N2',...
            'units', 'normalized','FontSize', 10,...
            'position', [0.4  0.76 0.15 0.05]);
        N2_label= uicontrol('Parent',fig_sleepstage,'style', 'listbox',...
            'string', sleepstage_options, 'Max', 2, 'Min', 0,...
            'units', 'normalized','FontSize', 8,...
            'position', [0.41 0.24 0.13 0.5]);
        N3_label_txt = uicontrol('Parent',fig_sleepstage,'style', 'text',...
            'string','N3',...
            'units', 'normalized','FontSize', 10,...
            'position', [0.55 0.76 0.15 0.05]);
        N3_label = uicontrol('Parent',fig_sleepstage,'style', 'listbox',...
            'string', sleepstage_options, 'Max', 2, 'Min', 0,...
            'units', 'normalized','FontSize', 8,...
            'position', [0.56 0.24 0.13 0.5]);
        REM_label_txt = uicontrol('Parent',fig_sleepstage,'style', 'text',...
            'string','REM:',...
            'units', 'normalized','FontSize', 10,...
            'position', [0.7  0.76 0.15 0.05]);
        REM_label = uicontrol('Parent',fig_sleepstage,'style', 'listbox',...
            'string', sleepstage_options, 'Max', 2, 'Min', 0,...
            'units', 'normalized','FontSize', 8,...
            'position', [0.71 0.24 0.13 0.5]);
        figdel=4;
        btn_ok1 = uicontrol('Parent',fig_sleepstage, 'style',...
            'pushbutton','Position', [220 30 200 30], ...
            'String', 'OK','Callback', @selectionMade);
        uiwait(fig_sleepstage)
    end
    if Hypno_Type.Value==2
        if Hy==1
            figWidth = 650;
            figHeight = 350;
            figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
            figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
            fig_sleepstage = uifigure('Name',...
                'Sleep Phases Labels', 'Position', [figX, figY, figWidth, figHeight]);
            Instruction_label_txt = uicontrol('Parent',fig_sleepstage,'style', 'text',...
                'string',['Please select the correct' ...
                ' lable for each sleep stage all the other labels' ...
                ' will be considered as none. Note: Use Control' ...
                ' button to select multiple labels'],...
                'units', 'normalized','FontSize', 10,...
                'position', [0.05 0.8 0.8 0.15]);
            wake_label_txt = uicontrol('Parent',fig_sleepstage,'style', 'text',...
                'string','Wake',...
                'units', 'normalized','FontSize', 10,...
                'position', [0.1 0.76 0.15 0.05]);
            wake_label = uicontrol('Parent',fig_sleepstage,'style', 'listbox',...
                'string', sleepstage_options, 'Max', 2, 'Min', 0,...
                'units', 'normalized','FontSize', 8,...
                'position', [0.11 0.24 0.13 0.5]);
            N1_label_txt = uicontrol('Parent',fig_sleepstage,'style', 'text',...
                'string','N1',...
                'units', 'normalized','FontSize', 10,...
                'position', [0.25 0.76 0.15 0.05]);
            N1_label = uicontrol('Parent',fig_sleepstage,'style', 'listbox',...
                'string', sleepstage_options, 'Max', 2, 'Min', 0,...
                'units', 'normalized','FontSize', 8,...
                'position', [0.26 0.24 0.13 0.5]);
            N2_label_txt = uicontrol('Parent',fig_sleepstage,'style', 'text',...
                'string','N2',...
                'units', 'normalized','FontSize', 10,...
                'position', [0.4  0.76 0.15 0.05]);
            N2_label= uicontrol('Parent',fig_sleepstage,'style', 'listbox',...
                'string', sleepstage_options, 'Max', 2, 'Min', 0,...
                'units', 'normalized','FontSize', 8,...
                'position', [0.41 0.24 0.13 0.5]);
            N3_label_txt = uicontrol('Parent',fig_sleepstage,'style', 'text',...
                'string','N3',...
                'units', 'normalized','FontSize', 10,...
                'position', [0.55 0.76 0.15 0.05]);
            N3_label = uicontrol('Parent',fig_sleepstage,'style', 'listbox',...
                'string', sleepstage_options, 'Max', 2, 'Min', 0,...
                'units', 'normalized','FontSize', 8,...
                'position', [0.56 0.24 0.13 0.5]);
            REM_label_txt = uicontrol('Parent',fig_sleepstage,'style', 'text',...
                'string','REM:',...
                'units', 'normalized','FontSize', 10,...
                'position', [0.7  0.76 0.15 0.05]);
            REM_label = uicontrol('Parent',fig_sleepstage,'style', 'listbox',...
                'string', sleepstage_options, 'Max', 2, 'Min', 0,...
                'units', 'normalized','FontSize', 8,...
                'position', [0.71 0.24 0.13 0.5]);
            figdel=4;
            btn_ok1 = uicontrol('Parent',fig_sleepstage, 'style',...
                'pushbutton','Position', [220 30 200 30], ...
                'String', 'OK','Callback', @selectionMade);
            uiwait(fig_sleepstage)
        end
    end
wake_name=sleepstage_options(wake_label.Value);
N1_name=sleepstage_options(N1_label.Value);
N2_name=sleepstage_options(N2_label.Value);
N3_name=sleepstage_options(N3_label.Value);
REM_name=sleepstage_options(REM_label.Value);
%Label for spleep phases wake=0, N1=1, N2=2, N3=3 and REM=4
sleepstage1 =[];
sleepstage1 = num2cell(nan(size(sleepstage_final)));
[isInWakeName, ~] = ismember(sleepstage_final, wake_name);
sleepstage1(isInWakeName) = {0};
[isInN1Name, ~] = ismember(sleepstage_final, N1_name);
sleepstage1(isInN1Name) = {1};
[isInN2Name, ~] = ismember(sleepstage_final, N2_name);
sleepstage1(isInN2Name) = {2};
[isInN3Name, ~] = ismember(sleepstage_final, N3_name);
sleepstage1(isInN3Name) = {3};
[isInREMName, ~] = ismember(sleepstage_final, REM_name);
sleepstage1(isInREMName) = {4};
    if size(sleepstage1, 1) < size(sleepstage1, 2)
        sleepstage1=sleepstage1';
    end
    for i = 1:numel(sleepstage1)
        if isempty(sleepstage1{i})
            sleepstage1{i} = NaN; % Replace empty arrays with NaN
        end
    end
sleepstage1=cell2mat(sleepstage1);
    if Unit_Record_on.Value==1
        record_on_tm=record_on_tm*0.000001;
    elseif Unit_Record_on.Value==2
        record_on_tm=record_on_tm*0.001;
    end
    if Unit_Duration.Value==1
        duration_tm=duration_tm*0.000001;
    elseif Unit_Duration.Value==2
        duration_tm=duration_tm*0.000001;
    end
Hypno_data=[];
Hypno_data=[record_on_tm, duration_tm, sleepstage1];
Hypno_data=array2table(Hypno_data);
Hypno_data.Properties.VariableNames = {'RecordingOnset', 'Duration', 'SleepStage'};
Hypno_data = rmmissing(Hypno_data);
Conv_Hypno{Hy,1}=Hypno_data;
currentStart = Hypno_data.RecordingOnset(1);
currentStage = Hypno_data.SleepStage(1);
sleepPhases = [];
    for i = 2:height(Hypno_data)
        if Hypno_data.SleepStage(i) ~= currentStage
            % End of current sleep phase, record it
            currentEnd = Hypno_data.RecordingOnset(i-1) + Hypno_data.Duration(i-1);
            sleepPhases = [sleepPhases; currentStart, currentEnd, currentStage];
            % Update start and stage for new sleep phase
            currentStart = Hypno_data.RecordingOnset(i);
            currentStage = Hypno_data.SleepStage(i);
        end
    end
    % Add the last sleep phase
    currentEnd = Hypno_data.RecordingOnset(end) + Hypno_data.Duration(end);
    sleepPhases = [sleepPhases; currentStart, currentEnd, currentStage];
    phaseType=0;
    wakePhases = handlestorePhases(sleepPhases, phaseType);
    phaseType=1;
    N1Phases= handlestorePhases(sleepPhases, phaseType);
    phaseType=2;
    N2Phases= handlestorePhases(sleepPhases, phaseType);
    phaseType=3;
    N3Phases = handlestorePhases(sleepPhases, phaseType);
    phaseType=4;
    REMPhases = handlestorePhases(sleepPhases, phaseType);
    if Hypno_Type.Value==1
    figWidth = 600;
    figHeight = 300;
    figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
    figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
    Setting_fig = figure('Name', 'Settings', 'NumberTitle', 'off',...
        'MenuBar', 'none','Position', [figX, figY, figWidth, figHeight]);
    uicontrol('Style', 'text', 'String', 'Select phase/s', 'FontSize', 9,'units', 'normalized',...
        'position', [0.045 0.85 0.2 0.1]);
    wake_all=uicontrol('Style', 'checkbox', 'String', 'Wake', 'units', 'normalized',...
        'position', [0.1 0.75 0.15 0.1]);
    N1_all=uicontrol('Style', 'checkbox', 'String', 'N1 Phase', 'units', 'normalized',...
        'position', [0.1 0.62 0.3 0.1]);
    N2_all=uicontrol('Style', 'checkbox', 'String', 'N2 Phase', 'units', 'normalized',...
        'position', [0.1 0.49 0.3 0.1]);
    N3_all=uicontrol('Style', 'checkbox', 'String', 'N3 Phase', 'units', 'normalized',...
        'position', [0.1 0.36 0.3 0.1]);
    REM_all=uicontrol('Style', 'checkbox', 'String', 'REM Phase', 'units', 'normalized',...
        'position', [0.1 0.23 0.3 0.1]);
    uicontrol('Style', 'text', 'String', 'Segment Settings', 'FontSize', 9,'units', 'normalized',...
        'position', [0.35 0.85 0.3 0.1]);
    bg = uibuttongroup('Visible', 'off', 'Position', [0.35 0.25 0.6 0.6], 'Parent', Setting_fig);
    FullLength_all=uicontrol(bg,'Style', 'radiobutton', 'String', 'Method AAE: All availabe epochs regarless of length', 'units', 'normalized',...
        'position', [0.08 0.85 0.8 0.12]);
    fivemin_all=uicontrol(bg,'Style', 'radiobutton', 'String', 'Method AEWO: All epochs >=5 min with 50% overlap', 'units', 'normalized',...
        'position', [0.08 0.55 0.85 0.12]);
    Oneseg_5min=uicontrol(bg,'Style', 'radiobutton', 'String', 'Method FEO: First five minutes epoch only', 'units', 'normalized',...
        'position', [0.08 0.25 0.85 0.12]);
    bg.Visible = 'on';
    bg.BorderType='none';
    figdel=7;
    uicontrol('Parent',Setting_fig, 'style',...
        'pushbutton','units', 'normalized',...
        'Position', [0.4 0.08 0.2 0.1], 'String', 'Analyze',...
        'Callback', @selectionMade);
    uiwait(Setting_fig);
    end
    if Hypno_Type.Value==2
        if Hy==1
    figWidth = 600;
    figHeight = 300;
    figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
    figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
    Setting_fig = figure('Name', 'Settings', 'NumberTitle', 'off',...
        'MenuBar', 'none','Position', [figX, figY, figWidth, figHeight]);
    uicontrol('Style', 'text', 'String', 'Select phase/s', 'FontSize', 9,'units', 'normalized',...
        'position', [0.045 0.85 0.2 0.1]);
    wake_all=uicontrol('Style', 'checkbox', 'String', 'Wake', 'units', 'normalized',...
        'position', [0.1 0.75 0.15 0.1]);
    N1_all=uicontrol('Style', 'checkbox', 'String', 'N1 Phase', 'units', 'normalized',...
        'position', [0.1 0.62 0.3 0.1]);
    N2_all=uicontrol('Style', 'checkbox', 'String', 'N2 Phase', 'units', 'normalized',...
        'position', [0.1 0.49 0.3 0.1]);
    N3_all=uicontrol('Style', 'checkbox', 'String', 'N3 Phase', 'units', 'normalized',...
        'position', [0.1 0.36 0.3 0.1]);
    REM_all=uicontrol('Style', 'checkbox', 'String', 'REM Phase', 'units', 'normalized',...
        'position', [0.1 0.23 0.3 0.1]);
    uicontrol('Style', 'text', 'String', 'Segment Settings', 'FontSize', 9,'units', 'normalized',...
        'position', [0.35 0.85 0.3 0.1]);
    bg = uibuttongroup('Visible', 'off', 'Position', [0.35 0.25 0.6 0.6], 'Parent', Setting_fig);
    FullLength_all=uicontrol(bg,'Style', 'radiobutton', 'String', 'All segments regarless of length', 'units', 'normalized',...
        'position', [0.08 0.85 0.8 0.12]);
    fivemin_all=uicontrol(bg,'Style', 'radiobutton', 'String', 'All segments >=5 min with 50% overlap', 'units', 'normalized',...
        'position', [0.08 0.55 0.85 0.12]);
    Oneseg_5min=uicontrol(bg,'Style', 'radiobutton', 'String', 'First segment of 5 min ', 'units', 'normalized',...
        'position', [0.08 0.25 0.85 0.12]);
    bg.Visible = 'on';
    bg.BorderType='none';
    figdel=7;
    uicontrol('Parent',Setting_fig, 'style',...
        'pushbutton','units', 'normalized',...
        'Position', [0.4 0.08 0.2 0.1], 'String', 'Analyze',...
        'Callback', @selectionMade);
    uiwait(Setting_fig);
        end
    end

    if wake_all.Value==1
        Phase_Name='wake';
        wake_final{Hy,1}=handleAutoprocess_Hypno(wakePhases,Phase_Name,FullLength_all,fivemin_all,Oneseg_5min);
    end
    if N1_all.Value==1
        Phase_Name='N1';   
        N1_final{Hy,1}=handleAutoprocess_Hypno(N1Phases,Phase_Name,FullLength_all,fivemin_all,Oneseg_5min);
    end
    if N2_all.Value==1
        Phase_Name='N2';
        N2_final{Hy,1}=handleAutoprocess_Hypno(N2Phases,Phase_Name,FullLength_all,fivemin_all,Oneseg_5min);
    end
    if N3_all.Value==1
        Phase_Name='N3';
        N3_final{Hy,1}=handleAutoprocess_Hypno(N3Phases,Phase_Name,FullLength_all,fivemin_all,Oneseg_5min);
    end
    if REM_all.Value==1
        Phase_Name='REM';
        REM_final{Hy,1}=handleAutoprocess_Hypno(REMPhases,Phase_Name,FullLength_all,fivemin_all,Oneseg_5min);
    end
    Hyp_name{Hy,1}=Hypno_files{Hy};
    All_SleepPhase=[Hyp_name,wake_final, N1_final, N2_final, N3_final, REM_final];
    All_SleepPhase_header = {'Hypno_filenames','wake','N1','N2','N3','REM'};
    All_SleepPhase=[All_SleepPhase_header;All_SleepPhase];
    save('Hypnograms_Converted','All_SleepPhase','-v7.3')
end

[ECG_files,pathname_ECG] = uigetfile({'*.mat';'*.xlxs';'*.csv';'*.txt';'*.edf'},...
    'Select ECG File/Files','MultiSelect','on');
    if iscell(ECG_files)
        if isempty(ECG_files)
            uiwait(msgbox('No ECG file selected'))
            return;
        end
    else
        if ECG_files==0
            uiwait(msgbox('No ECG file selected'))
            return;
        end
    end
    if ischar(ECG_files)
        ECG_files=cellstr(ECG_files);
    end

for Batch=1:length(ECG_files) 
    while true
        ECG_filename = fullfile(pathname_ECG, ECG_files{Batch});
        [~,SubjectName,ext]=fileparts(ECG_filename);
        Hypno_files = All_SleepPhase(:, 1);
        hypno_base_names = erase(Hypno_files, {'.txt', '.xlsx', '.csv'});
        ecg_base_names = erase(ECG_files{Batch}, {'.mat', '.xlsx', '.csv', '.txt', '.edf'});
        [~, idx_Hypnp] = ismember(ecg_base_names, hypno_base_names);
        if isempty(idx_Hypnp) || idx_Hypnp == 0
            uiwait(msgbox('ECG and Hypnogram file names do not match. Please rename or choose the correct file to upload again'));
            [ECG_files,pathname_ECG] = uigetfile({'*.mat';'*.xlxs';'*.csv';'*.txt';'*.edf'},...
                'Select ECG File/Files','MultiSelect','on');
            if iscell(ECG_files)
                if isempty(ECG_files)
                    uiwait(msgbox('No ECG file selected'))
                    return;
                end
            else
                if ECG_files==0
                    uiwait(msgbox('No ECG file selected'))
                    return;
                end
            end
            if ischar(ECG_files)
                ECG_files=cellstr(ECG_files);
            end
            ECG_filename = fullfile(pathname_ECG, ECG_files{Batch});
            [~,SubjectName,ext]=fileparts(ECG_filename);
            Hypno_files = All_SleepPhase(:, 1);
            hypno_base_names = erase(Hypno_files, {'.txt', '.xlsx', '.csv'});
            ecg_base_names = erase(ECG_files{Batch}, {'.mat', '.xlsx', '.csv', '.txt', '.edf'});
            [~, idx_Hypnp] = ismember(ecg_base_names, hypno_base_names);
        else
            break;
        end
    end
% Find the indices of the matching filenames
    if Batch==1
        figWidth = 600;
        figHeight = 190;
        figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
        figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
        ECG_format= uifigure('Name', 'ECG File Formate and Structure', ...
            'Position', [figX, figY, figWidth, figHeight]);
        uicontrol('Parent', ECG_format, 'style', 'text', ...
            'string', 'Select Yes if all ECG files have same formate, structure and fs', ...
            'units', 'normalized', 'FontSize', 11, ...
            'position', [0.078 0.74 0.8 0.12]);
        ECGfor_Type = uicontrol('Parent',ECG_format,'style', 'popupmenu',...
            'string',{'No','Yes'},...
            'units', 'normalized','FontSize', 10,...
            'position', [0.35 0.48 0.25 0.15]);
        figdel=10;
        uicontrol('Parent',ECG_format, 'style',...
            'pushbutton','Position', [210 40 150 30], 'String', 'OK','Callback', @selectionMade);
        uiwait(ECG_format);
    end
    if ext==".edf"
        if ECGfor_Type.Value==2
        if Batch==1
        [hdr_ECG, data_ECG]=edfread2(ECG_filename);
        list_fields=fieldnames(hdr_ECG);
        figWidth = 600;
        figHeight = 300;
        figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
        figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
        EDF_Info = figure('Name', 'Select Data Labels', ...
            'Position', [figX, figY, figWidth, figHeight], ...
            'MenuBar', 'none','NumberTitle', 'off', ...
            'ToolBar', 'none');
            uicontrol('parent', EDF_Info, 'Style', ...
                'text','string','Select Label field', 'FontSize', 13,...
                'Units', 'normalized', ...
                'Position', [0.3, 0.82, 0.4, 0.1]);
            uicontrol('parent', EDF_Info , 'Style', ...
                'text','string','Label Field', 'FontSize', 10,...
                'Units', 'normalized', ...
                'Position', [0.2, 0.7, 0.2, 0.1]);
             uicontrol('parent', EDF_Info, 'Style', ...
                'text','string','Fs Field', 'FontSize', 10,...
                'Units', 'normalized', ...
                'Position', [0.58, 0.7, 0.2, 0.1]);
            listbox_ECG = uicontrol('Style', 'listbox', ...
                'Units', 'normalized', ...
                'Position', [0.2, 0.22, 0.22, 0.5], ...
                'String', list_fields);
            listbox_Fs = uicontrol('Style', 'listbox', ...
                'Units', 'normalized', ...
                'Position', [0.58, 0.22, 0.22, 0.5], ...
                'String', list_fields);
            figdel=5;
            uicontrol('Parent',EDF_Info, 'style',...
                'pushbutton','Position', [225 20 150 30], 'String', 'OK','Callback', @selectionMade);
            uiwait(EDF_Info);
            Num_labels= listbox_ECG.Value;
            Num_Fs= listbox_Fs.Value;
            label_info=list_fields{Num_labels};
            Labels=hdr_ECG.(label_info);
            igWidth = 600;
            figHeight = 300;
            figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
            figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
            ECG_Info = figure('Name', 'Select ECG Column', ...
                'Position', [figX, figY, figWidth, figHeight], ...
                'MenuBar', 'none','NumberTitle', 'off', ...
                'ToolBar', 'none');
            uicontrol('parent', ECG_Info, 'Style', ...
                'text','string','Select ECG field', 'FontSize', 13,...
                'Units', 'normalized', ...
                'Position', [0.3, 0.82, 0.4, 0.1]);
            listbox_Col = uicontrol('Style', 'listbox', ...
                'Units', 'normalized', ...
                'Position', [0.2, 0.22, 0.22, 0.5], ...
                'String', Labels);
            figdel=6;
            uicontrol('Parent',ECG_Info, 'style',...
                'pushbutton','Position', [225 20 150 30], 'String', 'OK','Callback', @selectionMade);
            uiwait(ECG_Info);
            selection_Col= listbox_Col.Value;
            fs_info=list_fields{Num_Fs};
            fs=hdr_ECG.(fs_info);
        end
        end
        if ECGfor_Type.Value==1
        [hdr_ECG, data_ECG]=edfread2(ECG_filename);
        list_fields=fieldnames(hdr_ECG);
        figWidth = 600;
        figHeight = 300;
        figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
        figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
        EDF_Info = figure('Name', 'Select Data Labels', ...
            'Position', [figX, figY, figWidth, figHeight], ...
            'MenuBar', 'none','NumberTitle', 'off', ...
            'ToolBar', 'none');
            uicontrol('parent', EDF_Info, 'Style', ...
                'text','string','Select Label field', 'FontSize', 13,...
                'Units', 'normalized', ...
                'Position', [0.3, 0.82, 0.4, 0.1]);
            uicontrol('parent', EDF_Info , 'Style', ...
                'text','string','Label Field', 'FontSize', 10,...
                'Units', 'normalized', ...
                'Position', [0.2, 0.7, 0.2, 0.1]);
             uicontrol('parent', EDF_Info, 'Style', ...
                'text','string','Fs Field', 'FontSize', 10,...
                'Units', 'normalized', ...
                'Position', [0.58, 0.7, 0.2, 0.1]);
            listbox_ECG = uicontrol('Style', 'listbox', ...
                'Units', 'normalized', ...
                'Position', [0.2, 0.22, 0.22, 0.5], ...
                'String', list_fields);
            listbox_Fs = uicontrol('Style', 'listbox', ...
                'Units', 'normalized', ...
                'Position', [0.58, 0.22, 0.22, 0.5], ...
                'String', list_fields);
            figdel=5;
            uicontrol('Parent',EDF_Info, 'style',...
                'pushbutton','Position', [225 20 150 30], 'String', 'OK','Callback', @selectionMade);
            uiwait(EDF_Info);
            Num_labels= listbox_ECG.Value;
            Num_Fs= listbox_Fs.Value;
            label_info=list_fields{Num_labels};
            Labels=hdr_ECG.(label_info);
            igWidth = 600;
            figHeight = 300;
            figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
            figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
            ECG_Info = figure('Name', 'Select ECG Column', ...
                'Position', [figX, figY, figWidth, figHeight], ...
                'MenuBar', 'none','NumberTitle', 'off', ...
                'ToolBar', 'none');
            uicontrol('parent', ECG_Info, 'Style', ...
                'text','string','Select ECG field', 'FontSize', 13,...
                'Units', 'normalized', ...
                'Position', [0.3, 0.82, 0.4, 0.1]);
            listbox_Col = uicontrol('Style', 'listbox', ...
                'Units', 'normalized', ...
                'Position', [0.2, 0.22, 0.22, 0.5], ...
                'String', Labels);
            figdel=6;
            uicontrol('Parent',ECG_Info, 'style',...
                'pushbutton','Position', [225 20 150 30], 'String', 'OK','Callback', @selectionMade);
            uiwait(ECG_Info);
            selection_Col= listbox_Col.Value;
            fs_info=list_fields{Num_Fs};
            fs=hdr_ECG.(fs_info);
        end         
        ECG=data_ECG(:,selection_Col);
        fs=fs(1,selection_Col);
    else
        data_ECG=load(ECG_filename);
        data_ECG=struct2cell(data_ECG);
        data_ECG=data_ECG{1};
        if ECGfor_Type.Value==2
            if Batch==1
                figWidth = 600;
                figHeight = 190;
                figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
                figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
                ECG_Row_Num_fig = figure('Name', 'ECG Channel Information', ...
                    'Position', [figX, figY, figWidth, figHeight], ...
                    'MenuBar', 'none','NumberTitle', 'off', ...
                    'ToolBar', 'none');
                uicontrol('Parent', ECG_Row_Num_fig, 'style', 'text', ...
                    'string', 'Select Type', ...
                    'units', 'normalized', 'FontSize', 11, ...
                    'position', [0.18 0.74 0.25 0.12]);
                ECG_Type =uicontrol('Parent',ECG_Row_Num_fig,'style', 'popupmenu',...
                    'string',{'Single Channel','MultiChannel'} ,...
                    'units', 'normalized','FontSize', 12,...
                    'position', [0.2 0.552 0.25 0.15],'Callback', @ECGtype);
                figdel=8;%Variable to make condition true on clicking window disapears
                uicontrol('Parent',ECG_Row_Num_fig, 'style',...
                    'pushbutton','Position', [230 40 150 30], 'String', 'OK','Callback', @selectionMade);
                uiwait(ECG_Row_Num_fig)
            end
        end
        if ECGfor_Type.Value==1
            figWidth = 600;
            figHeight = 190;
            figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
            figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
            ECG_Row_Num_fig = figure('Name', 'ECG Channel Information', ...
                'Position', [figX, figY, figWidth, figHeight], ...
                'MenuBar', 'none','NumberTitle', 'off', ...
                'ToolBar', 'none');
            uicontrol('Parent', ECG_Row_Num_fig, 'style', 'text', ...
                'string', 'Select Type', ...
                'units', 'normalized', 'FontSize', 11, ...
                'position', [0.18 0.74 0.25 0.12]);
            ECG_Type =uicontrol('Parent',ECG_Row_Num_fig,'style', 'popupmenu',...
                'string',{'Single Channel','MultiChannel'} ,...
                'units', 'normalized','FontSize', 12,...
                'position', [0.2 0.552 0.25 0.15],'Callback', @ECGtype);
            figdel=8;%Variable to make condition true on clicking window disapears
            uicontrol('Parent',ECG_Row_Num_fig, 'style',...
                'pushbutton','Position', [230 40 150 30], 'String', 'OK','Callback', @selectionMade);
            uiwait(ECG_Row_Num_fig)
        end
        if Batch>1
        data_ECG=load(ECG_filename);
        data_ECG=struct2cell(data_ECG);
        data_ECG=data_ECG{1};
        end
            if ECG_Type.Value==2
                 ECG_Row_Num=str2double(ECG_Row_Num.String);
                if isrow(data_ECG)|| iscolumn(data_ECG)
                    ECG_vect=size(data_ECG);
                    if ECG_vect(1)>ECG_vect(2)
                        ECG=data_ECG(ECG_Row_Num,:);
                    else
                        ECG=data_ECG(:,ECG_Row_Num);
                    end
                else
                    ECG_vect=size(data_ECG);
                    if ECG_vect(1)<ECG_vect(2)
                        ECG=data_ECG(ECG_Row_Num,:);
                    else
                        ECG=data_ECG(:,ECG_Row_Num);
                    end
                end

            else
                ECG=data_ECG;
            end
    end
    if ECGfor_Type.Value==1
    figWidth = 300;
    figHeight = 190;
    figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
    figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
    fs_fig = figure('Name', 'Sampling Frequency', ...
        'Position', [figX, figY, figWidth, figHeight], ...
        'MenuBar', 'none','NumberTitle', 'off', ...
        'ToolBar', 'none');
    uicontrol('Parent', fs_fig, 'style', 'text', ...
        'string', 'Enter the Sampling Frequency', ...
        'units', 'normalized', 'FontSize', 11, ...
        'position', [0.18 0.74 0.6 0.2]);
    Resample_button = uicontrol('Parent',fs_fig,'style', 'pushbutton',...
        'string', 'Resample data',...
        'units', 'normalized','Enable','off',...
        'position', [0.25 0.33 0.45 0.17], ...
        'Callback',@resamplingdata);
    Fs_New= uicontrol('parent', fs_fig, 'Style', 'edit', ...
        'Units', 'normalized', ...
        'Position', [0.35 0.55 0.25 0.15],'Callback',@onresample);
    figdel=9;
    uicontrol('Parent',fs_fig, 'style',...
        'pushbutton','units', 'normalized',...
        'position', [0.25 0.12 0.45 0.17], 'String', 'OK',...
        'Callback', @selectionMade);
    uiwait(fs_fig)
    end
    if ECGfor_Type.Value==2
    if Batch==1
    figWidth = 300;
    figHeight = 190;
    figX = selectedScreen(1) + (selectedScreen(3) - figWidth) / 2;
    figY = selectedScreen(2) + (selectedScreen(4) - figHeight) / 2;
    fs_fig = figure('Name', 'Sampling Frequency', ...
        'Position', [figX, figY, figWidth, figHeight], ...
        'MenuBar', 'none','NumberTitle', 'off', ...
        'ToolBar', 'none');
    uicontrol('Parent', fs_fig, 'style', 'text', ...
        'string', 'Enter the Sampling Frequency', ...
        'units', 'normalized', 'FontSize', 11, ...
        'position', [0.18 0.74 0.6 0.2]);
    Resample_button = uicontrol('Parent',fs_fig,'style', 'pushbutton',...
        'string', 'Resample data',...
        'units', 'normalized','Enable','off',...
        'position', [0.25 0.33 0.45 0.17], ...
        'Callback',@resamplingdata);
    Fs_New= uicontrol('parent', fs_fig, 'Style', 'edit', ...
        'Units', 'normalized', ...
        'Position', [0.35 0.55 0.25 0.15],'Callback',@onresample);
    figdel=9;
    uicontrol('Parent',fs_fig, 'style',...
        'pushbutton','units', 'normalized',...
        'position', [0.25 0.12 0.45 0.17], 'String', 'OK',...
        'Callback', @selectionMade);
    uiwait(fs_fig)
    end
    end
    ECG_Names{Batch,1} = SubjectName;
    All_ECGs{Batch,1}=ECG;
    All_fs{Batch,1}=fs;
end
for Batch=1:length(ECG_files) 
    ECG=[];
    fs=[];
    ECG_filename=[];
    SubjectName=[];
    ECG=All_ECGs{Batch,1};
    fs=All_fs{Batch,1};
    SubjectName=ECG_Names{Batch,1};
    ECG_filename = ECG_Names{Batch,1};
    Hypno_files = All_SleepPhase(:, 1);
    hypno_base_names = erase(Hypno_files, {'.txt', '.xlsx', '.csv'});
    ecg_base_names = erase(ECG_files{Batch}, {'.mat', '.xlsx', '.csv', '.txt', '.edf'});
    [~, idx_Hypnp] = ismember(ecg_base_names, hypno_base_names);
    Wake_ECGs=HandleExtractingECG(All_SleepPhase(idx_Hypnp, 2));
    N1_ECGs=HandleExtractingECG(All_SleepPhase(idx_Hypnp, 3));
    N2_ECGs=HandleExtractingECG(All_SleepPhase(idx_Hypnp, 4));
    N3_ECGs=HandleExtractingECG(All_SleepPhase(idx_Hypnp, 5));
    REM_ECGs=HandleExtractingECG(All_SleepPhase(idx_Hypnp, 6));  
    
    if wake_all.Value==1
    Phase_Name='Wake';
    phases=[];
    phases=cell2mat(All_SleepPhase(idx_Hypnp, 2));
    HandleECGRun(Wake_ECGs,Phase_Name,phases)
    end
    if N1_all.Value==1
    Phase_Name='N1';
    phases=[];
    phases=cell2mat(All_SleepPhase(idx_Hypnp, 3));
    HandleECGRun(N1_ECGs,Phase_Name,phases)
    end
    if N2_all.Value==1
    Phase_Name='N2';
    phases=[];
    phases=cell2mat(All_SleepPhase(idx_Hypnp, 4));
    HandleECGRun(N2_ECGs,Phase_Name,phases)
    end
    if N3_all.Value==1
    Phase_Name='N3';
    phases=[];
    phases=cell2mat(All_SleepPhase(idx_Hypnp, 5));
    HandleECGRun(N3_ECGs,Phase_Name,phases)
    end
    if REM_all.Value==1
    Phase_Name='REM';
    phases=[];
    phases=cell2mat(All_SleepPhase(idx_Hypnp, 6));
    HandleECGRun(REM_ECGs,Phase_Name,phases)
    end
end
msgbox(['Data saved to ' pwd], 'Success');
    %Variable to make condition true on clicking window disapears
        function resamplingdata(object, event)
        prompt = {'Enter new sampling frequency (fs):'};
        dlgtitle = 'Input';
        dims = [1 35];
        fs_actual=fs;
        definput = {num2str(fs)}; % Default value  
        fs_required = inputdlg(prompt, dlgtitle, dims, definput);%new sampling frequency
        fs_required=cell2mat(fs_required);fs_required=str2double(fs_required);
        [no_s, fac_of_rs]=rat(fs_required/fs_actual); %number of samples that need to be bhe added after each sample fpr resampling
        ECG= resample(ECG,no_s,fac_of_rs);% resampling the signal (@512)
        fs=fs_required;
        %cla(axes1)
        set(Fs_New,'String',fs);
        fs=str2double(Fs_New.String);
        end
    function ECGtype(object, event)
        if ECG_Type.Value==2
            uicontrol('Parent',ECG_Row_Num_fig,'style', 'text',...
                'string',' Select ECG Channel No',...
                'units', 'normalized','FontSize', 11,...
                'position', [0.5 0.74 0.3 0.12]);

            ECG_Row_Num= uicontrol('parent', ECG_Row_Num_fig, 'Style', 'edit', ...
                'Units', 'normalized', ...
                'Position', [0.54 0.55 0.25 0.15]);
        end
    end

    function onresample(object, event)
        set(Resample_button,'Enable','on');
        fs=str2double(Fs_New.String);
     end
    function selectionMade(object, event)
        if figdel==1
            set(hypno_format, 'Visible', 'off');

            uiresume(hypno_format)
        elseif figdel==2
            set(hypnoProp_fig, 'Visible', 'off');
            uiresume(hypnoProp_fig)
        elseif figdel==3
            set(Hypno_Columns, 'Visible', 'off');
            set(popupFig, 'Visible', 'off');
            uiresume(Hypno_Columns)
        elseif figdel==4
            set(fig_sleepstage, 'Visible', 'off');
            uiresume(fig_sleepstage)
        elseif figdel==5
            set(EDF_Info, 'Visible', 'off');
            uiresume(EDF_Info)
        elseif figdel==6
            set(ECG_Info, 'Visible', 'off');
            uiresume(ECG_Info)
        elseif figdel==7
            set(Setting_fig, 'Visible', 'off');
            uiresume(Setting_fig)
            elseif figdel==8
            set(ECG_Row_Num_fig, 'Visible', 'off');
            set(ECG_Row_Num_fig, 'Visible', 'off');
            uiresume(ECG_Row_Num_fig)
        elseif figdel==9
            Resample_button = uicontrol('Parent',fs_fig,'style', 'pushbutton',...
             'string', 'Resample data',...
             'units', 'normalized','Enable','on',...
             'position', [0.25 0.1 0.45 0.17], ...
             'Callback',@resamplingdata);
            set(fs_fig, 'Visible', 'off');
            set(fs_fig, 'Visible', 'off');
            uiresume(fs_fig)
        elseif figdel==10
            set(ECG_format, 'Visible', 'off');
            uiresume(ECG_format)
        end
    end

    function setUnitDuration(object, event)
        if Phasetime_format.Value==3 % Check if "30 Sec Epochs" is selected
            set(Unit_Duration, 'Value', 3); % Set to "Second (s)"
            set(Unit_Duration, 'Enable', 'off');
        else
            set(Unit_Duration, 'Enable', 'on'); % Enable the dropdown
            set(Unit_Record_on, 'Enable', 'on');
        end
    end

end


