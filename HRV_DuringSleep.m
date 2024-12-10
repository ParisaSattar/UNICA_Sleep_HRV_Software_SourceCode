function HRV_DuringSleep()
clear all
close all

%Initializing global variables
global Main save_data Setting_win
global figdel_new Rplot tab1 
global isInEditMode fs idx1 idx2 Setting_fig
global ECG Segmentation ploting_segments plot_segment_button
global caseName ECG_data control edit_boxes 
global wakePhases N1Phases N2Phases N3Phases REMPhases N1_from_Wake N1_from_N2 N1_from_N3
global N1_from_REM N2_from_Wake N2_from_N1 N2_from_N3 N2_from_REM N3_from_Wake N3_from_N1
global N3_from_N2 N3_from_REM REM_from_Wake REM_from_N1 REM_from_N2 REM_from_N3
global segmented_ecg Setting_data ECG_Filter
global segment_Number R_pos TD_Tab px1 px3 px6
global TimeDomain_Calculate Frequency_Calculate FD_Tab NA_Tab 
global AA_Tab PP_Tab Complexity_Calculate Nonlinear_Calculate Poincare_Calculate


%Creating Main Figure
Myscreen=get(groot,"ScreenSize");
Main=figure('position',Myscreen, 'Name','UNICA Sleep HRV Software v1.0','NumberTitle', 'off','MenuBar', 'none','ToolBar', 'auto');
set(Main, 'WindowState', 'maximized');


%Creating tab
tgroup = uitabgroup(Main,'Position', [0 0.753 1 0.25]);
tab1 = uitab(tgroup, 'Title', 'PROCESSING');

%Creating sub tabs on tab 1 for each domain analysis separate tabs
tgroup1 = uitabgroup(Main, 'Position', [0.57 0.11 0.4 0.615]);
TD_Tab = uitab(tgroup1, 'Title', 'Time Domain');
FD_Tab = uitab(tgroup1, 'Title', 'Frequency Domain');
NA_Tab = uitab(tgroup1, 'Title', 'Nonlinear Analysis');
AA_Tab = uitab(tgroup1, 'Title', 'Complexity Analysis');
PP_Tab = uitab(tgroup1, 'Title', 'Poincaré Plots');

%import ECG data button
import_data = uicontrol('Parent',tab1,'style', 'pushbutton',...
    'string', 'Import ECG/PSG',...
    'Units', 'normalized',...
    'position', [0.015 0.55 0.072 0.22],'Callback',@import_file);

%import Hypnogram data button
import_segment_info = uicontrol('Parent', tab1, 'style', 'pushbutton', ...
    'string', '<html><div style="text-align:center; vertical-align:middle;">Import<br>Hypnogram</div></html>', ...
    'Enable','off','Units', 'normalized', 'position', [0.09 0.55 0.072 0.22], 'Callback', @import_segments);

%Text for the tab sub sections
File_text = uicontrol('Parent',tab1,'style', 'text',...
    'string','FILES',...
    'units', 'normalized',...
    'position', [0.07 0 0.04 0.1]);
Signal_text = uicontrol('Parent',tab1,'style', 'text',...
    'string','SIGNAL',...
    'units', 'normalized',...
    'position', [0.205 0 0.04 0.1]);
Hyp_text = uicontrol('Parent',tab1,'style', 'text',...
    'string','HYPNOGRAM',...
    'units', 'normalized',...
    'position', [0.34 0 0.09 0.1]);
Time_text = uicontrol('Parent',tab1,'style', 'text',...
    'string','TIME LIMIT',...
    'units', 'normalized',...
    'position', [0.55 0 0.04 0.1]);
Sleep_text = uicontrol('Parent',tab1,'style', 'text',...
    'string','Sleep Phase:','FontSize', 10,...
    'units', 'normalized',...
    'position', [0.299 0.7 0.065 0.15]);

Sleep_text1 = uicontrol('Parent',tab1,'style', 'text',...
    'string','Phase Segment:','FontSize', 10,...
    'units', 'normalized',...
    'position', [0.288 0.45 0.1 0.15]);

