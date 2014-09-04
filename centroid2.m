function m = centroid2(dataset, genes, conditions)


%timepoints of the current module
NumberOfConditions = length(conditions);
for i = 1:NumberOfConditions
  NumberOfTimePoints(i) = length(dataset.timepoints{conditions(i)});
end

%timepoints of the whole dataset:
for i = 1:length(dataset.timepoints)
  DatasetTimePoints(i) = length(dataset.timepoints{i});
end


tp = zeros(1,sum(NumberOfTimePoints));



for i = 1:length(conditions)
    index_offset = sum(NumberOfTimePoints(1:i-1))+1;
    value_offset = sum(DatasetTimePoints(1:conditions(i)-1))+1;
    
    tp(index_offset:index_offset+NumberOfTimePoints(i)-1) = value_offset:value_offset+DatasetTimePoints(conditions(i))-1;
end

m = mean(dataset.submatrix(genes, tp));