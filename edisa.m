function [g, c, dev] = edisa(E, gedisa_sample, gene_threshold, condition_threshold, coherent, penalty)

dataset=E;

g=gedisa_sample;
g_star = g;


for i = 1:100 %maximum number of iterations; in practice, convergence is reached earlier
  
  
  %c(n+1) = f_{t_C} ( E_G * g(n) ):
  %--------------------------------
  E.submatrix = E.submatrix';
  p_genes = project_genes(E,g);
  
  %look either for all clusters (including IRC) or for coherent clusters
  %only:
  if strcmp(coherent,'coherent')      
   
    av_column = average_column(p_genes);
    dist_column = distance_to_average_column(p_genes, av_column);
    c = threshold(dist_column, condition_threshold);
    
  else %IR:
      
       column_av = column_average2(p_genes);
       dist_column = distance_to_column_average2(p_genes, column_av);
       
  end
  
  
  %use adaptive parameters if no thresholds are specified:
  %-------------------------------------------------------
  if (gene_threshold == -1 || condition_threshold==-1)
              
      try
         partitions = kmeans(dist_column.pearson_distance', 2);
         par1= dist_column.pearson_distance(find(partitions==1));    
         par2 = dist_column.pearson_distance(find(partitions==2));
        
         condition_threshold = min(max(par1), max(par2))+0.01;
      catch 
      end       
      
  end
  
  c = threshold(dist_column, condition_threshold); 
 
  
  if (length(c)<=1) 
    E=p_genes;
    break;
  end
  
  %g(n+1) = f_{t_G} ( E_C * c(n+1) ):
  %----------------------------------
  E=p_genes;
  
  E.submatrix = E.submatrix';
  
  
  p_conditions = project_conditions2(E,c);
   
  
  %again, decide whether to look for coherent or IR clusters:
  if strcmp(coherent, 'coherent')
  
      av_row = average_row(p_conditions);
      dist_to_av = distance_to_average_row(p_conditions, av_row);
      
      
      
      %if the Pearson correlation is not applicable to the data an error code
      %is returned:
      %if(dist_to_av_row.pearson_distance ~= -1)
      %  g = threshold(dist_row, gene_threshold);
      %end
      
  else %IR:
     
   
       dist_to_av = dist_to_average_col2(p_conditions);
          
  end
  
  
  l = length(dist_to_av.pearson_distance);
  penalty_vec  =  exprnd(penalty,l,1);  %exponential distribution
  penalty_vec  =  sort(penalty_vec,'ascend');
  
  dist_to_av.pearson_distance = dist_to_av.pearson_distance.*penalty_vec;
  
  
  %use adaptive parameters if no thresholds are specified:
  %-------------------------------------------------------
  if (gene_threshold == -1 || condition_threshold==-1)
         
     try
        partitions = kmeans(dist_to_av.pearson_distance, 2);
        cluster1 = find(partitions==1);
        par1= dist_to_av.pearson_distance(cluster1);
          
        cluster2= find(partitions==2);
        par2 = dist_to_av.pearson_distance(cluster2);
        gene_threshold = min(max(par1), max(par2))+0.01;     
     catch   
     end
        
  end 
  
  
  if(dist_to_av.pearson_distance ~= -1)  
     g = threshold(dist_to_av, gene_threshold);
  end    
  
  
  E=p_conditions;
  
  
  if length(g) < 2
    break;
  end
  
  
  %convergence criterion:
  %----------------------
  if ((length(g_star)-length(g)) / (length(g_star)+length(g))<0.01)
      break;
  else
      g_star = g;
  end
  
end


%return the current gene and conditions sets, as well as the cluster score:
%--------------------------------------------------------------------------

g=E.genenumbers;
c=E.conditionnumbers;



%timepoints of the current module
NumberOfConditions = length(c);
for i = 1:NumberOfConditions
  NumberOfTimePoints(i) = length(E.timepoints{i});
end

%timepoints of the whole dataset:
for i = 1:length(dataset.timepoints)
  DatasetTimePoints(i) = length(dataset.timepoints{i});
end

tp  = zeros(1,sum(NumberOfTimePoints));

for i = 1:NumberOfConditions
    index_offset = sum(NumberOfTimePoints(1:i-1))+1;
    value_offset = sum(DatasetTimePoints(1:c(i)-1))+1;
    
    tp(index_offset:index_offset+NumberOfTimePoints(i)-1) = value_offset:value_offset+DatasetTimePoints(c(i))-1;
end

if strcmp(coherent,'coherent')  
  
   %Pearson on all trajectories:
   dev = bicluster_dev( extract_all_trajectories(dataset.submatrix(dataset.genes_internal(g),tp), NumberOfTimePoints) );

else %IR clusters:   
        

  start = 1;
  for i= 1:NumberOfConditions
    dev_c(i) = bicluster_dev(dataset.submatrix(dataset.genes_internal(g),tp(start:start+NumberOfTimePoints(i)-1)) );
    start = start + NumberOfTimePoints(i);
  end
 
  dev = mean(dev_c);

end

g = dataset.genes_internal(g);