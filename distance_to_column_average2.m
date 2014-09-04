%distances to the average trajectory in a column
function d_struct = distance_to_column_average2(m, column_average)

matrix=m.submatrix;
%matrix = m;

NumberOfConditions = length(m.conditionnumbers);

for i = 1:NumberOfConditions
   NumberOfTimePoints(i) = length(m.timepoints{i});
end
NumberOfColumns = size(matrix,2);

%append the column average:
start=1;

for i = 1 : NumberOfConditions
  matrix(start:start+NumberOfTimePoints(i)-1,NumberOfColumns+1)=  column_average{i};
  start = start+NumberOfTimePoints(i);
end


%extract trajectories from the columns:
start=1;
for i = 1 : NumberOfConditions
  %conditions(:,:,i) = matrix(start:start+NumberOfTimePoints(i)-1,:);
  conditions{i} = matrix(start:start+NumberOfTimePoints(i)-1,:);
  start = start+NumberOfTimePoints(i);
end


for i = 1: NumberOfConditions
  try
      %distance_matrix = squareform(pdist(conditions(:,:,i)','correlation'));
     
      distance_matrix = squareform(Mypdist(conditions{i}','correlation'));

      d(i)=mean(distance_matrix(NumberOfColumns+1,1:NumberOfColumns));
      
  catch
     disp('error in pdist: standard deviations too low for some points. col')
     %d_struct = struct('pearson_distance', -1);
     %return;
     d(i) = 99; %extremely high value (out of range) --> will definitely be discarded
  end
end

%d_struct=d;
d_struct = struct('pearson_distance', {d}, 'genenumbers', {m.genenumbers}, 'conditionnumbers', {m.conditionnumbers});
