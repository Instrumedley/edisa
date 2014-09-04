function av = average_column(m)

NumberOfConditions = length(m.conditionnumbers);
for i = 1:NumberOfConditions
   NumberOfTimePoints(i) = length(m.timepoints{i});
end

m=m.submatrix;

NumberOfColumns = size(m,2);

start=1;
for i = 1: NumberOfConditions
  av(i,:) = reshape( m(start:start+NumberOfTimePoints(i)-1,:), 1, NumberOfTimePoints(i)*NumberOfColumns);
  start=start+NumberOfTimePoints(i);
end

av = mean(av);



