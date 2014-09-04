function d_struct = dist_to_average_col(m)

NumberOfTimePoints = length(find(m.timepoints==1));

genenumbers = m.genenumbers;
conditionnumbers = m.conditionnumbers;
m=m.submatrix;

NumberOfRows       = size(m,1);
NumberOfColumns    = size(m,2);
NumberOfConditions = NumberOfColumns/NumberOfTimePoints; 


pearson_matrix = m;
pearson_matrix(NumberOfRows+1,:) = mean(m);


for j = 1:NumberOfConditions
  matrix_for_j = pearson_matrix(:,NumberOfTimePoints*(j-1)+1 : NumberOfTimePoints*(j-1)+NumberOfTimePoints);
  
  try
    dist = squareform(Mypdist(matrix_for_j,'correlation'));
  catch
    disp('error in pdist: standard deviations too low for some points.')
    d_struct = struct('pearson_distance', -1);
    return;
  end
  
  dist_to_av(:,j) = dist(NumberOfRows+1,1:NumberOfRows);
end

dist_to_av = mean(dist_to_av,2);


d_struct = struct('pearson_distance', {dist_to_av}, 'genenumbers', {genenumbers}, 'conditionnumbers', {conditionnumbers});


