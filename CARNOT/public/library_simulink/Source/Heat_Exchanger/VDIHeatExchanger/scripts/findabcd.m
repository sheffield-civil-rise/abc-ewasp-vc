
OPTIONS = optimoptions('lsqcurvefit','Algorithm','trust-region-reflective');
[X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = lsqcurvefit(@(abcd,R)GEB(abcd,R,NTU),[0.433 1.63 0.267 0.5],R,P,[],[],OPTIONS);