function [f, p, v] = W1_max_detector(th1, f2, p2, v2);


% dichiarazione delle variabili globali
global buff1;

% procedura
f = 0;
p = 0;
v = 0;
if f2 == 1
    ref = p2 + 2;
    if v2 > 0
        for i = (ref - 4):(ref + 4),
            if buff1(i) >= th1 % condizione di soglia
                if ((buff1(i-1) < buff1(i)) & ...
                        (buff1(i+1) < buff1(i))) | ...
                        ((buff1(i-1) < buff1(i)) & ...
                        (buff1(i+1) == buff1(i)))
                    if buff1(i) > 1.2*v | ...
                            ((1.2*buff1(i) >= v) & (abs(i - ref) < abs(p - ref)))
                        f = 1;
                        p = i;
                        v = buff1(i);
                    end
                end
            end
        end
    elseif v2 < 0
        for i = (ref - 4):(ref + 4),
            if (buff1(i) <= -th1)  % condizione di soglia
                if ((buff1(i-1) > buff1(i)) & ...
                        (buff1(i+1) > buff1(i))) | ...
                        ((buff1(i-1) > buff1(i)) & ...
                        (buff1(i+1) == buff1(i)))
                    if buff1(i) < 1.2*v | ...
                            ((1.2*buff1(i) <= v) & (abs(i - ref) < abs(p - ref)))
                        f = 1;
                        p = i;
                        v = buff1(i);
                    end
                end
            end
        end
    end
end

