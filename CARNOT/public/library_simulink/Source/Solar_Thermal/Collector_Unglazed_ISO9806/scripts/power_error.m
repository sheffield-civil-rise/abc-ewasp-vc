% this m-fonction is the objective one for parameter identification for heatpump model
function e = power_error(p)

global TCh TCc UA

TCh = p(1);
TCc = p(2);
UA = p(3);

sim('validation.mdl');

e = (energies(end,3)-energies(end,2))/energies(end,3);