Delinator_text = uicontrol('Parent',tab1,'style', 'text',...
    'string','ANALYSIS',...
    'units', 'normalized',...
    'position', [0.664 0 0.08 0.1]);

reset_text = uicontrol('Parent',tab1,'style', 'text',...
    'string','RESET GUI',...
    'units', 'normalized',...
    'position', [0.9 0 0.08 0.1]);
SaveHRV_Data_text = uicontrol('Parent',tab1,'style', 'text',...
    'string','SAVE',...
    'units', 'normalized',...
    'position', [0.78 0 0.08 0.1]);

% Space to enter Sampling frequency
Fs_text = uicontrol('Parent',tab1,'style', 'text',...
    'string','fs:','FontSize', 10,...
    'units', 'normalized',...
    'position', [0.19 0.66 0.02 0.12]);
Fs_value = uicontrol('Parent',tab1,'style', 'edit',...
    'units', 'normalized',...
    'position',[0.21 0.64 0.035 0.15], ...
    'Enable','off','Callback',@string_to_num1);
Fs_Unit_txt = uicontrol('Parent',tab1,'style', 'text',...
    'string','Hz','FontSize', 10,...
    'units', 'normalized',...
    'position', [0.245 0.66 0.02 0.12]);

%Resample button
Resample_button = uicontrol('Parent',tab1,'style', 'pushbutton',...
    'string', 'Resample data',...
    'units', 'normalized','Enable','off',...
    'position', [0.19 0.41 0.072 0.19], ...
    'Callback',@resampling_data);

%All plot Buttons
plot_button=uicontrol('Parent',tab1,'style', 'pushbutton',...
    'string', 'Plot  ECG',...
    'units', 'normalized',...
    'position', [0.19 0.18 0.072 0.19],...
    'Enable','off','Callback',@plotdata);
plot_segment_button=uicontrol('Parent',tab1,'style', 'pushbutton',...
    'string', 'Plot Phase',...
    'units', 'normalized',...
    'position', [0.295 0.2 0.07 0.19],...
    'Enable','off','Callback', @plot_segment);

clear_plot_button=uicontrol('Parent',tab1,'style', 'pushbutton',...
    'string', 'clear plot',...
    'units', 'normalized',...
    'position', [0.388 0.2 0.07 0.19],...
    'Enable','off','Callback',@clearplot);


% ECG Segmentation popup meanu
Segmentation = uicontrol('Parent',tab1,'style', 'popupmenu',...
    'string', {'Wake','N1','N2','N3','REM', ...
    'N1 From W','N1 From N2', 'N1 From N3','N1 From REM',...
    'N2 From W','N2 From N1', 'N2 From N3','N2 From REM',...
    'N3 From W','N3 From N1', 'N3 From N2','N3 From REM', ...
    'REM From W','REM From N1', 'REM From N2','REM From N3',},...
    'units', 'normalized','FontSize', 10,...
    'position', [0.39 0.83 0.07 0.05],...
    'Enable','off','Callback', @Perform_segmentation);

ploting_segments = uicontrol('Parent',tab1,'style', 'popupmenu',...
    'units', 'normalized','string',{''},'FontSize', 10,...
    'Enable','off','position', [0.39 0.56 0.07 0.07]);

% Unit popup menu
Unit = uicontrol('Parent',tab1,'style', 'popupmenu',...
    'string', {'Samples','Seconds',},...
    'units', 'normalized','FontSize', 10,...
    'position', [0.53 0.76 0.1 0.1],...
    'Enable','off');

Unit_text = uicontrol('Parent',tab1,'style', 'text',...
    'string','Unit:',...
    'units', 'normalized','FontSize', 10,...
    'position', [0.488 0.69 0.04 0.16]);

Index1_text = uicontrol('Parent',tab1,'style', 'text',...
    'string','Start:',...
    'units', 'normalized','FontSize', 10,...
    'position', [0.5 0.52 0.05 0.16]);

Index1_value = uicontrol('Parent',tab1,'style', 'edit',...
    'units', 'normalized',...
    'Enable','off','position', [0.5 0.42 0.05 0.135], 'Callback', @Select_First_index);


Index2_text = uicontrol('Parent',tab1,'style', 'text',...
    'string', 'End:',...
    'units', 'normalized','FontSize', 10,...
    'position', [0.58 0.52 0.04 0.16]);

