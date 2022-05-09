% EthyleneGlycolMixture_Vapourpressure

% source: MEglobal Data sheet Ethylene-Glycol, 2008

M = [0 7.966820 1668.210 228.000; ...
    50 7.901886 1691.452 229.778; ...
    70 7.833380 1712.369 231.166; ...
    80 7.775839 1736.188 232.689; ...
    90 7.685032 1792.464 235.836; ...
    95 7.856193 2019.846 251.898; ...
    97 8.123192 2273.083 267.910; ...
    98 8.384100 2493.364 279.584; ...
    99 9.189807 3103.597 309.713; ...
    100 8.212109 2161.907 208.429];

t = -30:150;
mix = M(:,1);
A = M(:,2);
B = M(:,3);
C = M(:,4);

p = exp(A - B./(t+C));

% Log10 (P) = A � B/(T + C)
% P = mm Hg
% T = �C