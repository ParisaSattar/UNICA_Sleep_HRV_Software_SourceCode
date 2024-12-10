function handleImportHypno()
global popupFig hypnofig hypnoProp_fig fig_sleepstage Main sleepPhases
global wakePhases N1Phases N2Phases N3Phases REMPhases N1_from_Wake N1_from_N2 N1_from_N3
global N1_from_REM N2_from_Wake N2_from_N1 N2_from_N3 N2_from_REM N3_from_Wake N3_from_N1
global N3_from_N2 N3_from_REM REM_from_Wake REM_from_N1 REM_from_N2 REM_from_N3

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
    'Select Hypnogram File/');
    
    if isempty(Hypno_files)
        uiwait(msgbox('No hypnogram file selected'))
    end
    Hypno_filenames = fullfile(pathname_Hypno, Hypno_files);
    % Check the file extension to determine the reading function
    [~, ~, ext] = fileparts(Hypno_filenames);
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

%Display Content so user can select row number of labels
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
set(popupFig, 'WindowState', 'maximized'); % Make it read-only
            
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
        %record_on_tm= table2array(data_segment(:,idx_Record_on));
        duration_tm=ones(i, 1) * 30;
        record_on_tm=0:30:sum(duration_tm)-30;
        record_on_tm=record_on_tm';
        
    end
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
N1_from_Wake = handlePhaseTransitions(sleepPhases, 0, 1);
N1_from_N2 = handlePhaseTransitions(sleepPhases, 2, 1);
N1_from_N3 = handlePhaseTransitions(sleepPhases, 3, 1);
N1_from_REM = handlePhaseTransitions(sleepPhases, 4, 1);
N2_from_Wake = handlePhaseTransitions(sleepPhases, 0, 2);
N2_from_N1 = handlePhaseTransitions(sleepPhases, 1, 2);
N2_from_N3 = handlePhaseTransitions(sleepPhases, 3, 2);
N2_from_REM = handlePhaseTransitions(sleepPhases, 4, 2);
N3_from_Wake = handlePhaseTransitions(sleepPhases, 0, 3);
N3_from_N1 = handlePhaseTransitions(sleepPhases, 1, 3);
N3_from_N2 = handlePhaseTransitions(sleepPhases, 2, 3);
N3_from_REM = handlePhaseTransitions(sleepPhases, 4, 3);
REM_from_Wake = handlePhaseTransitions(sleepPhases, 0, 4);
REM_from_N1 = handlePhaseTransitions(sleepPhases, 1, 4);
REM_from_N2 = handlePhaseTransitions(sleepPhases, 2, 4);
REM_from_N3 = handlePhaseTransitions(sleepPhases, 3, 4);

function selectionMade(object, event)
    if figdel==2
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
    end
end
function setUnitDuration(object, event)
    if Phasetime_format.Value==3 % Check if "30 Sec Epochs" is selected
        set(Unit_Duration, 'Value', 3); % Set to "Second (s)"
        set(Unit_Duration, 'Enable', 'off'); % Lock the dropdown
    else
        set(Unit_Duration, 'Enable', 'on'); % Enable the dropdown
    end
end
end


