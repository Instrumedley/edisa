%From
cols1 = 1:6;
rows = 1:50;

%To
cols2 = 25:30;
rows2 = 51:100; 


shift = -2;
mult = -1;

noiseA.submatrix(rows2, cols2) = mult*noiseA.submatrix(rows, cols1)+shift;
noiseB.submatrix(rows2, cols2) = mult*noiseB.submatrix(rows, cols1)+shift;
noiseC.submatrix(rows2, cols2) = mult*noiseC.submatrix(rows, cols1)+shift;
noiseD.submatrix(rows2, cols2) = mult*noiseD.submatrix(rows, cols1)+shift;
noiseE.submatrix(rows2, cols2) = mult*noiseE.submatrix(rows, cols1)+shift;
noiseF.submatrix(rows2, cols2) = mult*noiseF.submatrix(rows, cols1)+shift;