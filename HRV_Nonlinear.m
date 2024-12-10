function [alpha,alpha1, alpha2, n, F_n,AE,SE]=HRV_Nonlinear(RR_intervals,m, r,fs,n1,n2,bkp,plotting)
AE=ApEn( m, r, RR_intervals);
SE=SampEn(m, r, RR_intervals);
RR_intervals=((RR_intervals)/fs)*1000;
[alpha, alpha1, alpha2, n, F_n]=dfa(RR_intervals,n1,n2,bkp,fs,plotting);
RR_intervals=(RR_intervals*fs)/1000;
end

