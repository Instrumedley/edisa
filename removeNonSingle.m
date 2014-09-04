%Removes modules with more than one condition
function results = removeNonSingle(results)
singles = zeros( size(results, 1), 1);
for i=1:size(results, 1)
    singles(i) = length( results{i,2} );
end
keep = find( singles == 1);
results = results(keep, :);

