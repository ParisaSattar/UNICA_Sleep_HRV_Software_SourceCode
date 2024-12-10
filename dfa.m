function [alpha, alpha1, alpha2, n, F_n]=dfa(data,n1,n2,breakpoint,fs,plotting)

global px3 NA_Tab 

%DFA(IBI,nn) - calculates alpha from detrended fluctuation analysis
%
%Inputs:    y = inter-beat interval signal (s)
%           n1,n2 = limits of window sizes
%           breakpoint = value of n that determines where alpha1 ends and
%           alpha2 begins
%           
%Outputs:   alpha = slope of log-log plot of integrated y vs window size.
%
%Example:   alpha=DFA(y,4,300)
%
% Reference: Heart rate analysis in normal subjects of various age groups
% Rajendra Acharya U*, Kannathal N, Ong Wai Sing, Luk Yi Ping and
% TjiLeng Chua

    if nargin < 4 || isempty(breakpoint); breakpoint=13; end
    if nargin < 3
       n1=4;
       n2=300;
       breakpoint=13;
    end
    data=data/fs;
    [r c]=size(data);
    if r>c; data=data'; end
    
    n=[n1:1:n2]; %array of window sizes
    nLen=length(n);

    %preallocate memory
    F_n=zeros(1,nLen);        

    mu=mean(data); %mean value
    
    for i=1:nLen
        N=length(data);
        nWin=floor(N/n(i)); %number of windows
        N1=nWin*n(i); %length of data minus rem
        
        %preallocate memory
        yk=zeros(1,N1);
        Yn=zeros(1,N1);
        %fitcoef=zeros(2,n(i)); 
        
        yk=cumsum(data(1:N1)-mu); %integrate        
        
        for j=1:nWin
            %linear fit coefs
            p=polyfit(1:n(i),yk(((j-1)*n(i)+1):j*n(i)),1);
            %create linear fit
            Yn(((j-1)*n(i)+1):j*n(i))=polyval(p,1:n(i));
        end
        
        % RMS fluctuation of integraged and detrended series
        F_n(i) = sqrt( sum((yk-Yn).^2)/N1 );
    end
    
    %fit all values of n
    a=polyfit(log10(n),log10(F_n),1);
    
    bp=find(n==breakpoint);
    %fit short term n=1:bp
    a1=polyfit(log10(n(1:bp)),log10(F_n(1:bp)),1);
    %fit long term n=bp+1:end
    a2=polyfit(log10(n(bp+1:end)),log10(F_n(bp+1:end)),1);
    
%     lfit=polyval(a,log10(n));
%     figure; loglog(n,F_n)
%     hold on; loglog(n,10.^lfit,'r')

    alpha=round(a.*1000)./1000; % total slope
    alpha1=round(a1.*1000)./1000; % short range scaling exponent
    alpha2=round(a2.*1000)./1000; % long range scaling exponent
    F_n=F_n';
    n=n';
    
    
    if plotting==1
        if exist('px3','var')
            delete(px3)
            
        end
    px3 = axes('Parent', NA_Tab, 'Position', [0.6 0.09 0.34 0.44], 'Visible', 'on');
    
    axes(px3); % Set the current axes to px3
    loglog(n, F_n, 'b', 'DisplayName', 'F(n)'); % log-log plot of F_n
    hold on;
    loglog(n, 10.^(polyval(polyfit(log10(n), log10(F_n), 1), log10(n))), 'r', 'DisplayName', '\alpha');
    loglog(n(1:breakpoint-n1+1), 10.^(polyval(polyfit(log10(n(1:breakpoint-n1+1)), log10(F_n(1:breakpoint-n1+1)), 1), log10(n(1:breakpoint-n1+1)))), 'k--*', 'DisplayName', '\alpha1');
    loglog(n(breakpoint-n1+2:end), 10.^(polyval(polyfit(log10(n(breakpoint-n1+2:end)), log10(F_n(breakpoint-n1+2:end)), 1), log10(n(breakpoint-n1+2:end)))), 'm--o', 'DisplayName', '\alpha2');
    xlabel(px3,'box size');
    ylabel(px3,'F(n)');
    legend('show');
    tb = axtoolbar(px3,{'zoomin','zoomout','rotate','restoreview','pan','datacursor'});

    hold off;
    end
    
end