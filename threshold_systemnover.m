function [RMS1, RMS2, RMS3, RMS4] = threshold_systemnover(W1, W2, W3, W4)

% Global variable declarations
global acc1 acc2 acc3 acc4;
global RMS1 RMS2 RMS3 RMS4;
global count go;


% Calculation of RMS
if count == 250
    acc1(1) = acc1(1) + W1^2;
    RMS1 = sqrt(sum(acc1) / (count * 8));

    acc2(1) = acc2(1) + W2^2;
    RMS2 = sqrt(sum(acc2) / (count * 8));

    acc3(1) = acc3(1) + W3^2;
    RMS3 = 1.5*sqrt(sum(acc3) / (count * 8));

    acc4(1) = acc4(1) + W4^2;
    RMS4 = .5*sqrt(sum(acc4) / (count * 8));

elseif count == 1
    acc1 = [(W1^2), acc1(1:7)];
    acc2 = [(W2^2), acc2(1:7)];
    acc3 = [(W3^2), acc3(1:7)];
    acc4 = [(W4^2), acc4(1:7)];

else
    acc1(1) = acc1(1) + W1^2;
    acc2(1) = acc2(1) + W2^2;
    acc3(1) = acc3(1) + W3^2;
    acc4(1) = acc4(1) + W4^2;
end


% counter update
if count == 250
    count = 1;
else
    count = count + 1;
end
