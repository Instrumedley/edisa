%projects the gene vector vec on the expression data vector
function pr = project_genes (data, vec)

pr = struct('submatrix', {data.submatrix(:,vec)}, 'genes', {data.genes(vec)}, 'genenumbers', {data.genenumbers(vec)}, 'timepoints', {data.timepoints}, 'tissue', {data.tissue}, 'sample', {data.sample}, 'conditionnumbers', {data.conditionnumbers});