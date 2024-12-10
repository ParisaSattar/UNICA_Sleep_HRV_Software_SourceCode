function [HR, NN_mean,stdnn,sdsd,rmssd,R50,R20,pR50,pR20]=HRV_TimeDomain(RR_intervals,fs)


%% All time domain parameters
RR_intervals_sec = RR_intervals / fs;
total_time_sec = sum(RR_intervals_sec);
num_beats = length(RR_intervals_sec);
RR_intervals=(RR_intervals/fs)*1000;
NN_mean=mean(RR_intervals);% Calculating mean of RR intervals
HR= round((num_beats / total_time_sec) * 60); % Calculating Heart Rate
stdnn=std(RR_intervals);% Calculating standard deviation of RR intervals
RR_diff=diff(RR_intervals);% Calculating Difference of adj RR interval
sdsd=std(RR_diff);%Calculating standard deviation of Difference between adj RR interval
% Calculating RMSSD
sq_RR_diff=(RR_diff.^2);%  Calculating square of (Difference of RR intervals)
sum_sq_RR_diff=sum(sq_RR_diff); %Calculating sum of square of (Difference of adj RR intervals)
rmssd=sqrt(sum_sq_RR_diff/(numel(RR_diff))); % Calculating  (Difference of adj RR intervals)


% Calculating Number of pairs of adjacent NN intervals differing by more than 50 ms and 20ms
R50=0;
R20=0;
%RR_intervals=RR_intervals';
diff_adj=abs(diff(RR_intervals));
R50=sum(diff_adj>50);
R20=sum(diff_adj>20);
% for i=1:(length(RR_intervals)-1)
% if (RR_intervals(1,i+1)-RR_intervals(1,i))>50
%    R50=R50+1;
% elseif (RR_intervals(1,i+1)-RR_intervals(1,i))>20
%      R20=R20+1;
% end
% end
%RR50 count divided by the total number of all RR intervals
pR50=R50/length(RR_intervals)*100;
pR20=R20/length(RR_intervals);
RR_intervals=(RR_intervals*fs)/1000;
end