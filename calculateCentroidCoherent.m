function [centroid, timesteps] = calculateCentroidCoherent(dataset, module)

conditions = module{1,2};
timesteps = [];
count = 1;

if( isempty(conditions) )
    conditions = 1:length(dataset.conditions);
end
%Extracting all time-points from all conditions contained in the module

for j=1:length(dataset.conditions)
    if length(find(conditions == j))
      timesteps = [timesteps, count:count+length(dataset.timepoints{j})-1];
      count = count+length(dataset.timepoints{j});
    else
      count = count+length(dataset.timepoints{j});
    end
end

timep = length(dataset.timepoints{1});
aligns = zeros(length(conditions), timep);

%Calculate aligned conditions
centroid = mean( dataset.submatrix(module{1,1},timesteps));

count = 1;
for j=1:length(conditions)
    aligns(j,:) = centroid(count:count+timep-1);
    count = count + timep;
end

avcentroid = mean(aligns);
count = 1;
for j=1:length(conditions)
   centroid(count:count+timep-1) = avcentroid;
   count = count + timep;
end

%figure;plot(centroid);
