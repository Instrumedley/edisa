function [centroid,timesteps]  = calculateCentroidIR(dataset, module)
  %Reducing the dataset to the contained conditions
  timesteps = []; 
  count = 1;
  conditions = module{1,2};
  
  %Extracting all time-points from all conditions contained in the module
  for j=1:length(dataset.conditions)
      if length(find(conditions == j))
        timesteps = [timesteps, count:count+length(dataset.timepoints{j})-1];
        count = count+length(dataset.timepoints{j});
      else
        count = count+length(dataset.timepoints{j});
      end
  end
    
  %Calculate aligned conditions
  centroid = mean( dataset.submatrix(module{1,1},timesteps));  
  
%figure;plot(centroid);