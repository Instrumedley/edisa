function d_struct = distance_to_column_average(m, column_average)

matrix=m.submatrix;
%matrix = m;

NumberOfTimePoints = length(find(m.timepoints==1));
NumberOfConditions = size(matrix,1)/NumberOfTimePoints;
NumberOfColumns = size(matrix,2);

%append the column average:
start=1;
for i = 1 : NumberOfConditions
  matrix(start:start+NumberOfTimePoints-1,NumberOfColumns+1)=  column_average(i,:);
  start = start+NumberOfTimePoints;
end


%extract trajectories from the columns:
start=1;
for i = 1 : NumberOfConditions
  conditions(:,:,i) = matrix(start:start+NumberOfTimePoints-1,:);
  start = start+NumberOfTimePoints;
end


for i = 1: NumberOfConditions
  try
      distance_matrix = squareform(Mypdist(conditions(:,:,i)','correlation'));
      d(i)=mean(distance_matrix(NumberOfColumns+1,1:NumberOfColumns));
     
  catch
     disp('error in pdist: standard deviations too low for some points. col')
     d_struct = struct('pearson_distance', -1);
     return;
  end
end
  
%d_struct=d;
d_struct = struct('pearson_distance', {d}, 'genenumbers', {m.genenumbers}, 'conditionnumbers', {m.conditionnumbers});