Index2_value = uicontrol('Parent',tab1,'style', 'edit',...
    'units', 'normalized',...
    'Enable','off','position', [0.58 0.42 0.05 0.135], 'Callback', @Select_Second_index);

%Selecting desired signal for analysis button
Select_data = uicontrol('Parent',tab1,'style', 'pushbutton',...
    'string', 'Select & plot',....
    'units', 'normalized',...
    'position', [0.506 0.2 0.12 0.19],...
    'Enable','off','Callback', @extract_DOI);

%Setting button
Setting_win = uicontrol('Parent',tab1,'style', 'pushbutton',...
    'string', 'Settings',...
    'units', 'normalized',...
    'position', [0.67 0.55 0.072 0.19],...
    'Enable','off','Callback', @Setting_window);

%Rpeak detection button
Annotate_button = uicontrol('Parent',tab1,'style', 'pushbutton',...
    'string', 'Annotate ECG',...
    'units', 'normalized',...
    'position', [0.67 0.25 0.072 0.19],...
    'Enable','off','Callback', @Annotate_ECG);

% function for HRV analysis parameters
handleHRVanalysis()

%logos
axlogo = axes('Parent', Main,'Units', 'normalized', 'position', [0.88 0.01 0.11 0.09]);
axlogo.Toolbar.Visible = 'off';
axis(axlogo, 'off');
img = imread('MeDSP_LabLogo.png');
imshow(img, 'Parent', axlogo);
axlogo_unica = axes('Parent', Main,'Units', 'normalized', 'position', [0.81 0.01 0.09 0.09]);
axlogo_unica.Toolbar.Visible = 'off';
axis(axlogo_unica, 'off');
img = imread('unica_logo.png');
imshow(img, 'Parent', axlogo_unica);




% for aesthetic look code start here
ax = axes('Parent', tab1,'Units', 'normalized', 'position', [0.15 0 0.05 1]);
ax.Toolbar.Visible = 'off';
ax2 = axes('Parent', tab1,'Units', 'normalized', 'position', [0.25 0 0.05 1]);
ax2.Toolbar.Visible = 'off';
ax3 = axes('Parent', tab1,'Units', 'normalized', 'position', [0.455 0 0.05 1]);
ax3.Toolbar.Visible = 'off';
ax4 = axes('Parent', tab1,'Units', 'normalized', 'position', [0.625 0 0.05 1]);
ax4.Toolbar.Visible = 'off';
ax5 = axes('Parent', tab1,'Units', 'normalized', 'position', [0.735 0 0.05 1]);
ax5.Toolbar.Visible = 'off';
ax6 = axes('Parent', tab1,'Units', 'normalized', 'position', [0.85 0 0.05 1]);
ax6.Toolbar.Visible = 'off';
% Coordinates for the vertical line
xline = 5;
yline = [0 10];
% Draw the line
line(ax, [xline xline], yline, 'Color', [.7 .7 .7]);  % Draws a blue vertical line on tab1
line(ax2, [xline xline], yline, 'Color', [.7 .7 .7]);
line(ax3, [xline xline], yline, 'Color', [.7 .7 .7]);
line(ax4, [xline xline], yline, 'Color', [.7 .7 .7]);
line(ax5, [xline xline], yline, 'Color', [.7 .7 .7]);
line(ax6, [xline xline], yline, 'Color', [.7 .7 .7]);
yy = 5; % y-coordinate for the horizontal line
x = [0 10]; % Start and end points of the line on the x-axis
axis(ax, 'off');
%axis(ax1, 'off');
axis(ax2, 'off');
axis(ax3, 'off');
axis(ax4, 'off');
axis(ax5, 'off');
axis(ax6, 'off');
% for aesthetic look code ends here


%Creating axes for plotting ECG signal, phases and annotations%
axes1=axes('Parent',Main,'position',[0.05 0.08 0.5 0.6], 'XGrid', 'on','YGrid', 'on' );
tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});
xlabel(axes1,'Time'); 
ylabel(axes1,'ECG (mV)'); 

