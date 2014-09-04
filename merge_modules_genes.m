function results = merge_modules_genes(results, overlapthr)

%Check if two modules have a substantial gene overlap (more than
%overlapthr)
remove = zeros(size(results,1),1);
for i = 1:size(results,1)
   for j=i+1:size(results,1)
        overlap = length(find(ismember(results{i},results{j})))/ min(length(results{i}), length(results{j}));
        if (overlap > overlapthr) %& (length(results{i,2}) == length(results{j,2}))
           if length(results{i,2}) < length(results{j,2})
            remove(j) = 1;
           else
            remove(i) = 1;
           end
        end
   end
   %Remove modules with no condition
   if  length(results{i,2}) < 1
      remove(i) = 1;
   end
end

%Remove modules
keep = find(remove == 0);
results = results(keep,:);
