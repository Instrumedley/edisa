function [sample_set, GeneSubset] = gedisa_sample6b(E, sample_size, GeneSubset, PearsonDistanceMatrix)

NumberOfGenes = size(E.submatrix,1);
AllGenes      = [1:NumberOfGenes];
sample        = floor(NumberOfGenes/3);

%optional: sampling without replacement:
%---------------------------------------
%if size(GeneSubset,2) > sample
%  g = randsample(AllGenes(GeneSubset),sample);
%else
%   GeneSubset = AllGenes; %the set is empty --> start again 
%   g = randsample(AllGenes(GeneSubset),sample);
%end

g=AllGenes;

%if g<100 
    %disp('too few genes for this sampling method')
    %return;
%end
   
for i = 1:10
  sample_set{i} = n_neighbours_under_c3(E, g, sample_size, PearsonDistanceMatrix);
end

GeneSubset = setdiff(GeneSubset,g);
