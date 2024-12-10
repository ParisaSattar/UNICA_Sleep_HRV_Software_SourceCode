%{
Initialization and memory allocation for global variables
%}
function [] = init(signal);

% -------------------------------------------------------------------------
% 'system'
% buffers
% -------------------------------------------------------------------------
global max1 max2 max3;
global val1 val2 val3;
global max1c max2c max3c;
global val1c val2c val3c;

% buffers of the synchronized maxima
max1 = zeros(1, 16) + 100;
max2 = zeros(1, 16) + 100;
max3 = zeros(1, 16) + 100;
val1 = zeros(1, 16);
val2 = zeros(1, 16);
val3 = zeros(1, 16);

max1c = zeros(1, 2);
max2c = zeros(1, 2);
max3c = zeros(1, 2);
val1c = zeros(1, 2);
val2c = zeros(1, 2);
val3c = zeros(1, 2);

% -------------------------------------------------------------------------
% 'WT'
% Coefficients of transform filters
% -------------------------------------------------------------------------
global W1_coeff W2_coeff W3_coeff W4_coeff W5_coeff;
global buff;
global buff1 buff2 buff3 buff4 buff5;
global c go;

% (z^1 ... z^0) - no translation with respect to signal events
W1_coeff = 2*[1, -1]; 

% (z^4 ... z^-1) - traslazione 2
W2_coeff = 4\[1, 3, 2, -2, -3, -1];

% (z^10 ... z^-3) - traslazione 6
W3_coeff = 32\[1, 3, 6, 10, 11, 9, 4, -4, -9, -11, -10, -6, -3, -1];

% (z^22 ... z^-7) - traslazione 14
W4_coeff = 256\[1, 3, 6, 10, 15, 21, 28, 36, 41, 43, 42, 38, 31, 21, 8, ...
    -8, -21, -31, -38, -42, -43, -41, -36, -28, -21, -15, -10, -6, -3, -1];

% (z^46 ... z^-15) - traslazione 30
W5_coeff = 2048\[1,3,6,10,15,21,28,36,45,55,66,78,91,105,120,136,149,159,166,170,171,169,164,156,145,131,114,94,71,45,16,...
    -16,-45,-71,-94,-114,-131,-145,-156,-164,-169,-171,-170,-166,-159,-149,-136,-120,-105,-91,-78,-66,-55,-45,-36,-28,-21,-15,-10,-6,-3,-1];

% buffers
buff = zeros(1, 62);
buff1 = zeros(1, 2048);
buff2 = zeros(1, 2048);
buff3 = zeros(1, 2048);
buff4 = zeros(1, 2048);
buff5 = zeros(1, 2048);

% counter
c = 1;
go = 0;

% -------------------------------------------------------------------------
% 'threshold'
% Initialization of the variables for the calculation of the threshold
% -------------------------------------------------------------------------
global acc1 acc2 acc3 acc4;
global RMS1 RMS2 RMS3 RMS4;
global count go;

% counter
count = 1;

% initial thresholds
RMS1 = 20;
RMS2 = 30;
RMS3 = 40;
RMS4 = 25;

% accumulators
acc1 = zeros(1, 8) + 2*250*20^2;
acc2 = zeros(1, 8) + 2*250*30^2;
acc3 = zeros(1, 8) + 2*250*40^2;
acc4 = zeros(1, 8) + 2*250*(.5*50)^2;

% -------------------------------------------------------------------------
% 'redundance_remover'
% Initialization of the variables for the calculation of the maximums
% -------------------------------------------------------------------------
global ref out;
global delay;
global redundance;

ref = 0;
out = 0;
delay = zeros(1, 16);
redundance = zeros(1, 16);

% -------------------------------------------------------------------------
% 'zero_blanking'
% Initialization of the variables for the detection of zeros
% -------------------------------------------------------------------------
global QRS_buff;
global RR;
global RR_buff;
global last_couple1;
global last_couple3;
global reference;
global sb_start;

QRS_buff = [0, 0];
RR_buff = zeros(1, 8) + 200;
RR = 200;
last_couple1 = [0, 0];
last_couple1 = [0, 0];
reference = 0;
sb_start = 300;

% -------------------------------------------------------------------------
% 'QRS_delineator'
% Initialization of the buffer of the duration of the QRS complex
% -------------------------------------------------------------------------
global QRS_width;
global QRS_internal_width;
global QRS_max_width QRS_max_internal_width;

QRS_max_width = 38;
QRS_max_internal_width = 38;
QRS_width = zeros(1,4) + 35; % 140 ms
QRS_internal_width = zeros(1,4) + 30; % 120 ms

% -------------------------------------------------------------------------
% 'T_detector'
% Initialization of global variables
% -------------------------------------------------------------------------
global T_done;
global R R_end R_max;
global T_found;

T_found = 0;
T_done = 1;
R = 0;
R_end = 0;
R_max = 100;

% -------------------------------------------------------------------------
% 'T_detector'
% Initialization of global variables
% -------------------------------------------------------------------------
global T_ref;

T_ref = 200;
