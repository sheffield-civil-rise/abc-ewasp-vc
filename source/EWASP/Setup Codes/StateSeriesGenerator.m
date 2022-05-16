function StateSeries = StateSeriesGenerator(Start,End,multiStateActive)

yout=ones(24,1);

if or(Start > 23, End > 23)
    error('Start or End Hour is greater that 23')
elseif or(Start < 0, End < 0)
        error('Start or End Hour is less than 0')
else
        
end

if multiStateActive == 1

    if End<Start
        
        End=End+24;
        
        yout(Start:End,1)=2;
        
        yout(1:end-24,1)=yout(25:end,1);
        
        yout=yout(1:24,1);
    else 
        
        yout(Start:End,1)=2;
        yout=yout(1:24,1);
        
    end
    
else
    
end

StateSeries=repmat(kron(yout,ones(60,1)),365,1);