%projects the condition vector vec on the expression data vector
function pr = project_conditions2 (data, vec)


NumberOfConditions = length(vec);

for i = 1:NumberOfConditions
   NumberOfTimePoints(i) = length(data.timepoints{vec(i)});
end


start=1;
for i =1: NumberOfConditions
    vector(start:start+NumberOfTimePoints(i)-1) = start:start+NumberOfTimePoints(i)-1;
    start = start+NumberOfTimePoints(i);
end

pr = struct('submatrix', {data.submatrix(:,vector)}, 'genes', {data.genes}, 'genenumbers', {data.genenumbers}, 'timepoints', {data.timepoints(vec)}, 'tissue', {data.tissue}, 'sample', {data.sample}, 'conditionnumbers', {data.conditionnumbers(vec)});
