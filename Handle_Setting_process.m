function Handle_Setting_process()
global FullLength_all fivemin_all Oneseg_5min Main
global wake_all N1_all N2_all N3_all REM_all SubjectName 
global wake_final N1_final N2_final N3_final REM_final
global wakePhases N1Phases N2Phases N3Phases REMPhases

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
% Create a new figure for options
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
Auto_setting=uicontrol('Style', 'pushbutton', 'String', 'Analyze', 'FontSize', 9,'units', 'normalized',...
    'position', [0.4 0.08 0.2 0.1],'Callback', @Setting_process);

    function Setting_process(object, event)
        wake_final=cell(1, 1);N1_final=cell(1, 1);
        N2_final=cell(1, 1);N3_final=cell(1, 1);
        REM_final=cell(1, 1);
        if wake_all.Value==1
            Phase_Name='wake';
            wake_final{1,1}=handleAutoprocess_Hypno(wakePhases,Phase_Name,FullLength_all,fivemin_all,Oneseg_5min);
        end
        if N1_all.Value==1
            Phase_Name='N1';
            N1_final{1,1}=handleAutoprocess_Hypno(N1Phases,Phase_Name,FullLength_all,fivemin_all,Oneseg_5min);
        end
        if N2_all.Value==1
            Phase_Name='N2';
            N2_final{1,1}=handleAutoprocess_Hypno(N2Phases,Phase_Name,FullLength_all,fivemin_all,Oneseg_5min);
        end
        if N3_all.Value==1
            Phase_Name='N3';
            N3_final{1,1}=handleAutoprocess_Hypno(N3Phases,Phase_Name,FullLength_all,fivemin_all,Oneseg_5min);
        end
        if REM_all.Value==1
            Phase_Name='REM';
            REM_final{1,1}=handleAutoprocess_Hypno(REMPhases,Phase_Name,FullLength_all,fivemin_all,Oneseg_5min);
        end
        All_SleepPhase=[wake_final, N1_final, N2_final, N3_final, REM_final];
        All_SleepPhase_header = {'wake','N1','N2','N3','REM'};
        All_SleepPhase=[All_SleepPhase_header;All_SleepPhase];
        save('Hypnograms_Converted','All_SleepPhase','-v7.3')
        Wake_ECGs=HandleExtractingECG(All_SleepPhase(2, 1));
        N1_ECGs=HandleExtractingECG(All_SleepPhase(2, 2));
        N2_ECGs=HandleExtractingECG(All_SleepPhase(2, 3));
        N3_ECGs=HandleExtractingECG(All_SleepPhase(2, 4));
        REM_ECGs=HandleExtractingECG(All_SleepPhase(2, 5));

        if wake_all.Value==1
            Phase_Name='Wake';
            phases=[];
            phases=cell2mat(All_SleepPhase(2, 1));
            HandleECGRun(Wake_ECGs,Phase_Name,phases)
        end
        if N1_all.Value==1
            Phase_Name='N1';
            phases=[];
            phases=cell2mat(All_SleepPhase(2, 2));
            HandleECGRun(N1_ECGs,Phase_Name,phases)
        end
        if N2_all.Value==1
            Phase_Name='N2';
            phases=[];
            phases=cell2mat(All_SleepPhase(2, 3));
            HandleECGRun(N2_ECGs,Phase_Name,phases)
        end
        if N3_all.Value==1
            Phase_Name='N3';
            phases=[];
            phases=cell2mat(All_SleepPhase(2, 4));
            HandleECGRun(N3_ECGs,Phase_Name,phases)
        end
        if REM_all.Value==1
            Phase_Name='REM';
            phases=[];
            phases=cell2mat(All_SleepPhase(2, 5));
            HandleECGRun(REM_ECGs,Phase_Name,phases)
        end
        msgbox(['Data saved to ' pwd], 'Success');
    end
end