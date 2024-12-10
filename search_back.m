function [f, p] = search_back(th3, th2, th1);

% dichiarazione delle variabili globali
global QRS_buff;
global RR;
global RR_buff;
global last_couple1 last_couple2 last_couple3;
global last_couple1val last_couple2val last_couple3val;
global reference;
global sb_start;
global buff3 buff2 buff1;


% procedura
f = 0;
p = 0;
reference = reference + 1;
sb_start = sb_start + 1;
if reference > (1.5*RR + 128)
    % ------
    % inizializzazioni
    max1 = zeros(1, 16) + 500;
    max2 = zeros(1, 16) + 500;
    max3 = zeros(1, 16) + 500;
    val1 = zeros(1, 16);
    val2 = zeros(1, 16);
    val3 = zeros(1, 16);
    ref = 0;
    out = 0;
    delay = zeros(1, 16);
    redundance = zeros(1, 16);
    max1c = [0, 0];
    max2c = [0, 0];
    max3c = [0, 0];
    val1c = [0, 0];
    val2c = [0, 0];
    val3c = [0, 0];
    
    for ii = sb_start:-1:16,
        
        % ------
        % ricerca dei max/min su W3
        f3 = 0;
        p3 = 0;
        v3 = 0;
        if buff3(ii) >= th3 % condizione di soglia
            if ((buff3(ii-1) < buff3(ii)) & ...
                    (buff3(ii+1) < buff3(ii))) | ...
                    ((buff3(ii-1) < buff3(ii)) & ...
                    (buff3(ii+1) == buff3(ii)))
                f3 = 1;
                p3 = ii;
                v3 = buff3(ii);
            end

        elseif buff3(ii) <= -th3  % condizione di soglia
            if ((buff3(ii-1) > buff3(ii)) & ...
                    (buff3(ii+1) > buff3(ii))) | ...
                    ((buff3(ii-1) > buff3(ii)) & ...
                    (buff3(ii+1) == buff3(ii)))
                f3 = 1;
                p3 = ii;
                v3 = buff3(ii);
            end
        end
        
        % ------
        % ricerca dei max/min su W2
        f2 = 0;
        p2 = 0;
        v2 = 0;
        if f3 == 1
            ref2 = p3 + 4;
            if v3 > 0
                for i = (ref2 - 8):(ref2 + 8),
                    if buff2(i) >= th2 % condizione di soglia
                        if ((buff2(i-1) < buff2(i)) & ...
                                (buff2(i+1) < buff2(i))) | ...
                                ((buff2(i-1) < buff2(i)) & ...
                                (buff2(i+1) == buff2(i)))
                            if buff2(i) > 1.2*v2 | ...
                                    ((1.2*buff2(i) >= v2) & (abs(i - ref2) < abs(p - ref2)))
                                f2 = 1;
                                p2 = i;
                                v2 = buff2(i);
                            end
                        end
                    end
                end
            elseif v3 < 0
                for i = (ref2 - 8):(ref2 + 8),
                    if (buff2(i) <= -th2)  % condizione di soglia
                        if ((buff2(i-1) > buff2(i)) & ...
                                (buff2(i+1) > buff2(i))) | ...
                                ((buff2(i-1) > buff2(i)) & ...
                                (buff2(i+1) == buff2(i)))
                            if buff2(i) < 1.2*v2 | ...
                                    ((1.2*buff2(i) <= v2) & (abs(i - ref2) < abs(p - ref2)))
                                f2 = 1;
                                p2 = i;
                                v2 = buff2(i);
                            end
                        end
                    end
                end
            end
        end
        
        % ------
        % ricerca dei max/min su W1
        f1 = 0;
        p1 = 0;
        v1 = 0;
        if f2 == 1
            ref1 = p2 + 2;
            if v2 > 0
                for i = (ref1 - 4):(ref1 + 4),
                    if buff1(i) >= th1 % condizione di soglia
                        if ((buff1(i-1) < buff1(i)) & ...
                                (buff1(i+1) < buff1(i))) | ...
                                ((buff1(i-1) < buff1(i)) & ...
                                (buff1(i+1) == buff1(i)))
                            if buff1(i) > 1.2*v1 | ...
                                    ((1.2*buff1(i) >= v1) & (abs(i - ref1) < abs(p - ref1)))
                                f1 = 1;
                                p1 = i;
                                v1 = buff1(i);
                            end
                        end
                    end
                end
            elseif v2 < 0
                for i = (ref1 - 4):(ref1 + 4),
                    if (buff1(i) <= -th1)  % condizione di soglia
                        if ((buff1(i-1) > buff1(i)) & ...
                                (buff1(i+1) > buff1(i))) | ...
                                ((buff1(i-1) > buff1(i)) & ...
                                (buff1(i+1) == buff1(i)))
                            if buff1(i) < 1.2*v1 | ...
                                    ((1.2*buff1(i) <= v1) & (abs(i - ref1) < abs(p - ref1)))
                                f1 = 1;
                                p1 = i;
                                v1 = buff1(i);
                            end
                        end
                    end
                end
            end
        end

        % ------
        % analisi di ridondanza su W3
        delay = delay - 1;
        if f1 == 1
            % creazione dei buffers
            max1 = [p1, max1(1:15)];
            max2 = [p2, max2(1:15)];
            max3 = [p3, max3(1:15)];
            val1 = [v1, val1(1:15)];
            val2 = [v2, val2(1:15)];
            val3 = [v3, val3(1:15)];
            
            % aggiornamento del massimo di riferimento
            ref = ref + 1;
            % aggiornamento dell'uscita di riferimento
            out = out + 1;
            % aggiornamento delle attese previste e degli indici di ridondanza
            redundance = [0, redundance(1:15)];
            delay = [30, delay(1:15)];
        end

        % procedura
        if ref ~= 0
            if (delay(ref) == 0) & (redundance(ref) == 0)

                % cerco gli estremi dell'intervallo di ricerca
                bottom = ref;
                for h = 1:ref,
                    distance = (max3(ref) - max3(h));
                    if (distance <= 30) & (bottom == ref)
                        bottom = h;
                        break
                    end
                end
                top = ref;
                for h = ref:numel(max3),
                    distance = (max3(h) - max3(ref));
                    if (distance <= 30)
                        top = h;
                    else
                        break
                    end
                end

                % cerco le coppie max/min e ne calcolo il parametro
                par = zeros(1, top);
                found = 0;
                for m = bottom:top,
                    if (sign(val3(m)) == -sign(val3(ref))) & (redundance(m) == 0)
                        par(m) = abs(val3(m)/(max3(ref) - max3(m)));
                        found = found + 1;
                    end
                end

                % confronto del parametro
                if found > 1
                    par_max = 0;
                    pointer = 0;
                    for m = bottom:top,
                        % elementi molto differenti
                        if (par(m) > 1.2*par_max)
                            par_max = par(m);
                            pointer = m;
                        elseif 1.2*par(m) > par_max
                            % elementi simili a un lato del riferimento
                            if ((pointer < ref) & (m < ref))
                                par_max = par(m); % il più vicino
                                pointer = m;
                            % elementi simili ai due lati del riferimento
                            elseif ((pointer < ref) & (m > ref)) & ...
                                    (abs(val3(m)) > abs(val3(pointer)))
                                par_max = par(m);
                                pointer = m;
                            end
                        end
                    end

                    % aggiorno gli indici di ridondanza
                    for m = bottom:top,
                        if par(m) ~= 0
                            redundance(m) = redundance(m) + 1;
                        end
                    end
                    redundance(pointer) = redundance(pointer) - 1;
                end

                % aggiorno il riferimento
                ref = ref - 1;
            elseif delay(ref) == 0
                ref = ref - 1;
            end
        end

        % definizione dei massimi non ridondanti
        fr = 0;
        p1r = 0;
        p2r = 0;
        p3r = 0;
        v1r = 0;
        v2r = 0;
        v3r = 0;
        if out ~= 0
            if (delay(out) == -30) & (redundance(out) == 0)
                fr = 1;
                p1r = max1(out);
                p2r = max2(out);
                p3r = max3(out);
                v1r = val1(out);
                v2r = val2(out);
                v3r = val3(out);
                out = out - 1;
            elseif delay(out) == -30
                out = out - 1;
            end
        end
        
        % ------
        % ricerca dello zero
        % procedura
        p = 0;
        if fr == 1
            % costruzione dei buffers delle coppie su W1 e W3
            max1c = [p1r, max1c(1)];
            max2c = [p2r, max2c(1)];
            max3c = [p3r, max3c(1)];
            val1c = [v1r, val1c(1)];
            val2c = [v2r, val2c(1)];
            val3c = [v3r, val3c(1)];
            
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

        % aggiornamento dei parametri di sistema
        if f == 1
            QRS_buff = [p, QRS_buff(1)];
            RR_buff = [(QRS_buff(2) - QRS_buff(1)), RR_buff(1:7)];
            RR = ceil(sum(RR_buff)/8);
            last_couple1 = max1c;
            last_couple2 = max2c;
            last_couple3 = max3c;
            last_couple1val = val1c;
            last_couple2val = val2c;
            last_couple3val = val3c;
            reference = p;
            sb_start = p - ceil(RR/2);
            break
        end
    end
    
    % complesso QRS non trovato
    if f == 0
        reference = reference - RR;
        sb_start = reference;
    end
end
