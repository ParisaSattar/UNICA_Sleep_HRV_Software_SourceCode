function [QRS_on, QRS_end] = ...
    QRS_delineator(fb, QRS_ist, fsb, QRS_sb);

global val2c;
global last_couple2val;
global buff2;
global QRS_width QRS_internal_width;
global QRS_max_width QRS_max_internal_width;

% assignment of variables to beat detection
beat = 0;
if fb == 1
    beat = 1;
    QRS = QRS_ist;
    th_sx = .04*max(abs(val2c)); % construction of the threshold
    th_dx = .04*max(abs(val2c)); % construction of the threshold
elseif fsb == 1
    beat = 1;
    QRS = QRS_sb;
    th_sx = .04*max(abs(last_couple2val)); % construction of the threshold
    th_dx = .04*max(abs(last_couple2val)); % construction of the threshold
end

% ----------------------------------------------
% DETECTION OF SIGNIFICANT MAXIMUMS
% ----------------------------------------------
QRS_on = 0;
QRS_end = 0;

point_sx = zeros(2,5);
point_dx = zeros(2,5);

if beat == 1
    sx = 0;
    dx = 0;
    % search window
    sw = 25; % 120 ms
    % --- maxima to the left of the QRS complex
    for i = (QRS - 2):(QRS - 2 + sw),
        if abs(buff2(i)) >= th_sx % threshold condition
            if ((buff2(i) > 0) & ... maximum case
                    (((buff2(i-1) < buff2(i)) & ...
                    (buff2(i+1) < buff2(i))) | ...
                    ((buff2(i-1) < buff2(i)) & ...
                    (buff2(i+1) == buff2(i))))) | ...
                    ((buff2(i) < 0) & ... case of minimum
                    (((buff2(i-1) > buff2(i)) & ...
                    (buff2(i+1) > buff2(i))) | ...
                    ((buff2(i-1) > buff2(i)) & ...
                    (buff2(i+1) == buff2(i)))))
                if point_sx(1,1) == 0; % first maximum
                    point_sx(1,1) = i;
                    point_sx(2,1) = buff2(i);
                    sx = sx + 1;
                elseif (i - point_sx(1,sx) < 15) & ...
                        (sign(point_sx(2,sx)) == -sign(buff2(i))) % opposite and neighbors
                    sx = sx + 1;
                    point_sx(1,sx) = i;
                    point_sx(2,sx) = buff2(i);
                elseif (i - point_sx(1,sx) < 10) & ...
                        (abs(buff2(i)) > 1.2*abs(point_sx(2,sx)))
                    point_sx(1,sx) = i;
                    point_sx(2,sx) = buff2(i);
                end
            end
        end
    end
                    

    % --- maxima to the right of the QRS complex
    for i = (QRS - 2):-1:(QRS - 2 - sw),
        if abs(buff2(i)) >= th_dx % threshold condition
            if ((buff2(i) > 0) & ... maximum case
                    (((buff2(i-1) < buff2(i)) & ...
                    (buff2(i+1) < buff2(i))) | ...
                    ((buff2(i-1) < buff2(i)) & ...
                    (buff2(i+1) == buff2(i))))) | ...
                    ((buff2(i) < 0) & ... case of minimum
                    (((buff2(i-1) > buff2(i)) & ...
                    (buff2(i+1) > buff2(i))) | ...
                    ((buff2(i-1) > buff2(i)) & ...
                    (buff2(i+1) == buff2(i)))))
                if point_dx(1,1) == 0; % first maximum
                    point_dx(1,1) = i;
                    point_dx(2,1) = buff2(i);
                    dx = dx + 1;
                elseif (point_dx(1,dx) - i < 15) & ...
                        (sign(point_dx(2,dx)) == -sign(buff2(i))) %  opposite and neighbors
                    dx = dx + 1;
                    point_dx(1,dx) = i;
                    point_dx(2,dx) = buff2(i);
                elseif (point_dx(1,dx) - i < 10) & ...
                        (abs(buff2(i)) > 1.2*abs(point_dx(2,dx)))
                    point_dx(1,dx) = i;
                    point_dx(2,dx) = buff2(i);
                end
            end
        end
    end

    % security control
    if sx == 0
        point_sx(:,1) = point_dx(:,1);
        point_dx = [point_dx(:,2:5),[0 0]'];
        sx = 1;
        dx = dx - 1;
    elseif dx == 0
        point_dx(:,1) = point_sx(:,1);
        point_sx = [point_sx(:,2:5),[0 0]'];
        dx = 1;
        sx = sx + 1;
    end
    
    % maximum excess removal
    internal_width = ceil(mean(QRS_internal_width) + .2*mean(QRS_internal_width));
    if internal_width > QRS_max_internal_width
        internal_width = QRS_max_internal_width;
    end
    
    while (point_sx(1,sx) - point_dx(1,dx)) > internal_width
        if abs(point_sx(2,sx)) >= abs(point_dx(2,dx))
            if dx > 1
                point_dx(1,dx) = 0;
                point_dx(2,dx) = 0;
                dx = dx - 1;
            elseif sx > 1
                point_sx(1,sx) = 0;
                point_sx(2,sx) = 0;
                sx = sx - 1;
            else
                break
            end
        else
            if sx > 1
                point_sx(1,sx) = 0;
                point_sx(2,sx) = 0;
                sx = sx - 1;
            elseif dx > 1
                point_dx(1,dx) = 0;
                point_dx(2,dx) = 0;
                dx = dx - 1;
            else
                break
            end
        end
    end
    
    % internal duration of the complex
    QRS_internal_width = [(point_sx(1,sx)-point_dx(1,dx)), QRS_internal_width(1:3)];

    % intervals for searching for onsets and ends
    interval = ceil((mean(QRS_width) - QRS_internal_width(1) + 0.2*mean(QRS_width))/2);
    
    
    % --- ONSET of the QRS COMPLEX
    n_first = point_sx(1,sx);
    th_on = .05*abs(point_sx(2,sx));
    
    if point_sx(2,sx) > 0
        for ii = n_first:(n_first + interval)
            if buff2(ii) < th_on
                QRS_on = ii + 2+2; % comprende la traslazione 2
                break;
            end
        end
    else
        for ii = n_first:(n_first + interval)
            if buff2(ii) > -th_on
                QRS_on = ii + 2+2; % includes translation 2
                break;
            end
        end
    end
    if QRS_on == 0
        QRS_on = n_first + interval + 2+2; % includes translation 2
    end
    
    
    % --- END of the QRS COMPLEX
    n_last = point_dx(1,dx);
    th_end = .3*abs(point_dx(2,dx));
    
    if point_dx(2,dx) > 0
        for ii = n_last:-1:(n_last - interval)
            if buff2(ii) < th_end
                QRS_end = ii + 2; % includes translation 2
                break;
            end
        end
    else
        for ii = n_last:-1:(n_last - interval)
            if buff2(ii) > -th_end
                QRS_end = ii + 2; % includes translation 2
                break;
            end
        end
    end
    if QRS_end == 0
        QRS_end = n_last - interval + 2; % includes translation 2
    end

    % duration of the complex
    QRS_width = [(QRS_on-QRS_end), QRS_width(1:3)];
end
