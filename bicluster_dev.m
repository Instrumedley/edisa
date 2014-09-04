%computes the intracluster variance for the given dataset (cluster):
function ivs = bicluster_dev(dataset)

%centroid = mean (dataset);
centroid = dataset(1,:);

data_matrix = dataset;
data_matrix(size(data_matrix,1)+1,:) = centroid;

try
  
  distance  = Mypdist(data_matrix, 'correlation');
  distance_matrix = squareform(distance);
  
  %we only need the last column: pearson distances of all genes against the
  %centroid:
  
  %standard deviation:
  ivs = sum( distance_matrix(size(distance_matrix,1),:).^2);
  ivs = sqrt( ivs * (1/ ( size(distance_matrix,1) -1 -1 )) );  % 1/(n-1)   -1 because of the centroid
  
catch
  ivs=9999999;
end


