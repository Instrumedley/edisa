function d_struct = distance_to_average_column(m, average_column)


NumberOfConditions = length(m.conditionnumbers);
for i = 1:NumberOfConditions
   NumberOfTimePoints(i) = length(m.timepoints{i});
end

matrix=m.submatrix;

NumberOfColumns = size(matrix,2);

start=1;
for i = 1: NumberOfConditions
  cols(i,:) = reshape( matrix(start:start+NumberOfTimePoints(i)-1,:), 1, NumberOfTimePoints(i)*NumberOfColumns);
  start=start+NumberOfTimePoints(i);
end

cols(NumberOfConditions+1,:) = average_column;
distance_matrix = squareform(Mypdist(cols,'correlation'));
d=distance_matrix(NumberOfConditions+1,1:NumberOfConditions);

%d_struct=d;
d_struct = struct('pearson_distance', {d}, 'genenumbers', {m.genenumbers}, 'conditionnumbers', {m.conditionnumbers});







