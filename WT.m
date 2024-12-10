%{
Calculation of the WT on 5 scales.

The algorithm expects a buffer that stores a window of
62 samples of the signal on which the functions of
transfer of suitably calculated filters.

W1 lags behind the signal by 1 sample.
W2 is 4 samples late.
W3 is 10 samples late
W4 is 22 samples behind.
w5 is 46 samples behind.
These delays also correspond to the transitory times of each transformed.
%}
function [out1, out2, out3, out4, out5] = WT(sample);

% Global variable declaration
global buff;
global W1_coeff W2_coeff W3_coeff W4_coeff W5_coeff;
global buff1 buff2 buff3 buff4 buff5;
global c go;

% Buffer implementation
buff = [sample, buff(1:61)];

% Convolutions
W1 = sum(buff(1:2) .* W1_coeff);
W2 = sum(buff(1:6) .* W2_coeff);
W3 = sum(buff(1:14) .* W3_coeff);
W4 = sum(buff(1:30) .* W4_coeff);
W5 = sum(buff(1:62) .* W5_coeff);

if go == 1
    buff1 = [W1, buff1(1:2047)];
    buff2 = [W2, buff2(1:2047)];
    buff3 = [W3, buff3(1:2047)];
    buff4 = [W4, buff4(1:2047)];
    buff5 = [W5, buff5(1:2047)];
else
    buff1 = [0, buff1(1:2047)];
    buff2 = [0, buff2(1:2047)];
    buff3 = [0, buff3(1:2047)];
    buff4 = [0, buff4(1:2047)];
    buff5 = [0, buff5(1:2047)];
end

out1 = buff1(1);
out2 = buff2(1);
out3 = buff3(1);
out4 = buff4(1);
out5 = buff5(1);

if c == 64
    go = 1;
    c = c + 1;
elseif c < 64
    c = c + 1;
end