%Reset button of GUI
Reset_data = uicontrol('Parent',tab1,'style', 'pushbutton',...
    'string', 'Reset',...
    'units', 'normalized',...
    'position', [0.9 0.4 0.072 0.19],...
    'Callback', @Resetall);

%HRV Analysis setting button
Setting_data = uicontrol('Parent',tab1,'style', 'pushbutton',...
    'string', 'Batch Run',...
    'units', 'normalized',...
    'position', [0.015 0.22 0.1475 0.22],...
    'Callback', @Custom_process);

%Rpeak correction option
Manual_Correction_button = uicontrol('Parent',Main,'style', 'pushbutton',...
    'string', 'Manual Correction',...
    'units', 'normalized',...
    'position', [0.05 0.69 0.08 0.04],...
    'Callback', @Manual_Correction_Callback);

%Callback function 1 for Rpeak correction start here
    function Manual_Correction_Callback(hObject, eventdata)
        isInEditMode = 1; % Toggle the mode
    end

    function Rplot = plotRPeaks()
        cla(axes1)
        tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});
        if Unit.Value == 1
            ECGplot=plot(axes1,ECG_data);
            hold on
            Rplot = plot(axes1,R_pos, ECG_data(R_pos), '*');
        elseif Unit.Value == 2
            t = 0:1/fs:(length(ECG_data)/fs)-1/fs;
            ECGplot=plot(axes1,t,ECG_data);
            hold on
            Rplot = plot(axes1,t(R_pos), ECG_data(R_pos), '*');
        end
        set(Rplot, 'ButtonDownFcn', @plot_ButtonDownFcn);
        set(ECGplot, 'ButtonDownFcn', @plot_ButtonDownFcn);
    end
%Callback function 1 for Rpeak correction ends here
       
%Callback function for Resetting GUI start here
    function Resetall(object, event)
        msgFig = figure('Name', 'Reset', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'ToolBar', 'none', ...
            'Position', [550, 400, 200, 100],'CloseRequestFcn', ''); % Prevent closing until explicitly done
        uicontrol('Style', 'text', ...
            'Position', [20, 50, 160, 20],'FontSize',12, ...
            'String', 'Resetting the GUI...', ...
            'Parent', msgFig);
        close(Main);
        HRV_DuringSleep();
        set(msgFig, 'CloseRequestFcn', 'closereq')
        if ishandle(msgFig)
            close(msgFig);
        end
    end
%Callback function for Resetting GUI ends here
    
%Callback function to import ECG file start here
    function import_file(object, event)
        control=1;
        HandleImportECG()
        set(Fs_value,'string',fs);
            set(plot_button,'Enable','on');
            set(clear_plot_button,'Enable','on');
            set(Resample_button,'Enable','on');
            set(import_segment_info,'Enable','on');
            set(Fs_value,'Enable','on');
            set(Annotate_button,'Enable','on');
            set(Unit,'Enable','on');
            set(Index1_value,'Enable','on');
            set(Index2_value,'Enable','on');
            set(Select_data,'Enable','on');
            set(save_data,'Enable','on');
            if istable(ECG)
                ECG=table2array(ECG);
                ECG=cell2mat(ECG);
            end
    end
%Callback function to import ECG file ends here
    
%function for invisible images
    function selectionMade1(object, event)
        if figdel_new==7
            set(Setting_fig, 'Visible', 'off');
            uiresume(Setting_fig)
        end
    end

%     function buttonCallback(object, event)
%         % Retrieve the user input from the edit box
%         userInput = get(editBoxHandle, 'String');
%         % Now you can use userInput as needed
%         disp(['User input: ', userInput]);  % Display the input in the command window
%     end

%Callback function to import sleep segments indexes start here
    function import_segments(object, event)
        control=1;
        if isempty(Fs_value.String)
            uiwait(msgbox('Please first enter the sampling frequency in fs'))%fs is necessary for phase segmentation
        else
        handleImportHypno() 
        set(plot_segment_button,'Enable','on');
        set(Segmentation,'Enable','on');
        set(ploting_segments,'Enable','on');
        set(Annotate_button,'Enable','on');
        set(Unit,'Enable','on');
        set(Index1_value,'Enable','on');
        set(Index2_value,'Enable','on');
