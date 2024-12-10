function [R_pos, QRS_on_pos, QRS_end_pos, ...
    T_pos, T_on_pos, T_end_pos, ...
    P_pos, P_on_pos, P_end_pos] = ...
    system_novar(signal,caseName,Tol_seg,segNo,Phase_Name)

global Main
figPosition = get(Main, 'Position');

% Get the screen size(s)
screensize = get(0, 'MonitorPositions');

% Determine on which screen the main figure is located
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
nz = 1;
nt = 1;
np = 1;
R_pos = 0;
T_pos = 0;
P_pos = 0;
P_on_pos = 0;
P_end_pos = 0;
% -------------------------------------------------------------------------
% Memory allocation for test variables
% -------------------------------------------------------------------------
global max1 max2 max3;
global val1 val2 val3;
global max1c max2c max3c;
global val1c val2c val3c;
ww1=zeros(size(signal));
ww2=zeros(size(signal));
ww3=zeros(size(signal));
ww4=zeros(size(signal));
ww5=zeros(size(signal));

%%%%% INITIALIZATION %%%%%
init(signal);
% Define the waitbar dimensions
figWidth = 350;
figHeight = 60;

% Center the waitbar relative to the screen where the main figure is located
figX = figPosition(1) + (figPosition(3) - figWidth) / 2;
figY = figPosition(2) + (figPosition(4) - figHeight) / 2;

% Create the waitbar and set its position
waitHandle = waitbar(0, sprintf('Annotating ''%s'' %s Segment %d of %d', caseName, Phase_Name, segNo, Tol_seg));
set(waitHandle, 'Units', 'pixels');
set(waitHandle, 'Position', [figX, figY, figWidth, figHeight]);
waitHandle.Children.Title.Interpreter = 'none';
for i = 1:numel(signal)

    %%%%% CALCULATION OF PROCESSES %%%%%
    [w1, w2, w3, w4, w5] = WT(signal(i));
    ww1(i)=w1;
    ww2(i)=w2;
    ww3(i)=w3;
    ww4(i)=w4;
    ww5(i)=w5;
    
    %%%%% CALCULATION OF THRESHOLDS %%%%%
    [th1, th2, th3, th4] = ...
        threshold_systemnover(w1, w2, w3, w4);
    
    %%%%% CALCULATION OF MAX / MIN ON W4 %%%%%
    [f4, p4, v4] = W4_max_detector(th4);
    
    %%%%% CALCULATION OF MAX / MIN ON W3 %%%%%
    [f3, p3, v3] = W3_max_detector(th3, f4, p4, v4);
    
    %%%%% CALCULATION OF MAX / MIN ON W2 %%%%%
    [f2, p2, v2] = W2_max_detector(th2, f3, p3, v3);
    
    %%%%% CALCULATION OF MAX / MIN ON W1 %%%%%
    [f1, p1, v1] = W1_max_detector(th1, f2, p2, v2);
    
    %%%%% SYNCHRONIZATION OF BUFFERS %%%%%
    max1 = max1 + 1;
    max2 = max2 + 1;
    max3 = max3 + 1;
    if f1 == 1
        max1 = [p1, max1(1:15)];
        max2 = [p2, max2(1:15)];
        max3 = [p3, max3(1:15)];
        val1 = [v1, val1(1:15)];
        val2 = [v2, val2(1:15)];
        val3 = [v3, val3(1:15)];
    end

    %%%%% REDUNDANCY REDUCER %%%%%
    [fr, p1r, v1r, p2r, v2r, p3r, v3r] = redundance_remover(f1);

    %%%%% Contruction of buffer couple %%%%%
    max1c = max1c + 1;
    max2c = max2c + 1;
    max3c = max3c + 1;
    if fr == 1
        max1c = [p1r, max1c(1)];
        max2c = [p2r, max2c(1)];
        max3c = [p3r, max3c(1)];
        val1c = [v1r, val1c(1)];
        val2c = [v2r, val2c(1)];
        val3c = [v3r, val3c(1)];
    end
    
    %%%%% ZERO DETECTION %%%%%
    [fz, zero] = zero_detector(fr);

    %%%%% REMOVAL OF CLOSE ZEROS %%%%%
    [fb, QRS] = zero_blanking(fz, zero);
    
    %%%%% SEARCH BACK PROCEDURE %%%%%
    [fsb, QRS_sb] = search_back((1/1.5*th3), th2, th1);
    
    %%%%% DELINEATION OF THE QRS COMPLEX %%%%%
    [QRS_on, QRS_end] = ...
        QRS_delineator(fb, QRS, fsb, QRS_sb);
    
    %%%%% T-WAVE DETECTION AND DELINEATION  %%%%%
    [ft, T, T_on, T_end] = ...
        T_detector(fb, QRS, fsb, QRS_sb, QRS_on, QRS_end);
    
    %%%%% P-WAVE DETECTION AND DELINEATION %%%%%
    [fp, P, P_on, P_end] = ...
        P_detector_novar(fb, QRS, fsb, QRS_sb, QRS_on, ft, T_end);
    
    % ---------------------------------------------------------------------
    % Construction of output vectors
    % ---------------------------------------------------------------------

    % QRS complex
    if fb == 1
        R_pos(nz) = i - QRS + 1;
        QRS_on_pos(nz) = i - QRS_on + 1;
        QRS_end_pos(nz) = i - QRS_end + 1;
        nz = nz + 1;
    elseif fsb == 1
        R_pos(nz) = i - QRS_sb + 1;
        QRS_on_pos(nz) = i - QRS_on + 1;
        QRS_end_pos(nz) = i - QRS_end + 1;
        nz = nz + 1;
    end
    
    % T wave
    if ft == 1
        T_pos(nt) = i - T + 1;
        T_on_pos(nt) = i - T_on + 1;
        T_end_pos(nt) = i - T_end + 1;
        nt = nt + 1;
    end
    
    % TP wave
    if fp == 1
        P_pos(np) = i - P + 1;
        P_on_pos(np) = i - P_on + 1;
        P_end_pos(np) = i - P_end + 1;
        np = np + 1;
    end
waitbar(i/numel(signal), waitHandle);
end
close(waitHandle);
end