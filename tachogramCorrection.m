function RpkLoc_new_final=tachogramCorrection(RpkLoc1)    
    RRint=diff(RpkLoc1); % calculating RR interval
    RRint_mean=mean(RRint);
    RRint=RRint'; % taking transpose
    a20=0.70*RRint_mean; %set threshold for min interval
    %finding index that is extra marked i.e. less than 55% of RRmean

%     prob_idx=nonzeros(prob_idx);
    prob_idx=find(RRint<a20); 

    if isempty(prob_idx)
        RpkLoc_new=RpkLoc1; % generating new variable so it will be compared with next threshold for long RR intervals
    else
        prob_idx=prob_idx+1;
        RpkLoc_new=RpkLoc1;

       if prob_idx(end)>=length(RRint)
        for i=1:length(prob_idx)-1
            if RRint(prob_idx(i)-1)>RRint(prob_idx(i)+1)
                RpkLoc_new(prob_idx(i)-1)=0; % removing extra or short annotations
            else
                RpkLoc_new(prob_idx(i))=0;
            end
            
        end
       
       else

        for i=1:length(prob_idx)
            if RRint(prob_idx(i)-1)>RRint(prob_idx(i)+1)
                RpkLoc_new(prob_idx(i)-1)=0; % removing extra or short annotations
            else
                RpkLoc_new(prob_idx(i))=0;
            end
        end
       end
        %disp(['Discarting correction at case ',num2str(ipk)])
     end

    
    RpkLoc_new=nonzeros(RpkLoc_new);
    %RpkLoc_new is the new Rpeak location variables that should be compared to
    %identify long intervals
    new_RRint=diff(RpkLoc_new);
    new_RRint_mean=mean(new_RRint);
    new_RRint_median=median(new_RRint);
    a30=1.5*new_RRint_mean;   %set threshold for max interval length

    %finding indexes that are larger than 150% RRmean

    new_prob_idx=0;
    for i=1:length(new_RRint)
        if  new_RRint(i)>a30 % comparing RR intervals with threshold
            new_prob_idx(i)=i;
        end
    end

    new_prob_idx=nonzeros(new_prob_idx);
    l_new_prob_idx=length(new_prob_idx);
    new_len_prob_idx=0;
    %conditions when nothing needs to be corrected
    if l_new_prob_idx==0 % this if will end at line 158 so it will save the matrix in the same cell
        RpkLoc_new_final=RpkLoc_new;

    else
        %disp(['Adding correction at case ',num2str(ipk)])
        for i=1:length(new_prob_idx)
            if  new_RRint(new_prob_idx(i))>=1.5*new_RRint_mean && RRint(new_prob_idx(i))<=2.5*new_RRint_mean %when one R peak is missing
                new_len_prob_idx(i,1)=1;
            elseif  RRint(new_prob_idx(i))>=2.5*new_RRint_mean &&  RRint(new_prob_idx(i))<=3.5*new_RRint_mean %when two R peaks are missing
                new_len_prob_idx(i,1)=2;
            elseif  RRint(new_prob_idx(i))>3.5*new_RRint_mean &&  RRint(new_prob_idx(i))<=4.5*new_RRint_mean %when three R peaks are missing
                new_len_prob_idx(i,1)=3;
            elseif  RRint(new_prob_idx(i))>4.5*new_RRint_mean  %when more than three R peaks are missing
                len_prob_idx(i,1)=4;
            else
                new_len_prob_idx(i,1)=0;
            end
        end


        %new_len_prob_idx=new_len_prob_idx';
        prob_mat=[new_len_prob_idx, new_prob_idx]; %concating matrix with to have index a
        % nd number of peaks need to add at perticular index
        prob_mat=sortrows(prob_mat); % sorting is necessary because it will help 
        % to identify the new index when we need to add extra peak see code at line 121


        % finding values and indexes to append the matrix
        i=0;
        a_Rloc=new_prob_idx';
        j=0;
        k=0;
        l=0;
        ib1dx=[];
        b1=[1];
        nb1=find(new_len_prob_idx==1);
        nb1=numel(nb1);
        vb1=[];
        ib1dx=[];
        b2=[1 2];
        nb2=find(new_len_prob_idx==2);
        nb2=numel(nb2);
        vb2=[];
        ib2dx=[];
        b3=[1,2 3];
        nb3=find(new_len_prob_idx==3);
        nb3=numel(nb3);
        vb3=[];
        ib3dx=[];

        for i=1:length(a_Rloc) %run the loop to the length of missing values
            if  prob_mat(i,1)==1 %when there is one value to add
                l=l+1;
                nn=1:1:1*nb1;
                vb1(1:nn(l))=[a_Rloc(i)+b1, vb1];
                dectdiff=RpkLoc_new(new_prob_idx(i)+1)-RpkLoc_new(new_prob_idx(i));
                ib1dx(1:nn(l))=[RpkLoc_new(new_prob_idx(i))+round(dectdiff/2),ib1dx];
            elseif prob_mat(i,1)==2 %when there is 2 value to add
                k=k+1;
                nn=2:2:2*nb2;
                vb2(1:nn(k))=[a_Rloc(i)+b2, vb2];
                ib2dx(1:nn(k))=[RpkLoc_new(new_prob_idx(i))+round(new_RRint_median),RpkLoc_new(new_prob_idx(i))+round(2*new_RRint_median)];
            elseif prob_mat(i,1)==3 %when there is 3 value to add
                j=j+1;
                nnn=3:3:3*nb3;
                vb3(1:nnn(j))=[a_Rloc(i)+b3, vb3];
                ib3dx(1:nnn(j))=[RpkLoc_new(new_prob_idx(i))+round(new_RRint_median),RpkLoc_new(new_prob_idx(i))+round(2*new_RRint_median),RpkLoc_new(new_prob_idx(i))+round(3*new_RRint_median)];
            elseif prob_mat==0;
                RpkLoc_new(new_prob_idx(i))=RpkLoc_new(new_prob_idx(i));
            end
        end



        RpkLoc_new=RpkLoc_new';
        a_Rloc=[vb1,vb2,vb3]; % index of R_locations
        val_Rloc=[ib1dx, ib2dx, ib3dx]; % values of R locations
        miss_a_Rloc=[a_Rloc' val_Rloc'];
        miss_a_Rloc=sortrows(miss_a_Rloc);
        a_Rloc=miss_a_Rloc(:,1);
        val_Rloc=miss_a_Rloc(:,2);

        RpkLoc_new_final=RpkLoc_new;
        for i=0:length(a_Rloc)-1
            RpkLoc_new_final=[RpkLoc_new_final(1:length(RpkLoc_new_final) < a_Rloc(length(a_Rloc)-i)),val_Rloc(length(a_Rloc)-i) , RpkLoc_new_final(1:length(RpkLoc_new_final) >= a_Rloc(length(a_Rloc)-i))];
        end
        RpkLoc_new_final=RpkLoc_new_final';
        

    end


RpkLoc_new_final;
end