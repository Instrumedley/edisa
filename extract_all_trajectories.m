function trajectories = extract_all_trajectories(data, NumberOfTimePoints)

%NumberOfConditions = size(data,2)/NumberOfTimePoints;
NumberOfConditions = length(NumberOfTimePoints);

NumberOfGenes = size(data,1);

trajectories = zeros(NumberOfGenes * NumberOfConditions, NumberOfTimePoints(1));

counter=1;
genes=1;
for i = 1: NumberOfConditions
  trajectories(genes:genes+NumberOfGenes-1,1:NumberOfTimePoints(i)) = data(:,counter:counter+NumberOfTimePoints(i)-1);
  counter = counter+NumberOfTimePoints(i);
  genes=genes+NumberOfGenes;
end
