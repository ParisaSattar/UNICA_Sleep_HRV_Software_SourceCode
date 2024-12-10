function [C_bin,C_ter,KC_bin]=HRV_Complexity(RR_intervals,fs)
%defining threshold for LZ complexity
RR_intervals=(RR_intervals/fs)*1000;
global fs
for i=1:length(RR_intervals)-1;
    if RR_intervals(i)>= RR_intervals(i+1);
       Sn_bin(1,i)=0;
    else
       Sn_bin(1,i)=1;
    end
end


for i=1:length(RR_intervals)-1;
    if RR_intervals(i)+((0.5/100)*RR_intervals(i))>= RR_intervals(i+1);
       Sn_bin_half(1,i)=0;
    else
       Sn_bin_half(1,i)=1;
    end
end

for i=1:length(RR_intervals)-1;
    if RR_intervals(i)+((1/100)*RR_intervals(i))>= RR_intervals(i+1);
       Sn_bin1(1,i)=0;
    else
       Sn_bin1(1,i)=1;
    end
end

for i=1:length(RR_intervals)-1
    if RR_intervals(i)+((2/100)*RR_intervals(i))>= RR_intervals(i+1)
       Sn_bin2(1,i)=0;
    else
       Sn_bin2(1,i)=1;
    end
end


Sn_bin_Norm=binary_seq_to_string(Sn_bin);
C_bin=calc_lz_complexity(Sn_bin,'exhaustive', 1);
KC_bin=kolmogorov(Sn_bin);

Sn_bin_half_Norm=binary_seq_to_string(Sn_bin_half);
C_bin_half=calc_lz_complexity(Sn_bin_half,'exhaustive', 1);
KC_bin_half=kolmogorov(Sn_bin_half);

Sn_bin1_Norm=binary_seq_to_string(Sn_bin1);
C1_bin=calc_lz_complexity(Sn_bin1,'exhaustive', 1);
KC1_bin=kolmogorov(Sn_bin1);

Sn_bin2_Norm=binary_seq_to_string(Sn_bin2);
C2_bin=calc_lz_complexity(Sn_bin2,'exhaustive', 1);
KC2_bin=kolmogorov(Sn_bin2);



for i=1:length(RR_intervals)-1
    if RR_intervals(i)> RR_intervals(i+1)
       Sn_ter(1,i)=0;
    elseif  RR_intervals(i)< RR_intervals(i+1)
            Sn_ter(1,i)=1;
    else
            Sn_ter(1,i)=2;
    end
end


for i=1:length(RR_intervals)-1
    if RR_intervals(i)+((0.5/100)*RR_intervals(i))> RR_intervals(i+1)
       Sn_ter_half(1,i)=0;
    elseif  RR_intervals(i)+((0.5/100)*RR_intervals(i))< RR_intervals(i+1)
            Sn_ter_half(1,i)=1;
    else
            Sn_ter_half(1,i)=2;
    end
end

for i=1:length(RR_intervals)-1
    if RR_intervals(i)+((1/100)*RR_intervals(i))> RR_intervals(i+1)
       Sn_ter1(1,i)=0;
    elseif  RR_intervals(i)+((1/100)*RR_intervals(i))< RR_intervals(i+1)
            Sn_ter1(1,i)=1;
    else
            Sn_ter1(1,i)=2;
    end
end

for i=1:length(RR_intervals)-1
    if RR_intervals(i)+((2/100)*RR_intervals(i))> RR_intervals(i+1)
       Sn_ter2(1,i)=0;
    elseif  RR_intervals(i)+((2/100)*RR_intervals(i))< RR_intervals(i+1)
            Sn_ter2(1,i)=1;
    else
            Sn_ter2(1,i)=2;
    end
end


Sn_ter_Norm=binary_seq_to_string(Sn_ter);
C_ter=calc_lz_complexity(Sn_ter,'exhaustive', 1);
KC_ter=kolmogorov(Sn_ter);

Sn_ter_half_Norm=binary_seq_to_string(Sn_ter_half);
C_ter_half=calc_lz_complexity(Sn_ter_half,'exhaustive', 1);
KC_ter_half=kolmogorov(Sn_ter_half);

Sn_ter1_Norm=binary_seq_to_string(Sn_ter1);
C1_ter=calc_lz_complexity(Sn_ter1,'exhaustive', 1);
KC1_ter=kolmogorov(Sn_ter1);

Sn_ter2_Norm=binary_seq_to_string(Sn_ter2);
C2_ter=calc_lz_complexity(Sn_ter2,'exhaustive', 1);
KC2_ter=kolmogorov(Sn_ter2);

end

