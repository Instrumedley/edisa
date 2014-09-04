%computes the distance of each gene-time trajectory to the average gene-time
%trajectory:
function d = distance_to_average_genes (mat, average_trajectories)

%matrix = mat;
matrix=mat.submatrix;
NumberOfTimePoints = 6;
NumberOfRows = size(matrix,1);
NumberOfColumns = size(matrix,2);
NumberOfConditions = NumberOfRows/NumberOfTimePoints;

start=1;
for i=1:NumberOfConditions;
  
  %get the trajectories:
  current_gene_profile = matrix(start:start+NumberOfTimePoints-1,:);
  pearson_matrix = current_gene_profile;
  %append the average trajectory:
  pearson_matrix(:,NumberOfColumns+1)=average_trajectories(:,i);
  dist = squareform(Mypdist(pearson_matrix','correlation'));
  
  %distances to the average are in the bottom row of the correlation
  %matrix:
  dist_to_average(i,:) = dist(NumberOfColumns+1,1:NumberOfColumns); 
  
  start=start+NumberOfTimePoints;
end

%d=dist_to_average;
d = struct('pearson_distance', {dist_to_average},'genenumbers', {mat.genenumbers},'conditionnumbers', {mat.conditionnumbers});


%old version:
%NumberOfColumns=size(matrix.submatrix,2);
%pearson_matrix = matrix.submatrix;
%pearson_matrix(:,NumberOfColumns+1) = average_matrix;

%dist = squareform(pdist(pearson_matrix','correlation'));

%this gives back the bottom row of the pairwise Pearson distance matrix:
%d = struct('pearson_distance', {dist(NumberOfColumns+1,1:NumberOfColumns)},'genenumbers', {matrix.genenumbers},'conditionnumbers', {matrix.conditionnumbers});
