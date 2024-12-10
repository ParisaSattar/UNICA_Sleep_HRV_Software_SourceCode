function [f, p, v] = W4_max_detector(th4);

% dichiarazione delle variabili globali
global buff4;

% procedura
f = 0;
p = 0;
v = 0;
if buff4(8) >= th4 % condizione di soglia
    if ((buff4(7) < buff4(8)) & ...
            (buff4(9) < buff4(8))) | ...
            ((buff4(7) < buff4(8)) & ...
            (buff4(9) == buff4(8)))
        f = 1;
        p = 8;
        v = buff4(8);
    end
        
elseif buff4(8) <= -th4 % condizione di soglia
    if ((buff4(7) > buff4(8)) & ...
            (buff4(9) > buff4(8))) | ...
            ((buff4(7) > buff4(8)) & ...
            (buff4(9) == buff4(8)))
        f = 1;
        p = 8;
        v = buff4(8);
    end
end
