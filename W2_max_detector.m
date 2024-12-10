function [f, p, v] = W2_max_detector(th2, f3, p3, v3);


% dichiarazione delle variabili globali
global buff2;

% procedura
f = 0;
p = 0;
v = 0;
if f3 == 1
    ref = p3 + 4;
    if v3 > 0
        for i = (ref - 8):(ref + 8),
            if buff2(i) >= th2 % condizione di soglia
                if ((buff2(i-1) < buff2(i)) & ...
                        (buff2(i+1) < buff2(i))) | ...
                        ((buff2(i-1) < buff2(i)) & ...
                        (buff2(i+1) == buff2(i)))
                    if buff2(i) > 1.2*v | ...
                            ((1.2*buff2(i) >= v) & (abs(i - ref) < abs(p - ref)))
                        f = 1;
                        p = i;
                        v = buff2(i);
                    end
                end
            end
        end
    elseif v3 < 0
        for i = (ref - 8):(ref + 8),
            if (buff2(i) <= -th2)  % condizione di soglia
                if ((buff2(i-1) > buff2(i)) & ...
                        (buff2(i+1) > buff2(i))) | ...
                        ((buff2(i-1) > buff2(i)) & ...
                        (buff2(i+1) == buff2(i)))
                    if buff2(i) < 1.2*v | ...
                            ((1.2*buff2(i) <= v) & (abs(i - ref) < abs(p - ref)))
                        f = 1;
                        p = i;
                        v = buff2(i);
                    end
                end
            end
        end
    end
end
