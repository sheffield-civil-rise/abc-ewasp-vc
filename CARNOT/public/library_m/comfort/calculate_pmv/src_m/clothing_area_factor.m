function f_cl = clothing_area_factor(i_cl)
% $Revision: 81 $
% $Author: goettsche $
% $Date: 2016-11-02 14:10:23 +0100 (Mi, 02 Nov 2016) $
% $HeadURL: https://svn.noc.fh-aachen.de/carnot/trunk/public/library_m/comfort/calculate_pmv/src_m/clothing_area_factor.m $
% /* calculation of the clothing area factor - equation (4) of DIN EN ISO 7730:2005 */
%  original name: calculate_f_cl
if (i_cl<=0.078)
	f_cl = 1.00+1.290*i_cl;
else
	f_cl = 1.05+0.645*i_cl;
end