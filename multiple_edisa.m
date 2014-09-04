%iteratively calls edisa.m, provides the samples
function results = multiple_edisa (E, sample_size, gene_threshold, condition_threshold, runs, coherent, text)

penalty=15; %weighting parameter for the weighted samples (can be left unchanged - we just need some enhancement
%for the higher ranking neighbours )

NumberOfConditions = length(E.conditionnumbers);

RunsPerCondition = ceil(runs/NumberOfConditions);

initialruns = runs;

runs = RunsPerCondition*NumberOfConditions;

for i = 1:length(E.timepoints)
    NumberOfTimePoints(i) = length(E.timepoints{i});
end

%compute the distance matrix only once:
%---------------------------------------

Conditions_trajectories = [1:max(NumberOfTimePoints)*NumberOfConditions];

disp('Computing modules');
start=1;
cnt = 0;
results = cell(runs,3);
counter=1;
countruns = 0;
k = 0;

%test for github !This comment can be deleted anytime!
%TEST 2
while countruns < runs
gui
    k = k + 1;
    if k <= NumberOfConditions
        CurrentCondition = Conditions_trajectories(start:start+NumberOfTimePoints(k)-1);
        %cope wih all-zero entries by adding normally distributed noise:
        cond = E.submatrix(:,CurrentCondition);
        %s=sum(cond,2);
        %all_zero = find(s==0);
        %cond(all_zero,:) = cond(all_zero,:) + randn(length(all_zero),length(CurrentCondition));
        %cond = cond + rand( size(cond,1), size(cond,2))/10;
        try
            PearsonDistanceMatrix = squareform(Mypdist(cond, 'correlation')) ;
        catch
            disp(strcat('Problems with condition: ', int2str(size(CurrentCondition,2))));
            PearsonDistanceMatrix = zeros(size(cond,1), size(cond,1));
        end
        start=start+NumberOfTimePoints(k);

        %call the EDISA (10 samples are given to edisa.m at a time):
        %-----------------------------------------------------------

       GeneSubset = [1: size(E.submatrix,1)];
    end
    runcondition = 0;
    while runcondition < RunsPerCondition

        %sampling with nearest neighbour preprocessing:
        %----------------------------------------------
        AllConditions        = [1:NumberOfConditions];

        [sample_set, GeneSubset] = edisa_sample(E, sample_size, GeneSubset, PearsonDistanceMatrix);
        for j = 1:10
            runcondition = runcondition +1;
            if runcondition == RunsPerCondition
                continue
            end
            countruns = countruns +1;
            [results{countruns,1},results{countruns,2}, results{countruns,3}] = edisa(E, sample_set{j}, gene_threshold, condition_threshold, coherent, penalty);
        end
        if exist('text') == 1
            set(text, 'String', strcat('EDISA Iterations (',  int2str(min(countruns,initialruns)), ',',  int2str(initialruns) ,')'));
            pause(0.01);
        end
   end
   if k < NumberOfConditions
    clear PearsonDistanceMatrix
   end
end

%save outfile results;