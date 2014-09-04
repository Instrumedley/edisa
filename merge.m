%repeatedly applies the merge_module function to merge even modules which,
%themselves, are the result of a merge operation:
function m =  merge (dataset, results, threshold, alpha, minimal_size, merge_threshold)

 m=merge_modules2(dataset,results, threshold, alpha, minimal_size, merge_threshold);
 
 OldNumberOfModules = size(m,1);
 NumberOfModules = OldNumberOfModules-1;
 
 while NumberOfModules<OldNumberOfModules
 
   OldNumberOfModules = size(m,1);
   %m=merge_modules3(dataset,m, -1, alpha, -1, merge_threshold);
   %Merge-Variante:
   m=merge_modules2(dataset,m, -1, alpha, -1, merge_threshold);
   
   NumberOfModules = size(m,1);
 end