%dataset and results cell array as returned by the edisa, score threshold
%as a pre-filter, extension_threshold: add further conditions to the module
%if the score change to the worse is lower than extension_threshold

function results = extend_gene_modules(dataset, results, gene_threshold, condition_threshold, minimal_size, moduletype, texthandle)

average = zeros(size(results,1),1);

for i = 1 : size(results,1)
  %i = minimal_size;
  conditions = results{i,2};
  genes = size(dataset.submatrix(results{i,1},:),1);

  %Check if the dataset is extendable
  if genes < 2
      disp('Module does not contain enough genes');
      continue
  end
  if isempty(results{i,2})
        disp('Module contains no conditions');
        continue
  end
  
  if strcmp('coherent',moduletype)
      timep = length(dataset.timepoints{1});
      for j=conditions
          if timep ~= length(dataset.timepoints{j})
            if nargin > 6
                set(texthandle, 'String', 'Coherent definition not applicable. Not an equal number of time-steps per condition');
            end
            disp('Could not apply the coherent module definition');
            results = [];
            return
          end
      end
      [centroid, timesteps] = calculateCentroidCoherent(dataset, results(i,:));
  else
      [centroid, timesteps] = calculateCentroidIR(dataset, results(i,:));
  end
  
    
  %Calculate Pearson distance of every gene to centroid
  %CorrTwoCentroid = corr( tempmatrix', centroid');
  CorrTwoCentroid = corr( dataset.submatrix(:,timesteps)', centroid');

  %Calculate average perason distance of genes in module to centroid
  %average(i) = mean( corr( tempmatrix(results{i},:)', centroid'));
  average(i) = mean( corr( dataset.submatrix(results{i},timesteps)', centroid'));
  
  %Add all genes below the average distance
  alignedgenes = find( CorrTwoCentroid >  1-gene_threshold);
  alignedgenescore = CorrTwoCentroid(alignedgenes);
  [x, alignedgenesscore] = sort(alignedgenescore, 'descend');
  
  results{i,1} = alignedgenes(alignedgenesscore)';
  %results{i,1} = find( CorrTwoCentroid >  max(average, 0))';  
  
  %subplot(3,1,2); plot( dataset.submatrix(results{i,1},:)'); title(int2str(size(dataset.submatrix(results{i,1},:)))); 
  genes = size(dataset.submatrix(results{i,1},:),1);  
  %extendedcorr = (sum(sum(corr(dataset.submatrix(results{i,1},:)')))-genes)/(genes^2-genes)
   
  %subplot(3,1,3); plot( centroid' ); title('Centroid');
  if nargin > 6
    set(texthandle, 'String', strcat('Extending modules ' , '(', int2str(i),',',int2str(length(results)) , ')'));pause(0.01);    
  end
  %Calculate aligned conditions
  %try
  %    centroid = mean( tempmatrix(results{i,1},:));
  %catch
  %    disp('Division by zero while extending modules');
  %end
end

%[x, i] = sort(average, 'descend');
%results= results(i,:);

remove = zeros(length(results), 1);
for i=1:size(results,1)
    if length(results{i,1}) < minimal_size
        remove(i) = 1;
    end
end
remove = find(remove);
results(remove,:) = [];
%results
%m = results(GetAllBelow(results, condition_threshold, minimal_size),:);
