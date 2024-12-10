function [f, p] = zero_detector(fr);

% dichiarazioni delle variabili globali
global buff1;
global max1c val1c;

% procedura
f = 0;
p = 0;
if fr == 1
    % considero coppie max-min distanti massimo 30 campioni
    if ((max1c(2) - max1c(1)) <= 30) & (sign(val1c(2)) == -sign(val1c(1)))
        if abs(val1c(2)) <= abs(val1c(1))
            % routine di ricerca dello zero
            for z = max1c(1):max1c(2),
                if buff1(z) == 0
                    p = z;
                    f = 1;
                    break;
                elseif sign(buff1(z)) ~= sign(buff1(z+1))
                    if abs(buff1(z)) > abs(buff1(z+1))
                        p = z + 1;
                        f = 1;
                        break;
                    else
                        p = z;
                        f = 1;
                        break;
                    end
                end
            end
        else
            % routine di ricerca dello zero
            for z = max1c(2):-1:max1c(1),
                if buff1(z) == 0
                    p = z;
                    f = 1;
                    break;
                elseif sign(buff1(z)) ~= sign(buff1(z+1))
                    if abs(buff1(z)) > abs(buff1(z+1))
                        p = z + 1;
                        f = 1;
                        break;
                    else
                        p = z;
                        f = 1;
                        break;
                    end
                end
            end
        end
    end
end

        