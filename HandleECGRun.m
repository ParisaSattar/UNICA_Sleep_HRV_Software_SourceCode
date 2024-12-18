function HandleECGRun(phase_segmented_ecg,Phase_Name,phases)
global fs SubjectName ECG_Filter
    Segment_Numbers=[];
    ECGr=[];
    if isempty(phase_segmented_ecg)
       i=1;
       Segment_Numbers{i,1}=['Subject ', SubjectName,' has no ' Phase_Name 'phase'];
       T=table(Segment_Numbers);
       Outputfile_Name = SubjectName;
       Outputfile_Name = sprintf('%s_%s.xlsx', Phase_Name, Outputfile_Name);
       writetable(T, Outputfile_Name, 'Sheet', 1);
    else
        for i=1:length(phase_segmented_ecg)
            Tol_seg=length(phase_segmented_ecg);
            segNo=i;
            ECGr = phase_segmented_ecg{i,1};
%             % Filtering
%             order = 4;
%             low_cutoff = 0.67;
%             high_cutoff = 100;
%             nyquist = fs / 2;
%             low_cutoff_norm = low_cutoff / nyquist;
%             high_cutoff_norm = high_cutoff / nyquist;
%             [b, a] = butter(order, [low_cutoff_norm, high_cutoff_norm], 'bandpass');
%             ECGr = filtfilt(b, a, ECGr);
            ECG_len30=length(ECGr);
            if ECG_len30>30
                len = length(ECGr);
                % Adding mirrored signal before and after signal
                ECG_ext=wextend('1D','per',ECGr,len,'b');
                % taking complete signal for annotation
                start_epoch=1;
                stop_epoch=length(ECG_ext);
                % set debugging to 0 if no other visual output is required otherwise 1
                debugging=0;
                % These value does not impact the code this is just to satisfy the function requirement
                R_alignment=0;
                seconds_of_tolerance = 0;
                try
                    R_pos = Rpeakmark(ECG_ext, start_epoch,...
                        stop_epoch, fs, debugging, ECGr, seconds_of_tolerance,SubjectName,Tol_seg,segNo,Phase_Name);
                catch ME
                    Segment_Numbers{i,1}=['Segment ', num2str(i),' error occured in Repak annotation, check the signal quality'];
                    continue;
                end
            else
                Segment_Numbers{i,1}=['Segment ', num2str(i),' is less than 30 secs: HRV analysis not recommended, not analyzed'];
                continue;
            end


            All_R_pos{i,1}=R_pos;
            RR_intervals=diff(All_R_pos{i,1});
            try
            [HR(i,1), NN_mean(i,1),stdnn(i,1),sdsd(i,1),...
                rmssd(i,1),R50(i,1),R20(i,1),pR50(i,1),pR20(i,1)]=HRV_TimeDomain(RR_intervals,fs);
            [aVLF(i,1), aLF(i,1), aHF(i,1), nLF(i,1),nHF(i,1),lfhf(i,1)]=HRV_FrequencyDomain(R_pos,RR_intervals,fs)
            m=2;
            r=0.2*std(RR_intervals);
            n1=4;n2=11;bkp=16;
            [a,a1, a2, n, F_n,AE(i,1),SE(i,1)]=HRV_Nonlinear(RR_intervals,m, r,fs,n1,n2,bkp,0);
            alpha(i,1)=a(1);
            beta(i,1)=a(2);
            alpha1(i,1)=a(1);
            beta1(i,1)=a(2);
            alpha2(i,1)=a(1);
            beta2(i,1)=a(2);
            [C_bin(i,1),C_ter(i,1),KC_bin(i,1)]=HRV_Complexity(RR_intervals,fs);
            [SD1(i,1),SD2(i,1),SD12(i,1)]=HRV_Poincare(RR_intervals,0);
            catch ME
                Segment_Numbers{i,1}=['Segment ', num2str(i),' error occured in HRV analysis, check the signal quality/length'];
               continue;
            end
            Segment_Numbers{i,1}=['Segment', num2str(i)];
            ECG_Signal{i,1}=ECGr;
            Rpeak_Locs{i,1}=R_pos';
            R_pos=[];
            T1=table(ECG_Signal,Rpeak_Locs);
            Outputfile_Name = SubjectName;
            Outputfile_Name = sprintf('%s_%s.mat',Phase_Name, Outputfile_Name);
            save(Outputfile_Name,'T1','-v7.3')
            Phase_onset=phases(1:i,1);
            Phase_offset=phases(1:i,2);
            T=table(Phase_onset,Phase_offset,Segment_Numbers,HR, NN_mean,stdnn,sdsd,...
                rmssd,R50,R20,pR50,pR20,aVLF, aLF, aHF, nLF,nHF,lfhf,...
                alpha,beta, alpha1,beta1,alpha2,beta2,AE,SE,C_bin,C_ter,KC_bin,...
                SD1,SD2,SD12);
            Outputfile_Name = SubjectName;
            Outputfile_Name = sprintf('%s_%s.xlsx',Phase_Name, Outputfile_Name);
            writetable(T, Outputfile_Name, 'Sheet', 1);
        end
        clear ECG_Signal Rpeak_Locs;
    end
end