%         set(Point1,'Enable','on');
%         set(Point2,'Enable','on');
        set(Select_data,'Enable','on');
        set(save_data,'Enable','on');
        set(Setting_win,'Enable','on');
        end
    end
%Callback function to import sleep segments indexes start here
    
%function for batch analysis the whole signal based on user settings
    function Custom_process(object, event)
        handleBatchRun();
     end
%this function will be used to plot the sleep segments for example wake
%state have 5 ECG segments
%Thus you will see 1, 2, 3,4,5 numbers in the popup list
    function plot_segment(object, event)
        segment_Number=get(ploting_segments,'value');
        sl=length(segmented_ecg);
        if segment_Number<= sl
            ECG_data=segmented_ecg{segment_Number,1};
            if Unit.Value==1
                plot(axes1,ECG_data)
                set(axes1, 'XGrid', 'on','YGrid', 'on')
                xlabel('Samples')
                ylabel('ECG(mV)')
                tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});
            elseif Unit.Value==2
                if isempty(Fs_value.String)
                    uiwait(msgbox('Please first enter the sampling frequency in fs for plotting seconds'))
                    return;
                end
                t = 0:1/fs:length(ECG_data)/fs-1/fs;
                plot(axes1,t,ECG_data)
                set(axes1, 'XGrid', 'on','YGrid', 'on')
                xlabel(axes1,'Time (Sec)')
                ylabel(axes1,'ECG (mV)')
                tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});
            end
            tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});
        else
            uiwait(msgbox (sprintf('Only %g segments are present', sl)))
        end
        tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});
        ylabel(axes1,'ECG (mV)')
    end
 
%Callback for performing ECG segmentation phase wise
    function Perform_segmentation(object, event)
        switch Segmentation.Value
            case 1  % Wake Stage
                segmented_ecg=handleSegmentation(wakePhases, ploting_segments, plot_segment_button, fs, ECG);
            case 2  % N1 Stage
                segmented_ecg=handleSegmentation(N1Phases, ploting_segments, plot_segment_button, fs, ECG);
            case 3  % N2 Stage
                segmented_ecg=handleSegmentation(N2Phases, ploting_segments, plot_segment_button, fs, ECG);
            case 4  % N3 Stage
                segmented_ecg=handleSegmentation(N3Phases, ploting_segments, plot_segment_button, fs, ECG);
            case 5  % REM Stage
                segmented_ecg=handleSegmentation(REMPhases, ploting_segments, plot_segment_button, fs, ECG);
            case 6  % N1 from Wake
                segmented_ecg=handleSegmentation(N1_from_Wake, ploting_segments, plot_segment_button, fs, ECG);
            case 7  % N1 from N2
                segmented_ecg=handleSegmentation(N1_from_N2, ploting_segments, plot_segment_button, fs, ECG);
            case 8  % N1 from N3
                segmented_ecg=handleSegmentation(N1_from_N3, ploting_segments, plot_segment_button, fs, ECG);
            case 9  % N1 from REM
                segmented_ecg=handleSegmentation(N1_from_REM, ploting_segments, plot_segment_button, fs, ECG);
            case 10 % N2 from Wake
                segmented_ecg=handleSegmentation(N2_from_Wake, ploting_segments, plot_segment_button, fs, ECG);
            case 11 % N2 from N1
                segmented_ecg=handleSegmentation(N2_from_N1, ploting_segments, plot_segment_button, fs, ECG);
            case 12 % N2 from N3
                segmented_ecg=handleSegmentation(N2_from_N3, ploting_segments, plot_segment_button, fs, ECG);
            case 13 % N2 from REM
                segmented_ecg=handleSegmentation(N2_from_REM, ploting_segments, plot_segment_button, fs, ECG);
            case 14 % N3 from Wake
                segmented_ecg=handleSegmentation(N3_from_Wake, ploting_segments, plot_segment_button, fs, ECG);
            case 15 % N3 from N1
                segmented_ecg=handleSegmentation(N3_from_N1, ploting_segments, plot_segment_button, fs, ECG);
            case 16 % N3 from N2
                segmented_ecg=handleSegmentation(N3_from_N2, ploting_segments, plot_segment_button, fs, ECG);
            case 17 % N3 from REM
                segmented_ecg=handleSegmentation(N3_from_REM, ploting_segments, plot_segment_button, fs, ECG);
            case 18 % REM from Wake
                segmented_ecg=handleSegmentation(REM_from_Wake, ploting_segments, plot_segment_button, fs, ECG);
            case 19 % REM from N1
                segmented_ecg=handleSegmentation(REM_from_N1, ploting_segments, plot_segment_button, fs, ECG);
            case 20 % REM from N2
                segmented_ecg=handleSegmentation(REM_from_N2, ploting_segments, plot_segment_button, fs, ECG);
            case 21 % REM from N3
                segmented_ecg=handleSegmentation(REM_from_N3, ploting_segments, plot_segment_button, fs, ECG);
            otherwise
                error('Invalid segmentation value');
        end
    end
 
