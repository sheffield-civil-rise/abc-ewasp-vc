internal

U=[0
0.5
1
1.5
2
2.5
0
0.5
1
1.5
2
2.5];

T=[-5
    -5
    -5
    -5
    -5
    -5
    1
    1
    1
    1
    1
    1];

z=[1	    1
0.928571429	0.980952381
0.904761905	0.947619048
0.857142857	0.914285714
0.80952381	0.885714286
0.761904762	0.857142857
];

z=z(:);

zInterp=1+0.0023*T-0.06*U+0.005*T.*U-0.00017*U.^2;


%% external

z=[0.261904762
0.261904762
0.266666667
0.285714286
0.30952381
0.333333333
0.261904762
0.280952381
0.3
0.314285714
0.338095238
0.352380952];

zInterp=0.266+0.00215*T+0.018*U+0.00113*T.*U+0.0068*U.^2;
%%
surf(x,y,z)
 %f = fit([x y],z,"poly23")
