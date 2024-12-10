function [f, p, v] = W3_max_detector(th3, f4, p4, v4);


% dichiarazione delle variabili globali
global buff3;

% procedura
f = 0;
p = 0;
v = 0;
if f4 == 1
    ref = p4 + 8;
    if v4 > 0
        for i = (ref - 8):(ref + 8),
            if buff3(i) >= th3 % condizione di soglia
                if ((buff3(i-1) < buff3(i)) & ...
                        (buff3(i+1) < buff3(i))) | ...
                        ((buff3(i-1) < buff3(i)) & ...
                        (buff3(i+1) == buff3(i)))
                    if buff3(i) > 1.2*v | ...
                            ((1.2*buff3(i) >= v) & (abs(i - ref) < abs(p - ref)))
                        f = 1;
                        p = i;
                        v = buff3(i);
                    end
                end
            end
        end
    elseif v4 < 0
        for i = (ref - 8):(ref + 8),
            if (buff3(i) <= -th3)  % condizione di soglia
                if ((buff3(i-1) > buff3(i)) & ...
                        (buff3(i+1) > buff3(i))) | ...
                        ((buff3(i-1) > buff3(i)) & ...
                        (buff3(i+1) == buff3(i)))
                    if buff3(i) < 1.2*v | ...
                            ((1.2*buff3(i) <= v) & (abs(i - ref) < abs(p - ref)))
                        f = 1;
                        p = i;
                        v = buff3(i);
                    end
                end
            end
        end
    end
end

