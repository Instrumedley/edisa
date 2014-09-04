function PlotModules(dataset, results, modulenumber, genelist, storeDir)
if length(results) < 1
    return
end
if nargin < 4
   genelist = [];
end
    
figure(1);
%Set the Title of the Figure
set(gcf, 'name', strcat('Module ', int2str(modulenumber)));
set(gcf, 'NumberTitle', 'off');

plottingmodule = 1;

if length(genelist) > 0
    datasetmatrix = dataset.submatrix(genelist,:);
    genenames = dataset.genes(genelist,:);
    plottingmodule = 0;
else
    %Obtain the data
    datasetmatrix = dataset.submatrix(results{modulenumber},:);
    genenames = dataset.genes(results{modulenumber});
end
conditions = dataset.conditions;

%datasetmatrix = datasetmatrix( results{modulenumber,1},:);
includedConditions = results{modulenumber,2};

count = 1;
%Set the minimal and maximal y-value
maxvalue = 0;
minvalue = 0;
maxvaluetemp = 0;
minvaluetemp = 0;
for i=1:length(conditions)
    timecond = length(dataset.timepoints{i});
    if size(find(includedConditions == i),2) > 0
        maxvaluetemp = max(max(datasetmatrix(:,count:count+timecond-1)))+abs(max(max(datasetmatrix(:,count:count+timecond-1))))/10;
        minvaluetemp = min(min(datasetmatrix(:,count:count+timecond-1)))+abs(min(min(datasetmatrix(:,count:count+timecond-1))))/10;
    end
    count = count+timecond;
    maxvalue = max(maxvaluetemp, maxvalue);
    minvalue = min(minvalue, minvaluetemp);
end


%Create the subplots
if length(conditions) > 4
    numcolums = 3;
else
    numcolums = 2;
end
rows = ceil(length(conditions)/numcolums);

count = 1;
for i=1:length(conditions)
    subplot(rows,numcolums,i);
    xaxes = dataset.timepoints{i};
    timecond = length(dataset.timepoints{i});
    if size(find(includedConditions == i),2) > 0
        plot(datasetmatrix(:,count:count+timecond-1)');
    else
        plot(datasetmatrix(:,count:count+timecond-1)', 'Color',[0.859 0.85 0.85]);
    end
    count = count+timecond;
    title(conditions(i));
    set(gca,'XTick',1:length(dataset.timepoints{i}));
    set(gca,'XTickLabel',xaxes);
    axis([1 timecond minvalue maxvalue]);    
    if size(genenames,1) < 0 
       legend(genenames);
       legend('off');
    end
end
subplot(rows,numcolums,includedConditions(1));

if nargin < 5
   return
end
if not(isnumeric(storeDir))
    if length(genelist) > 0
        genescell = dataset.genes(genelist);
    else
        genescell =  dataset.genes(results{modulenumber});
    end
    output = '';
    output = strcat(output, '#Conditions:');
    for i=1:length(includedConditions)
        output = strcat(output, dataset.conditions{includedConditions(i)});
        if i < length(includedConditions)
            output = strcat(output, ',');
        end
    end
    dlmwrite(strcat(storeDir, 'Module', int2str(modulenumber) , '.txt'),  output, 'delimiter', '');
    for i=1:length(genescell)
        dlmwrite(strcat(storeDir,  'Module', int2str(modulenumber) , '.txt'), genescell{i}, '-append', 'delimiter', '');
    end
    %dlmwrite(strcat('../Modules/', store, '.txt'),  outputtext);
    %saveas(gcf, strcat(storeDir, 'Module', int2str(modulenumber)), 'eps');
    saveas(gcf, strcat(storeDir, 'Module', int2str(modulenumber)), 'epsc');
else
    pause(2)
end

close(figure(1))



