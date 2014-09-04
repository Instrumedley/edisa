function s = score(E,dataset,c,g, coherent)

NumberOfConditions = length(c);
for i = 1:NumberOfConditions
  NumberOfTimePoints(i) = length(find(E.timepoints{i}==1));
end

%timepoints of the whole dataset:
for i = 1:length(dataset.timepoints)
  DatasetTimePoints(i) = length(find(dataset.timepoints{i}==1));
end

tp  = zeros(1,sum(NumberOfTimePoints));

for i = 1:NumberOfConditions
    index_offset = sum(NumberOfTimePoints(1:i-1))+1;
    value_offset = sum(DatasetTimePoints(1:c(i)-1))+1;
    
    tp(index_offset:index_offset+NumberOfTimePoints(i)-1) = value_offset:value_offset+DatasetTimePoints(c(i))-1;
end

if strcmp(coherent,'coherent')  
  %Pearson on all trajectories:
  %dev = bicluster_dev( extract_all_trajectories(dataset.submatrix(dataset.genes_internal(g),tp), NumberOfTimePoints) );
else %IR clusters:   
        

 start = 1;
 for i= 1:NumberOfConditions
     
   dev_c(i) = bicluster_dev(dataset.submatrix(dataset.genes_internal(g),tp(start:start+NumberOfTimePoints(i)-1)) );
   start = start + NumberOfTimePoints(i);
 end
 
end
 
 s = mean(dev_c);