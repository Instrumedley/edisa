function modules = merge_modules(dataset, results, threshold, alpha, minimal_size, merge_threshold)

modules = [];

%Only consider modules with a score below the threshold
if threshold == 9999
    BelowThreshold = 1:size(results,1);
else
    BelowThreshold = GetAllBelow(results, threshold, minimal_size);
end

%assign condition set labels:
for i = 1 : length(BelowThreshold)
  t= results{BelowThreshold(i),2};
  conditionsets(i,1:length(t)) = t;
end

%for each module: get all modules with the same condition set:

deleted=0;
module_index=1;
for i = 1 : length(BelowThreshold)  
    if isempty(find(deleted==i)) %if not already deleted by a merging process
    
    cp = repmat(conditionsets(i,:), size(conditionsets,1), 1);
    cp_matrix = conditionsets - cp;
    SameSet = find (sum(abs(cp_matrix')) == 0);
    
    if size(SameSet,2) > 1
    %--------------------------    
    
    deleted=union(deleted,SameSet);
    centr_vec=0; 
    %compute their centroids:
    for j = 1 : size(SameSet,2)
      c = centroid2(dataset, results{BelowThreshold(SameSet(j)),1}, results{BelowThreshold(SameSet(j)),2});
      centr_vec(j,1:length(c)) = c;
    end
    
    
    %and compare (Pearson distance) the centroids:
    NumberOfEntries = size(centr_vec,1);
    dist_matrix = squareform(Mypdist(centr_vec, 'correlation'));
    
 
    %use PCA to determine k for kmeans:
    [coeff, score, latent] = princomp(centr_vec);
    
    eigen_sum=0;
    alleigenvalues = sum(latent);
        
    if alleigenvalues >0
        for h = 1: length(latent)
          if eigen_sum < alpha
              eigen_sum = eigen_sum + latent(h) / alleigenvalues;
          else
             top_k_clusters=h; break;
          end
        end
    else
        top_k_clusters=1; %in case there are no princ. components returned by the PCA
    end
   
    
    
    %perform a kmeans clustering on the centroids:
   
    %in case we have only few modules that are, moreover, close (average Pearson distance <
    %0.05, we need to assign them manually to one cluster, as the k-means function does
    %not accept k=1:
    if max(max(dist_matrix)) < merge_threshold       
       clusters=0;
       clusters(1:size(dist_matrix,1)) = 1; 
    else
      
      %perform a kmeans clustering and catch possible empty cluster errors:  
      emptycluster=1;
      
      while emptycluster
        try 
          clusters = kmeans(dist_matrix,top_k_clusters, 'replicates', 10);
          emptycluster=0;
        catch
          top_k_clusters = top_k_clusters-1;
          
          if top_k_clusters<1 
              disp('break')
               break;
          end;
          
          emptycluster=1;
        end
        
      end
      
    end
      
    %i
    %then merge all modules which got into the same cluster:
    
    ModulesToMerge=0;
    for m = 1 : top_k_clusters
        
      MergeCandidates = find(clusters==m);
      
  
      if length(MergeCandidates) > 1
        
         ModulesToMerge=union(ModulesToMerge, MergeCandidates);
        
         MergedModule=0;
         for j = 1 : length(MergeCandidates)
             b = results{BelowThreshold(SameSet(MergeCandidates(j))),1};
             a = MergedModule;
             
             %merge only, if it is a subset:
             if ( isempty(setdiff(a,0)) || isempty(setdiff(a,b)) || isempty(setdiff(b,a)) )
               MergedModule = union(a, b);
             end
            
         end
         
         modules{module_index,1} = MergedModule(find(MergedModule>0));
         modules{module_index,2} = find(conditionsets(m,:)>0);
         module_index=module_index+1;
      end
      
      
    end
    
    
    ModulesToMerge = ModulesToMerge(find(ModulesToMerge>0));
    
    
    %append the remaining modules (which are not merged):
    
    NotMerged = setdiff(SameSet,SameSet(ModulesToMerge));
    if (size(NotMerged,2) > 0 )
      
      for n = 1: size(NotMerged,2)
        modules{module_index,1} = results{BelowThreshold(NotMerged(n)),1};
        modules{module_index,2} = results{BelowThreshold(NotMerged(n)),2};
        modules{module_index,3} = -1;
        
        module_index=module_index+1;
      end 
     
    end
    
    
    %--------------------------  
    else %there is nothing to merge --> just append the module to the results
       modules{module_index,1} = results{BelowThreshold(SameSet(1)),1};
       modules{module_index,2} = results{BelowThreshold(SameSet(1)),2};
       modules{module_index,3} = -1;
       module_index=module_index+1;
    end

    end %if
end %for



%disp('modules before merging:') 
%length(BelowThreshold)
%disp('modules after merging:')
%size(modules,1)

    