%Callback for loading workspace data%
    function load_ws_data(object,event)
        control=2;
        set(clear_plot_button,'Enable','on');
        set(plot_button,'Enable','on');
        vars = evalin('base','who');
        set(object,'String',vars)
    end
  
%Callback to plot ECG data%
    function plotdata(object,event)
        cla(axes1)
        if control==1||control==3
            if Unit.Value==1
                plot(axes1, ECG)
                set(axes1, 'XGrid', 'on','YGrid', 'on')
                  xlabel(axes1,'Samples');
                  ylabel(axes1,'ECG (mV)');
            elseif Unit.Value==2
                if isempty(Fs_value.String)
                    uiwait(msgbox('Please first enter the sampling frequency in fs for plotting seconds'))
                    return;
                end
                t = 0:1/fs:length(ECG)/fs-1/fs;
                plot(axes1, t,ECG)
                set(axes1, 'XGrid', 'on','YGrid', 'on')
                xlabel(axes1,'Time (Sec)'); 
                ylabel(axes1,'ECG (mV)');
            end
            
        elseif control==2
            vars = get(ws_data_list,'String');
            var_index = get(ws_data_list,'Value');
            ECG= evalin('base',vars{var_index(1)});
            if Unit.Value==1
                plot(axes1,ECG)
                set(axes1, 'XGrid', 'on','YGrid', 'on')
                xlabel(axes1,'Samples');
                ylabel(axes1,'ECG (mV)');
            elseif Unit.Value==2
                if isempty(Fs_value.String)
                    uiwait(msgbox('Please first enter the sampling frequency in fs for plotting seconds'))
                    return;
                end
                t = 0:1/fs:length(ECG)/fs-1/fs;
                plot(axes1,t, ECG)
                xlabel(axes1,'Time (Sec)');
                set(axes1, 'XGrid', 'on','YGrid', 'on')
                ylabel(axes1,'ECG (mV)');
            end

        end
       tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});
    end

%Callback to clear axes%
    function clearplot(object, event)
        hold off
        cla(axes1)
        ECG_data=[];
    end

%Callback to convert string into number%
    function string_to_num1(object,event)
        fs=str2double(get(Fs_value,'string'));
    end

