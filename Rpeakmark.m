function [R_pos] = Rpeakmark(ECG_ext, start_epoch, stop_epoch, fs, debugging, ECGr, seconds_of_tolerance,SubjectName,Tol_seg,segNo,Phase_Name);


fs_actual=fs;
fs_required=250;
[no_s, fac_of_rs]=rat(fs_required/fs);
ECGra = resample(ECG_ext,no_s,fac_of_rs); %%% resampling @256
[R_pos256, QRS_on_pos256, QRS_end_pos256, T_pos256, T_on_pos256, T_end_pos256, P_pos256, P_on_pos256, P_end_pos256] = system_novar(ECGra,SubjectName,Tol_seg,segNo,Phase_Name);

%resampling to original fs
Converted_fs=256;
fac=round(Converted_fs/fs);
R_loc = round(R_pos256* fac_of_rs / no_s);



%%% Extracting signal of interest
len = length(ECGr); % Taking the length of added mirrored signal
Rstar=len; % start index of signal of interest 
Rstop=len+len; % stop index of signal of interest 
R_ext=R_loc; % location of R peaks marked by delineating my ecg 
R_ext1_idx= R_ext>Rstar; % extracting locations of signal of interest after 1st mirror signal
R_ext1=R_ext(R_ext1_idx); % extracting indexs of locations of signal of interest after 1st mirror signal 
R_ext2_idx= R_ext1<Rstop; % extracting locations of signal of interest after 2nd mirror signal
RpkLoc1=R_ext1(R_ext2_idx);% extracting indexs of locations of signal of interest after 2nd mirror signal 
RpkLoc1=RpkLoc1-len;% Re-indexing
R_pos=RpkLoc1;

sign_ECG=ECGr(R_pos);
numPositives = sum(sign_ECG > 0);
numNegatives = sum(sign_ECG < 0);
win_ms=round(fs*(20/1000));
win=max(10,win_ms);

R_pos=R_pos(2:end-1);
if numPositives > numNegatives
    for ir=1:length(R_pos)
        [~,ind(ir,1)]=max(ECGr((R_pos(ir)-win:R_pos(ir)+win)));
        new_Rloc(ir,1)=ind(ir,1)-1+R_pos(ir)-win;
        clear ind
    end
    %R_pos=[];
    %R_pos=new_Rloc';
    elseif numNegatives > numPositives
        for ir=1:length(R_pos)
        [~,ind(ir,1)]=min(ECGr((R_pos(ir)-win):R_pos(ir)+win));
        new_Rloc(ir,1)=ind(ir,1)-1+R_pos(ir)-win;
        clear ind
    end
    %R_pos=[];
    %R_pos=new_Rloc';
end
R_pos=[];
R_pos=tachogramCorrection(new_Rloc);
R_pos=R_pos';    
    
    
    if debugging
    time=(0:length(ECGra)-1)/fs;
    figure
    plot(time,ECGra)
    ylabel('ECG-2048Hz')
    hold on
    plot((R_pos-1)/fs, ECGra(R_pos),'*m')
    plot((QRS_end_pos-1)/fs, ECGra(QRS_end_pos),'om')
    plot((QRS_on_pos-1)/fs, ECGra(QRS_on_pos),'dm')
    
    hold on
    plot((T_pos-1)/fs, ECGra(T_pos),'*k')
    plot((T_end_pos-1)/fs, ECGra(T_end_pos),'ok')
    plot((T_on_pos-1)/fs, ECGra(T_on_pos),'dk')
    
    plot((P_pos-1)/fs,  ECGra(P_pos),'*g')
    plot((P_end_pos-1)/fs, ECGra(P_end_pos),'og')
    plot((P_on_pos-1)/fs, ECGra(P_on_pos),'dg')

    legend('ECGra','R','Rf','Ri','T','Tf','Ti','P','Pf','Pi')

end
