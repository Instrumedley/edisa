function m = centroid(dataset, genes, conditions)

NumberOfTimePoints = length(dataset.timepoints);

tp = zeros(1,length(conditions)*NumberOfTimePoints);

c = conditions*NumberOfTimePoints;

for i = 1:NumberOfTimePoints
  tp(i:NumberOfTimePoints:length(tp)) = c+i-NumberOfTimePoints;
  tpname(i:NumberOfTimePoints:length(tp)) = c/NumberOfTimePoints;
end


m = mean(dataset.submatrix(genes, tp));