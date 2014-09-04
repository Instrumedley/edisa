%intra-column average:
function av = column_average(m)

%matrix=m;
matrix = m.submatrix;

NumberOfTimePoints = length(find(m.timepoints==1));

NumberOfConditions = size(matrix,1)/NumberOfTimePoints;

start=1;
for i=1:NumberOfConditions;
   av(i,:) = mean(matrix(start:start+NumberOfTimePoints-1,:),2);
   start=start+NumberOfTimePoints;
end




