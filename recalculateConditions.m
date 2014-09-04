function results = recalculateConditions(dataset, results, condition_threshold, moduletype, texthandle)
counter = 0;

%for i=1:length(dataset.conditions)
%    allconditions{i} = dataset.submatrix(:,counter+1:counter+length(dataset.timepoints{i}));
%    counter = counter+length(dataset.timepoints{i});
%end
  %Reducing the dataset to the contained conditions
timesteps = cell(length(dataset.conditions),1); 
count = 1;
  
%Extracting all time-points from all conditions contained in the module
for j=1:length(dataset.conditions)
      timesteps{j} = [count:count+length(dataset.timepoints{j})-1];
      count = count+length(dataset.timepoints{j});
end

%allconditions

conditions = 1:length(dataset.conditions);

for i = 1 : size(results,1)
  %i = minimal_size;
  %BelowThreshold = GetAllBelow(results, condition_threshold, minimal_size);
  %Reducing the dataset to the contained conditions
  %timesteps = []; 
  count = 1;
  %for j=conditions
  %    timesteps = [timesteps, count:count+sum(dataset.timepoints{j})-1];
  %    count = count+sum(dataset.timepoints{j});
  %end
  
  %timesteps
  %Calculate centroid 
  %genes = size(dataset.submatrix(results{i,1},:),1);
 
  %Recalculate centroid
  if strcmp('coherent',moduletype)
      [centroidco, time] = calculateCentroidCoherent(dataset, results(i,:));
      timepointsco = length(dataset.timepoints{1});
      centroidnew = zeros(1, length(conditions)*length(dataset.timepoints{1}));
      countcent = 1;
      centroidco = centroidco(1:timepointsco);
      for j=1:length(conditions)
        centroidnew(countcent:countcent+timepointsco-1) = centroidco;
        countcent = countcent + timepointsco;
      end
  else
     %Calculate aligned conditions
      centroidnew = mean(dataset.submatrix(results{i,1},:));
  end
  results{i,3} = centroidnew;
end

%Stored the correlations of the conditions
corrcond = zeros(length(results), length(dataset.conditions));
countcond = 1;

for j=1:length(dataset.conditions)
    points = length(dataset.timepoints{j});
    for i=1:size(results,1)
        centroid = results{i,3};
        centroid = centroid(countcond:countcond+points-1);
        corrcond(i,j) = mean( corr( dataset.submatrix(results{i,1},timesteps{j})', centroid'));
    end
    countcond = countcond + points;
    if nargin > 4
        set(texthandle, 'String', strcat('Recalculating conditions ' , '(', int2str(j),',',int2str(length(dataset.conditions)) , ')'));
    end
    pause(0.01);
end

for i=1:size(results,1)
    results{i,2} = find(corrcond(i,:) > 1-condition_threshold);
end

    
