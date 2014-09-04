function res = importdataset(name)
    res = 0;
    description = strcat('Name of the dataset: ', name, '; ');
    eval 'cd ../sampleData';
    [filename pathname] = uigetfile({'*.txt', 'Text files (*.txt)';...
                                     '*.xls', 'Excel files (*.xls)';...
                                     '*.csv', '(*.csv)';...
                                     '*.*', 'All files (*.*)';...
                                     },'MultiSelect', 'on');
   %[filename pathname] = uigetfile('../sampleData/';'*.txt', 'Text files (*.txt)','MultiSelect', 'on');
   %[filename pathname] = uigetfile('../sampleData/','Choose all datasets containing the conditions', 'MultiSelect', 'on');
    if isequal(filename,0)
        disp('User selected Cancel');
        return
    end
    first = 0;
    conditions = length(filename);
    timepoints = {conditions, 1};
    description = strcat(description, 'Number of conditions: ', num2str(conditions), '; ');
    if iscell(filename)
        datasetNew = [];
        genenames = [];
        conditions = [];
        for i = 1:length(filename)
            pause(0.01);
            try
                M = importdata([pathname filename{i}]);
            catch
                disp('The format of your dataset cannot be processed'); 
                eval 'cd ../source'
                err = lasterror;
                errordlg(strcat('MATLAB internal error: ', err.message), 'Problems parsing the dataset');
                return
            end
            
            if isstruct(M.data)
                str = fieldnames(M.data);
                dataset = getfield(M.data, str{1} );
                disp('extracting dataset in if');
                textdataset = getfield(M.textdata, str{1} );
            else
                dataset = M.data;
                disp('extracting dataset in else');
                textdataset = M.textdata;
            end
            
            if first == 0
                first = size(textdataset,1)-1;
                genenames = textdataset(2:size(textdataset,1),1);
                description = strcat(description, 'Number of genes: ', num2str(length(genenames)), '; ');
            else
                %Check if the gene names are equal
                if not(isequal(textdataset(2:size(textdataset,1),1), genenames))
                    for j=1:length(genenames)
                        if not(isequal(textdataset(j+1,1), genenames(j)))
                            disp(strcat('These are the entries that are different. In Row: ', num2str(j+1)) );                    
                            disp([textdataset(j+1,1),genenames(j)]);
                        end
                    end     
                    disp(strcat('Error occured in files: ', filename{i},filename{1}));
                    errordlg('The gene names are not identical', 'Gene names not identical');
                    eval 'cd ../source'
                    return
                end            
            end
            
            %Generate new dataset
            datasetNew = [datasetNew dataset];

            %If only the genes are in the textdataset
            if size(textdataset,2) == 1
                timep = cell(1,size(dataset,2));
                for j=1:size(dataset,2)
                    if isnumeric(dataset(1,j))
                        timep{j} = num2str(M.data(1,j));
                    else
                        timep{j} = setdata(1,j);
                    end
                end
                timepoints{i} = timep;
            else
                timepoints{i} = textdataset(1,2:size(textdataset,2));
            end
            textheader = textdataset(1,2:size(textdataset,2));
            conditions = [conditions textdataset(1,1)];
        end
        genes = 1:first;
        genes = genes';
        conditionnumbers = 1:length(filename);
        dataset = struct('submatrix',{datasetNew},'genenumbers', {genes'}, 'genes',{genenames}, 'tissue', {'default'}, 'sample', {'mean'}, 'timepoints', {timepoints'}, 'conditions', {conditions}, 'conditionnumbers', {conditionnumbers},   'genes_internal',{genes'});
    else
        datasetNew = [];
        eval 'cd ../source'
        errordlg('You have to import multiple files to generate a 3D dataset', 'Only one file (dataset) selected');
        return
    end
eval 'cd ../source';
eval([ name '= dataset']);

%Stores a description file
fid = fopen(strcat('../datasets/', name, '.txt'), 'wt');
fwrite(fid, description);
fclose(fid);

%Stores the dataset
save( strcat('../datasets/', name, '.mat'), name);
res = 1;
end
