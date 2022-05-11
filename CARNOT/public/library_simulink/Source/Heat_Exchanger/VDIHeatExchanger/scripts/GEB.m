function P=GEB(abcd,R,NTU)
%Gleichung zur Einheitlichen Berechnung von Wärmetauschern nach
%VDI-Wärmeatlas C1 3.4


a=abcd(1,1);
b=abcd(1,2);
c=abcd(1,3);
d=abcd(1,4);

F=1./((1+a*R.^(d*b).*NTU.^b).^c);
E=(R-1).*NTU.*F;
P=(1-exp(E))./(1-R.*exp(E));
[rows,cols,~] = find(R==1); 
for i=1:size(rows)
    P(rows(i),cols(i))=NTU(rows(i),cols(i))*F(rows(i),cols(i))/(1+NTU(rows(i),cols(i))*F(rows(i),cols(i)));

end
