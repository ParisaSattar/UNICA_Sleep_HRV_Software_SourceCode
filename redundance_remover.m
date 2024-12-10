function [f, p1r, v1r, p2r, v2r, p3r, v3r] = redundance_remover(f1);

% dichiarazione delle variabili globali
global ref out;
global delay;
global max1 max2 max3;
global val1 val2 val3;
global redundance;


if f1 == 1
    % aggiornamento del massimo di riferimento
    ref = ref + 1;
    % aggiornamento dell'uscita di riferimento
    out = out + 1;
    % aggiornamento delle attese previste e degli indici di ridondanza
    redundance = [0, redundance(1:15)];
    delay = [(max3(1) + 30 + 8), delay(1:15)];
end

% procedura
if ref ~= 0
    if (max3(ref) == delay(ref)) & (redundance(ref) == 0)
    
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
    elseif max3(ref) == delay(ref)
        ref = ref - 1;
    end
end

% aggiornamento dei buffer dei max/min non ridondanti
f = 0;
p1r = 0;
p2r = 0;
p3r = 0;
v1r = 0;
v2r = 0;
v3r = 0;
if out ~= 0
    if (max3(out) == (delay(out) + 30)) & (redundance(out) == 0)
        f = 1;
        p1r = max1(out);
        p2r = max2(out);
        p3r = max3(out);
        v1r = val1(out);
        v2r = val2(out);
        v3r = val3(out);
        out = out - 1;
    elseif max3(out) == (delay(out) + 30)
        out = out - 1;
    end
end