%Callback to select indexes for desired segment to be analyzed start here
    function Select_First_index(object,event)
        if Unit.Value==1
                idx1=get(Index1_value, 'String');
                idx1=str2double(idx1);
        elseif Unit.Value==2
            if isempty(Fs_value.String)
                uiwait(msgbox('Please first enter the sampling frequency in fs for plotting seconds'))
                return;
            end
                idx1=get(Index1_value, 'String');
                idx1=str2double(idx1);
                if idx1==1
                    idx1=idx1;
                    set(Index1_value,'string', idx1)
                else
                    idx1=round(idx1*fs);
                    set(Index1_value,'string', round(idx1/fs))
                end
            
        end
    end

    function Select_Second_index(object,event)
        if Unit.Value==1
                idx2=get(Index2_value, 'String');
                idx2=str2double(idx2);
        elseif Unit.Value==2
            if isempty(Fs_value.String)
                uiwait(msgbox('Please first enter the sampling frequency in fs for plotting seconds'))
                return;
            end
                idx2=get(Index2_value, 'String');
                idx2=str2double(idx2);
                idx2=round(idx2*fs);
                set(Index2_value, 'String',round(idx2/fs));
        end
    end

    function extract_DOI(object, event)
        if isempty(ECG_data)
            ECG_data=ECG(idx1:idx2,1);
        else
            ECG_data=ECG_data(idx1:idx2,1);
        end
        cla(axes1)
        tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});        
        if Unit.Value==1
            plot(axes1, ECG_data)
            set(axes1, 'XGrid', 'on','YGrid', 'on') 
            tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});
            xlabel(axes1,'Samples');
            ylabel(axes1,'ECG (mV)');
        elseif Unit.Value==2
            if isempty(Fs_value.String)
                uiwait(msgbox('Please first enter the sampling frequency in fs for plotting seconds'))
                return;
            end
            t = 0:1/fs:length(ECG_data)/fs-1/fs;
            plot(axes1, t,ECG_data)
            set(axes1, 'XGrid', 'on','YGrid', 'on')
            tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});
            xlabel(axes1,'Time (Sec)');
            ylabel(axes1,'ECG (mV)');
        end
        
    end
%Callback to select indexes for desired segment to be analyzed start here

%Callback function for resampling data
    function resampling_data(object, event)
        control=3;
        prompt = {'Enter new sampling frequency (fs):'};
        dlgtitle = 'Input';
        dims = [1 35];
        definput = {num2str(fs)}; % Default value
        fs_required = inputdlg(prompt, dlgtitle, dims, definput);%new sampling frequency
        fs_required=cell2mat(fs_required);fs_required=str2double(fs_required);
        [no_s, fac_of_rs]=rat(fs_required/fs); %number of samples that need to be bhe added after each sample fpr resampling
        ECG= resample(ECG,no_s,fac_of_rs);% resampling the signal (@512)
        fs=fs_required;
        %cla(axes1)
        set(Fs_value,'string',fs);
        if Unit.Value==1
            plot(axes1, ECG)
            set(axes1, 'XGrid', 'on','YGrid', 'on')
        elseif Unit.Value==2
            if isempty(Fs_value.String)
                uiwait(msgbox('Please first enter the sampling frequency in fs for plotting seconds'))
                return;
            end
            t = 0:1/fs:length(ECG)/fs-1/fs;
            plot(axes1, t,ECG)
            set(axes1, 'XGrid', 'on','YGrid', 'on')
        end
    end

