%intra-column average:
function av = column_average2(m)

%matrix=m;
matrix = m.submatrix;

NumberOfConditions = length(m.conditionnumbers);

for i = 1:NumberOfConditions
   NumberOfTimePoints(i) = length(m.timepoints{i});
end


start=1;
for i=1:NumberOfConditions;
   av{i,:} = mean(matrix(start:start+NumberOfTimePoints(i)-1,:),2);
   start=start+NumberOfTimePoints(i);
end




