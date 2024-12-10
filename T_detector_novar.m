function [found, T, T_on, T_end] = ...
    T_detector(fb, QRS, fsb, QRS_sb, QRS_on, QRS_end);

global buff4 buff5;
global RR RR_buff;
global T_done;
global R R_end R_max;

% aggiornamento della posizione del battito e dell'end
R = R + 1;
R_end = R_end + 1;

% QRS rilevato
beat = 0;
if fb == 1
    beat = 1;
elseif fsb == 1
    beat = 1;
end

% condizione di ricerca e limiti
search = 0;
if beat == 1 & T_done == 0 % nel caso di T precedente non cercata
    search = 1;
    lim_sx = R_end - 14 - 10;
    lim_dx = QRS_on - 14 + ceil(4/9*(R_end - QRS_on));
elseif R == R_max % nel caso di limite raggiunto
    search = 1;
    lim_sx = R_end - 14 - 10;
    lim_dx = 2;
end

T = 0;
T_on = 0;
T_end = 0;
found = 0;

if search == 1
    
    % calcolo della soglia
    temp = 0;
    for i = (lim_sx):-1:(lim_dx)
        temp = temp + buff4(i)^2;
    end
    th_T_temp = .2*sqrt(temp/(lim_sx-lim_dx));
    
    %{
    ricerca dei massimi:
    all'interno della sw posizionata a partire da QRS_end
    cerco una coppia di massimi e minimi che superino una certa soglia.
    trovato il primo cerco il successivo che sia di verso opposto
    e si trovi entro 30 campioni dal precedente.
    se non soddisfa le condizioni cancello il primo e considero il corrente
    quando sono stati trovati 2 punti la ricerca conclude
    e si considera che l'onda T sia presente.
    %}
    found = 0;
    point_temp = [0,0];
    for i = lim_sx:-1:lim_dx,
        if abs(buff4(i)) >= th_T_temp % condizione di soglia
            if ((abs(buff4(i-1)) < abs(buff4(i))) & ...
                    (abs(buff4(i+1)) < abs(buff4(i)))) | ...
                    ((abs(buff4(i-1)) < abs(buff4(i))) & ...
                    (abs(buff4(i+1)) == abs(buff4(i))))
                if point_temp(1) == 0; % primo massimo
                    point_temp(1) = i;
                    point_temp(2) = buff4(i);
                elseif (abs(buff4(i)) >= abs(point_temp(2)))
                    point_temp(1) = i;
                    point_temp(2) = buff4(i);
                end
                
            end
        end
    end
    if point_temp(1) ~= 0
        found = 1;
        th_T = .25*abs(point_temp(2));
    end
    
    %{
    ricerca dei massimi RILEVANTI:
    all'interno della sw posizionata a partire da QRS_end
    cerco una coppia di massimi e minimi che superino una certa soglia.
    trovato il primo cerco il successivo che sia di verso opposto
    e si trovi entro 30 campioni dal precedente.
    vengono accettati fino a tre massimi opposti e vicini.
    picco unico: onda T +/-
    due picchi : onda T monofasica +/-
    tre picchi : onda T bifasica +/-, -/+
    viene data la priorità agli eventi più ampi
    %}
    if found == 1
        point = [0 0 0; 0 0 0];
        for i = lim_sx:-1:lim_dx,
            if abs(buff4(i)) >= th_T % condizione di soglia
                if ((abs(buff4(i-1)) < abs(buff4(i))) & ...
                        (abs(buff4(i+1)) < abs(buff4(i)))) | ...
                        ((abs(buff4(i-1)) < abs(buff4(i))) & ...
                        (abs(buff4(i+1)) == abs(buff4(i))))
                    if point(1,1) == 0; % primo massimo
                        point(1,1) = i;
                        point(2,1) = buff4(i);
                    elseif point(1,2) == 0 % secondo massimo
                        if (point(1,1) - i) > 50
                            if (abs(buff4(i)) >= abs(point(2,1)))
                                point(1,1) = i;
                                point(2,1) = buff4(i);
                            end
                        elseif sign(point(2,1)) == sign(buff4(i)) % stesso verso
                            if abs(point(2,1)) <= abs(buff4(i)) % il più grande
                                point(1,1) = i;
                                point(2,1) = buff4(i);
                            end
                        else % verso opposto e vicini
                            point(1,2) = i;
                            point(2,2) = buff4(i);
                        end
                    elseif point(1,3) == 0
                        if (point(1,2) - i) > 50
                            if (abs(buff4(i)) >= abs(point(2,1))) & ...
                                    (abs(buff4(i)) >= abs(point(2,2)))
                                point(1,1) = i;
                                point(2,1) = buff4(i);
                                point(1,2) = 0;
                                point(2,2) = 0;
                            end
                        elseif sign(point(2,2)) == sign(buff4(i)) % stesso verso
                            if abs(point(2,2)) <= abs(buff4(i)) % il più grande
                                point(1,2) = i;
                                point(2,2) = buff4(i);
                            end
                        else % verso opposto e vicini
                            point(1,3) = i;
                            point(2,3) = buff4(i);
                        end
                    else
                        if (point(1,3) - i) > 50
                            if (abs(buff4(i)) >= abs(point(2,1))) & ...
                                    (abs(buff4(i)) >= abs(point(2,2))) & ...
                                    (abs(buff4(i)) >= abs(point(2,3)))
                                point(1,1) = i;
                                point(2,1) = buff4(i);
                                point(1,2) = 0;
                                point(2,2) = 0;
                                point(1,3) = 0;
                                point(2,3) = 0;
                            end
                        elseif sign(point(2,3)) == sign(buff4(i)) % stesso verso
                            if abs(point(2,3)) <= abs(buff4(i)) % il più grande
                                point(1,3) = i;
                                point(2,3) = buff4(i);
                            end
                        elseif abs(buff4(i)) >= abs(point(2,1)) % verso opposto e vicini
                            point(1,1) = point(1,2);
                            point(2,1) = point(2,2);
                            point(1,2) = point(1,3);
                            point(2,2) = point(2,3);
                            point(1,3) = i;
                            point(2,3) = buff4(i);
                        end
                    end
                end
            end
        end
        % determinazione dei picco P
        if point(1,2) == 0 % onda crescente/decrescente
            T = point(1,1) + 14;
        elseif point(1,3) == 0 % onda monofasica +/-
            for z = point(1,1):-1:point(1,2),
                if buff4(z) == 0
                    T = z + 14;
                    break;
                elseif sign(buff4(z)) ~= sign(buff4(z+1))
                    if abs(buff4(z)) > abs(buff4(z+1))
                        T = z + 1 + 14;
                        break;
                    else
                        T = z + 14;
                        break;
                    end
                end
            end
        else % onda bifasica +/-, -/+
            T = point(1,2) + 14;
        end
    end
    T_done = 1;
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
        th_on = .5*abs(point(2,1));
        lim_sx_on = lim_sx;
        lim_dx_on = point(1,1);
        % end
        th_end = .5*abs(point(2,2));
        lim_sx_end = point(1,2);
        lim_dx_end = lim_dx;
    else % onda bifasica
        % on
        th_on = .6*abs(point(2,1));
        lim_sx_on = lim_sx;
        lim_dx_on = point(1,1);
        % end
        th_end = .6*abs(point(2,3));
        lim_sx_end = point(1,3);
        lim_dx_end = lim_dx;
    end
    
    % ricerca on
    for ii = lim_dx_on:lim_sx_on,
        if abs(buff4(ii)) < th_on
            T_on = ii + 14; % comprende la traslazione 14
            break;
        end
    end
    if T_on == 0
        T_on = lim_sx_on + 14;
    end
    
    % ricerca end
    for ii = lim_sx_end:-1:lim_dx_end,
        if abs(buff4(ii)) < th_end
            T_end = ii + 14; % comprende la traslazione 14
            break;
        end
    end
    if T_end == 0
        T_end = lim_dx_end + 14;
    end
end
        

%%%%%%%%%%%%%% aggiornamento del battito %%%%%%%%%%%%
if fb == 1
    if T_done == 1
        R = QRS;
        R_end = QRS_end;
        R_max = ceil(5/9*RR);
        T_done = 0;
    end
elseif fsb == 1
    if T_done == 1
        R = QRS_sb;
        R_end = QRS_end;
        R_max = ceil(5/9*RR);
        T_done = 0;
    end
end