%Callback function for annotating R peaks starts here
    function Annotate_ECG(object,event)
        if isempty(Fs_value.String)
            uiwait(msgbox('Please first enter the sampling frequency in fs'))
            return;
        end
        set(TimeDomain_Calculate,'Enable','off');
        set(Frequency_Calculate,'Enable','off');
        set(Nonlinear_Calculate,'Enable','off');
        set(Complexity_Calculate,'Enable','off');
        set(Poincare_Calculate,'Enable','off');
        set(edit_boxes, 'String', '');
        cla(px3); 
        cla(px1); 
        cla(px6);
        Tol_seg=1;segNo=1;
        Phase_Name='ECG';
        % Initialize the progress bar
        if isempty(ECG_data)
            ECGr = ECG;
        else
            ECGr = ECG_data;
        end
        
        ECG_len30=length(ECGr)/fs;
        if ECG_Filter.Value==1
        order = 4;
        low_cutoff = 0.67;
        high_cutoff = 100;
        nyquist = fs / 2;
        low_cutoff_norm = low_cutoff / nyquist;
        high_cutoff_norm = high_cutoff / nyquist;
        [b, a] = butter(order, [low_cutoff_norm, high_cutoff_norm], 'bandpass');
        ECGr = filtfilt(b, a, ECGr);
        end
        % Adding mirrored signal before and after signal
        len = length(ECGr);
        ECG_ext=wextend('1D','per',ECGr,len,'b');
        % taking complete signal for annotation
        start_epoch=1;
        stop_epoch=length(ECG_ext);
        % set debugging to 0 if no other visual output is required otherwise 1
        debugging=0;
        % These value does not impact the code this is just to satisfy the function requirement
        R_alignment=0;
        seconds_of_tolerance = 0;
        if ECG_len30<30
           uiwait(msgbox('ECG is less than 30 secs: HRV analysis not recommended select longer epoch'))
           return;
        end
        try
        [R_pos] = Rpeakmark(ECG_ext, start_epoch,...
            stop_epoch, fs, debugging, ECGr, seconds_of_tolerance,caseName,Tol_seg,segNo,Phase_Name);
        catch ME
        errordlg('Error in Rpeak Annotation: Please check the signal quality');
        % Pause execution until user closes the error dialog
        uiwait;
        % Optionally, rethrow the error if you want to halt further execution
        rethrow(ME);
        end
        cla(axes1)
        tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});
        if Unit.Value==1
            if isempty(ECG_data)
                plot(axes1,ECG)
                set(axes1, 'XGrid', 'on','YGrid', 'on')
                hold on;
                Rplot = plot(axes1,R_pos,ECG(R_pos), '*');
                xlabel('Samples')
                ylabel('ECG (mV)')
            else
                plot(axes1,ECG_data)
                set(axes1, 'XGrid', 'on','YGrid', 'on')
                hold on;
                Rplot = plot(axes1,R_pos,ECG_data(R_pos), '*');
                xlabel('Samples')
                ylabel('ECG (mV)')
            end
            tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});  
        elseif Unit.Value==2
            if isempty(Fs_value.String)
                uiwait(msgbox('Please first enter the sampling frequency in fs for plotting seconds'))
                return;
            end
            if isempty(ECG_data)
                t = 0:1/fs:length(ECG)/fs-1/fs;
                plot(axes1,t,ECG)
                hold on;
                Rplot = plot(axes1,t(R_pos),ECG(R_pos), '*');
                xlabel(axes1,'Time (Sec)');
                
               ylabel(axes1,'ECG (mV)');
            else
                t = 0:1/fs:length(ECG_data)/fs-1/fs;
                plot(axes1,t,ECG_data)
                hold on;
                Rplot = plot(axes1,t(R_pos),ECG_data(R_pos), '*');
                xlabel(axes1,'Time(Sec)')
                ylabel(axes1,'ECG (mV)')
            end            
            tb = axtoolbar(axes1,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});    
        end
        set(Rplot, 'ButtonDownFcn', @plot_ButtonDownFcn);
        set(TimeDomain_Calculate,'Enable','on');
        set(Frequency_Calculate,'Enable','on');
        set(Nonlinear_Calculate,'Enable','on');
        set(Complexity_Calculate,'Enable','on');
        set(Poincare_Calculate,'Enable','on');
    end
%Callback function for annotating R peaks ends here 

%Callback function 2 for Rpeak correction start here
    function plot_ButtonDownFcn(object, event)
        if isInEditMode==1
            if Unit.Value == 1
                currentPoint = get(gca, 'CurrentPoint');
                xClick = round(currentPoint(1,1)); % X-coordinate of the click
                % Determine if the click is near an existing marker
                threshold = 20; % Define threshold for "closeness"
                distances = abs(R_pos - xClick);
                [minDistance, nearestIndex] = min(distances);
                if minDistance <= threshold
                    % If click is near an existing marker, delete it
                    R_pos(nearestIndex) = [];
                else
                    R_pos = [R_pos, xClick];
                    R_pos = sort(R_pos);
                end
            elseif Unit.Value == 2
                currentPoint = get(gca, 'CurrentPoint');
                xClick = round(currentPoint(1,1)*fs); % X-coordinate of the click
                % Determine if the click is near an existing marker
                threshold = 20; % Define threshold for "closeness"
                distances = abs(R_pos - xClick);
                [minDistance, nearestIndex] = min(distances);
                if minDistance <= threshold
                    % If click is near an existing marker, delete it
                    R_pos(nearestIndex) = [];
                else
                    R_pos = [R_pos, xClick];
                    R_pos = sort(R_pos);
                end
            end
            % Update the plot
            delete(Rplot); % Delete old plot
            Rplot = plotRPeaks(); % Plot with updated R_pos
        end
    end
%Callback function 2 for Rpeak correction ends here

%Callback function for analysis methods
    function Setting_window(object, event)
        Handle_Setting_process();
    end
end

