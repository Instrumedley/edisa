function d_struct = dist_to_average_col2(m)

NumberOfConditions = length(m.conditionnumbers);

for i = 1:NumberOfConditions
  NumberOfTimePoints(i) = length(m.timepoints{i});
end
%NumberOfTimePoints = m.timepoints;


genenumbers = m.genenumbers;
conditionnumbers = m.conditionnumbers;
m=m.submatrix;

NumberOfRows       = size(m,1);
NumberOfColumns    = size(m,2);

pearson_matrix = m;
pearson_matrix(NumberOfRows+1,:) = mean(m);

start =1;
for j = 1:NumberOfConditions
    
  matrix_for_j = pearson_matrix(:, start : start + NumberOfTimePoints(j)-1);
  %matrix_for_j(size(matrix_for_j,1)+1,:) = mean(matrix_for_j(1:50,:));
  
  start=start+NumberOfTimePoints(j);
  
  try
    dist = squareform(Mypdist(matrix_for_j,'correlation'));
    dist_to_av(:,j) = dist(NumberOfRows+1,1:NumberOfRows);  
  catch
    disp('error in pdist: standard deviations too low for some points.')
    %d_struct = struct('pearson_distance', -1);
    %return;  
  end
  
  
end

try
dist_to_av = mean(dist_to_av,2);
catch
    disp('error in pdist: standard deviations too low for some points.')
    d_struct = struct('pearson_distance', -1);
    return; 
end

d_struct = struct('pearson_distance', {dist_to_av}, 'genenumbers', {genenumbers}, 'conditionnumbers', {conditionnumbers});


