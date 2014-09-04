%randomly picks a gene from the dataset and returns the n nearest
%neighbours under a randomly chosen condition:
function neighbours = n_neighbours_under_c2(dataset,GeneSubset, n,PearsonDistanceMatrix)

%NumberOfGenes        = size(dataset.submatrix,1);
%sample only from a 1/3 subset of the data matrix:
%GeneSubset           = randomgenes(floor(NumberOfGenes/3), NumberOfGenes); 

g = randsample(GeneSubset,1); %choose a random gene from the subset

p_dist = PearsonDistanceMatrix;

[value, index] = sort(p_dist(g,:));

neighbours = index(1:n); %the n nearest neighbours including g itself

%plot(dataset.submatrix(neighbours,:)');
