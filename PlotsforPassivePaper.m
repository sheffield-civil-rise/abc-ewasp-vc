load('PassiveHouse_PartRuns.mat')

G3=arrayfun(@(i) mean(fullG2(i:i+60-1)),1:60:length(fullG2)-60+1)'/1000

G5=arrayfun(@(i) mean(fullG2(i:i+30-1)),1:30:length(fullG2)-30+1)'/1000
% jan=H3(1:31*24,1);
% feb=H3(31*24+1:59*24,1);
% mar=H3(59*24+1:90*24,1);
% apr=H3(90*24+1:120*24,1);
% may=H3(120*24+1:151*24,1);
% jun=H3(151*24+1:181*24,1);
% jul=H3(181*24+1:212*24,1);
% aug=H3(212*24+1:243*24,1);
% sep=H3(243*24+1:273*24,1);
% oct=H3(273*24+1:304*24,1);
% nov=H3(304*24+1:334*24,1);
% dec=H3(334*24+1:365*24,1);

jan2=G3(1:31*24,1);
feb2=G3(31*24+1:59*24,1);
mar2=G3(59*24+1:90*24,1);
apr2=G3(90*24+1:120*24,1);
may2=G3(120*24+1:151*24,1);
jun2=G3(151*24+1:181*24,1);
jul2=G3(181*24+1:212*24,1);
aug2=G3(212*24+1:243*24,1);
sep2=G3(243*24+1:273*24,1);
oct2=G3(273*24+1:304*24,1);
nov2=G3(304*24+1:334*24,1);
dec2=G3(334*24+1:365*24,1);

% jan=reshape(jan,[24,31]);
% feb=reshape(feb,[24,28]);
% mar=reshape(mar,[24,31]);
% apr=reshape(apr,[24,30]);
% may=reshape(may,[24,31]);
% jun=reshape(jun,[24,30]);
% jul=reshape(jul,[24,31]);
% aug=reshape(aug,[24,31]);
% sep=reshape(sep,[24,30]);
% oct=reshape(oct,[24,31]);
% nov=reshape(nov,[24,30]);
% dec=reshape(dec,[24,31]);

jan2=reshape(jan2,[24,31]);
feb2=reshape(feb2,[24,28]);
mar2=reshape(mar2,[24,31]);
apr2=reshape(apr2,[24,30]);
may2=reshape(may2,[24,31]);
jun2=reshape(jun2,[24,30]);
jul2=reshape(jul2,[24,31]);
aug2=reshape(aug2,[24,31]);
sep2=reshape(sep2,[24,30]);
oct2=reshape(oct2,[24,31]);
nov2=reshape(nov2,[24,30]);
dec2=reshape(dec2,[24,31]);
% 
% jan=mean(jan,2);
% feb=mean(feb,2);
% mar=mean(mar,2);
% apr=mean(apr,2);
% may=mean(may,2);
% jun=mean(jun,2);
% jul=mean(jul,2);
% aug=mean(aug,2);
% sep=mean(sep,2);
% oct=mean(oct,2);
% nov=mean(nov,2);
% dec=mean(dec,2);

jan2=mean(jan2,2);
feb2=mean(feb2,2);
mar2=mean(mar2,2);
apr2=mean(apr2,2);
may2=mean(may2,2);
jun2=mean(jun2,2);
jul2=mean(jul2,2);
aug2=mean(aug2,2);
sep2=mean(sep2,2);
oct2=mean(oct2,2);
nov2=mean(nov2,2);
dec2=mean(dec2,2);

% annualaverageplot=[jan;feb;mar;apr;may;jun;jul;aug;sep;oct;nov;dec];
annualaverageplot2=[jan2;feb2;mar2;apr2;may2;jun2;jul2;aug2;sep2;oct2;nov2;dec2];
% plot(annualaverageplot)
% hold on
plot(epluselec)
hold on
plot(annualaverageplot2)
xticks([12 36 60 84 108 132 156 180 204 228 252 276])
xticklabels({'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'})
ylabel('Electricity Demand (kW)')
legend({'E+','EWASP'})
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'off';
xticks(24:24:288)
hold off


%%

plot(G3(47*24+1:54*24,1))
%hold on
%plot(H3(47*24+1:54*24,1))
hold on
plot(Epluswinterweek)
legend({'EWASP','E+'})
xlabel('Time (h)')
ylabel('Electricity Demand (kW)')
hold off



%%

subplot(1,2,1)

plot(1:365,h2*24/1000,1:365,h3*24/1000,1:365,h4*24/1000)
 xlim([0 365])
 xlabel('Day')
 ylabel('KWh_{Th} delivered')
 legend({'2 occupants','3 occupants','4 occupants'},'Location','north')
 a1=sum(h2*24/1000)/86
 a2=sum(h3*24/1000)/86
 a3=sum(h4*24/1000)/86
 pbaspect([1 1 1])
 subplot(1,2,2)

plot(1:365,e2*24/1000,1:365,e3*24/1000,1:365,e4*24/1000)
 xlim([0 365])
 xlabel('Day')
 ylabel('KWh_{e} consumed')
 legend({'2 occupants','3 occupants','4 occupants'},'Location','north')
 b1=sum(e2*24/1000)/86
 b2=sum(e3*24/1000)/86
 b3=sum(e4*24/1000)/86
 pbaspect([1 1 1])
 homePath = char(java.lang.System.getProperty("user.home"));
 figPath1 = fullfile(homePath, "Desktop", "CONFPAPERfig1");
 print(figPath1, "-dpng", "-r500");
 
 %%
 subplot(1,2,1)
 plot((T2/1000)+eleconly/1000)
  xlim([0 1440])
 xlabel('Time (min)')
 ylabel('KW_{e}')
  pbaspect([1 1 1])
 subplot(1,2,2)
 
  plot((S2/1000))
  xlim([0 1440])
  xlabel('Time (min)')
 ylabel('KW_{th}')
 
 pbaspect([1 1 1])

 homePath = char(java.lang.System.getProperty("user.home"));
 figPath2 = fullfile(homePath, "Desktop", "CONFPAPERfig2");
 print(figPath2, "-dpng", "-r500"); 