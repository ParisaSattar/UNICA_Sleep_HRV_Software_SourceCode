function [f, QRS] = zero_blanking(fz, zero);

% dichiarazione delle variabili globali
global QRS_buff;
global RR;
global RR_buff;
global max3c max1c;
global last_couple1;
global last_couple3;
global reference;
global sb_start;

% aggiornamento del buffer dei complessi QRS rilevati
QRS_buff = QRS_buff + 1;

% procedura
f = 0;
QRS = 0;
if fz == 1
    if (QRS_buff(1) - zero) > 30
        f = 1;
        QRS = zero;
    end
end

% aggiornamento dei parametri di sistema
if f == 1
    QRS_buff = [QRS, QRS_buff(1)];
    RR_buff = [(QRS_buff(2) - QRS_buff(1)), RR_buff(1:7)];
    RR = ceil(sum(RR_buff)/8);
    last_couple3 = max3c;
    last_couple1 = max1c;
    reference = QRS;
    sb_start = QRS - ceil(RR/2);
end
