function d_struct = distance_to_average_row(m, average_row)

%matrix=m;
matrix=m.submatrix;
NumberOfRows = size(matrix,1);

matrix(NumberOfRows+1,:)= average_row;
try
  distance_matrix = squareform(Mypdist(matrix,'correlation'));
  d=distance_matrix(NumberOfRows+1,1:NumberOfRows);
catch  
  disp('error in pdist: standard deviations too low for some points. row')
  d_struct = struct('pearson_distance', -1);
  return;
end

%d_struct=d;
d_struct = struct('pearson_distance', {d'}, 'genenumbers', {m.genenumbers}, 'conditionnumbers', {m.conditionnumbers});
