function [found, P, P_on, P_end] = ...
    P_detector_novar(fb, QRS, fsb, QRS_sb, QRS_on, ft, T_end);

global buff4;
global RR RR_buff;
global T_ref;
global T_found;

P = 0;
P_on = 0;
P_end = 0;
found = 0;

% assegnazione delle variabili nel caso di rilevamento battito
beat = 0;
if fb == 1
    beat = 1;
    R = QRS;
elseif fsb == 1
    beat = 1;
    R = QRS_sb;
end

% aggiornamento del riferimento si T
if ft == 1
    T_ref = T_end;
elseif T_found == 1
    T_ref = T_ref + 1;
else
    T_ref = 0;
end

if beat == 1
    % limiti dell'intervallo di ricerca
    
    if (T_ref == 0) | (T_ref > (QRS_on + 80)) % T non presente o lontana
        lim_sx = QRS_on - 14 + 80;
        lim_dx = QRS_on - 14 + 5;
    else % T presente a distanza accettabile
        lim_sx = T_end - 14 - 10;
        lim_dx = QRS_on - 14 + 5;
    end
  
    % calcolo della soglia
    temp = 0;
    for i = lim_dx:lim_sx
        temp = temp + buff4(i)^2;
    end
    th_P_temp = .25*sqrt(temp/(lim_sx-lim_dx));
    
    %{
    ricerca dei massimi:
    all'interno della sw posizionata a partire da QRS_on
    cerco una coppia di massimi e minimi che superino una certa soglia.
    trovato il primo cerco il successivo che sia di verso opposto
    e si trovi entro 30 campioni dal precedente.
    se non soddisfa le condizioni cancello il primo e considero il corrente
    quando sono stati trovati 2 punti la ricerca conclude
    e si considera che l'onda P sia presente.
    %}
    found = 0;
    point_temp = [0 0];
    for i = lim_dx:lim_sx,
        if abs(buff4(i)) >= th_P_temp % condizione di soglia
            if ((abs(buff4(i-1)) < abs(buff4(i))) & ...
                    (abs(buff4(i+1)) < abs(buff4(i)))) | ...
                    ((abs(buff4(i-1)) < abs(buff4(i))) & ...
                    (abs(buff4(i+1)) == abs(buff4(i))))
                if point_temp(1) == 0; % primo massimo
                    point_temp(1) = i;
                    point_temp(2) = buff4(i);
                else % secondo massimo
                    if (sign(point_temp(2)) == sign(buff4(i))) | ... % stesso verso
                            ((i - point_temp(1)) > 30) % verso opposto e lontani
                        point_temp(1) = i;
                        point_temp(2) = buff4(i);
                    else % verso opposto e vicini
                        found = 1;
                        th_P = .5*max(abs(point_temp(2)), abs(buff4(i)));
                        break;
                    end
                end
            end
        end
    end
    
    %{
    ricerca dei massimi RILEVANTI:
    all'interno della sw posizionata a partire da QRS_on
    cerco una coppia di massimi e minimi che superino una certa soglia.
    trovato il primo cerco il successivo che sia di verso opposto
    e si trovi entro 30 campioni dal precedente.
    vengono accettati fino a tre massimi opposti e vicini.
    picco unico: onda P +/-
    due picchi : onda P monofasica +/-
    tre picchi : onda P bifasica +/-, -/+
    viene data la priorità agli eventi più vicini al complesso QRS
    %}
    if found == 1
        point = [0 0 0; 0 0 0];
        for i = lim_dx:lim_sx,
            if abs(buff4(i)) >= th_P % condizione di soglia
                if ((abs(buff4(i-1)) < abs(buff4(i))) & ...
                        (abs(buff4(i+1)) < abs(buff4(i)))) | ...
                        ((abs(buff4(i-1)) < abs(buff4(i))) & ...
                        (abs(buff4(i+1)) == abs(buff4(i))))
                    if point(1,1) == 0; % primo massimo
                        point(1,1) = i;
                        point(2,1) = buff4(i);
                    elseif point(1,2) == 0 % secondo massimo
                        if (i - point(1,1)) > 30 % punti lontani
                            break;
                        elseif sign(point(2,1)) == sign(buff4(i)) % stesso verso
                            point(1,1) = i;
                            point(2,1) = buff4(i);
                        else % verso opposto e vicini
                            point(1,2) = i;
                            point(2,2) = buff4(i);
                        end
                    elseif (i - point(1,2)) <= 30 % terzo massimo vicino al secondo
                        if sign(point(2,2)) == sign(buff4(i)) % stesso verso
                            point(1,2) = i;
                            point(2,2) = buff4(i);
                        else  % verso opposto 
                            point(1,3) = i;
                            point(2,3) = buff4(i);
                        end
                    else
                        break;
                    end
                end
            end
        end
        % determinazione dei picco P
        if point(1,2) == 0 % onda crescente/decrescente
            P = point(1,1) + 14;
        elseif point(1,3) == 0 % onda monofasica +/-
            for z = point(1,1):point(1,2),
                if buff4(z) == 0
                    P = z + 14;
                    break;
                elseif sign(buff4(z)) ~= sign(buff4(z+1))
                    if abs(buff4(z)) > abs(buff4(z+1))
                        P = z + 1 + 14;
                        break;
                    else
                        P = z + 14;
                        break;
                    end
                end
            end
        else % onda bifasica +/-, -/+
            P = point(1,2) + 14;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%% delineation %%%%%%%%%%%%%%%%%%%%%
if found == 1
    
    % definizione degli intervalli di ricerca
    % e della soglia per on e end
    if point(1,2) == 0 % onda crescente
        % on
        th_on = .6*abs(point(2,1));
        lim_sx_on = lim_sx;
        lim_dx_on = point(1,1);
        % end
        th_end = .6*abs(point(2,1));
        lim_sx_end = point(1,1);
        lim_dx_end = lim_dx;
    elseif point(1,3) == 0 % onda monofasica
        % on
        th_on = .5*abs(point(2,2));
        lim_sx_on = lim_sx;
        lim_dx_on = point(1,2);
        % end
        th_end = .5*abs(point(2,1));
        lim_sx_end = point(1,1);
        lim_dx_end = lim_dx;
    else % onda bifasica
        % on
        th_on = .6*abs(point(2,3));
        lim_sx_on = lim_sx;
        lim_dx_on = point(1,3);
        % end
        th_end = .6*abs(point(2,1));
        lim_sx_end = point(1,1);
        lim_dx_end = lim_dx;
    end
    
    % ricerca on
    for ii = lim_dx_on:lim_sx_on,
        if abs(buff4(ii)) < th_on
            P_on = ii + 14; % comprende la traslazione 14
            break;
        end
    end
    if P_on == 0
        P_on = lim_sx_on + 14;
    end
    
    % ricerca end
    for ii = lim_sx_end:-1:lim_dx_end,
        if abs(buff4(ii)) < th_end
            P_end = ii + 14; % comprende la traslazione 14
            break;
        end
    end
    if P_end == 0
        P_end = lim_dx_end + 14;
    end
end
