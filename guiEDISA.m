function varargout = guiEDISA(varargin)
% GUIEDISA M-file for guiEDISA.fig
%      GUIEDISA, by itself, creates a new GUIEDISA or raises the existing
%      singleton*.
%
%      H = GUIEDISA returns the handle to a new GUIEDISA or the handle to
%      the existing singleton*.
%
%      GUIEDISA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIEDISA.M with the given input arguments.
%
%      GUIEDISA('Property','Value',...) creates a new GUIEDISA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiEDISA_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiEDISA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiEDISA

% Last Modified by GUIDE v2.5 19-Apr-2007 15:07:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiEDISA_OpeningFcn, ...
                   'gui_OutputFcn',  @guiEDISA_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%global microarrydataset;
%global results;


% --- Executes just before guiEDISA is made visible.
function guiEDISA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiEDISA (see VARARGIN)

global files
% Choose default command line output for guiEDISA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Load Strings into dropdown boxes
set(handles.SelectMenu, 'String', readDatasets());
set(handles.ModuleDefinition, 'String', ...
    'Independent response modules|Coherent modules|Single response modules');
global PlotOnClickGenes
global PlotOnClickModules
PlotOnClickModules = get(handles.PlotClickModules, 'Value');
PlotOnClickGenes = get(handles.PlotGeneOnClick, 'Value');
%warning off all
%global handles;
set(handles.ConditionsText, 'String', num2str(get(handles.tauc,'Value')));
set(handles.GenesText, 'String', num2str(get(handles.taug,'Value')));
rand('state',0)


% UIWAIT makes guiEDISA wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%global microarraydataset


% --- Outputs from this function are returned to the command line.
function varargout = guiEDISA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in runEDISA.
function runEDISA_Callback(hObject, eventdata, handles)
% hObject    handle to runEDISA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear GLOBAL
global microarraydataset
global results
global refcond
global files
global parametersString

%Minimal gene size of a condition
minimalgenesize = 5;
refcond = 0;

%Obtain the parameter settings from the GUI
taug= get(handles.taug, 'Value');
tauc= get(handles.tauc, 'Value');
moduleType = get(handles.ModuleDefinition, 'Value');

try
    iterations = int32(str2num(get(handles.NumberOfIterations, 'String')));
catch
    set(handles.Text, 'String', strcat('Please enter a numeric value as iterations' ));
    return;
end

if iterations < 0
    set(handles.Text, 'String', strcat('Please enter a positive number of iterations' ));
    return;
end

single = 0;
parametersString = cell(5,1);
if moduleType == 1
   moduleType = 'IR';
   parametersString{2}  = strcat('ModuleType: ', 'independent response module');
elseif moduleType == 2
    moduleType = 'coherent';
   parametersString{2}  = strcat('ModuleType: ', 'coherent module');
else
    moduleType = 'IR';
    single = 1;
    parametersString{2}  = strcat('ModuleType: ', 'single response module');
end


%Disable control elements during evaluation of the algorithm
results = []; %set(handles.Refine, 'Enable', 'off');
TurnOffHandles(handles);
disp('Loading dataset')


%Load dataset
datasetname = loadDataset(get(handles.SelectMenu, 'Value'));
set(handles.Subtitle, 'String', datasetname);
set(handles.Text, 'String', 'Dataset loaded');
pause(0.3);
set(handles.Text, 'String', strcat('Preprocessing' ));
drawnow

%ensure a sampling size equal or smaller than the number of genes
%sampleSize = int32(20); %int32(str2num(get(handles.SampleSize, 'String')));
sampleSize = min(20, length(microarraydataset.genes)-1);

parametersString{1}  = strcat('Dataset: ', datasetname); parametersString{3}  = strcat('Iterations: ', num2str(iterations)); 
parametersString{4}  = strcat('Genes: ', num2str(taug)); parametersString{5}  = strcat('Conditions: ', num2str(tauc));


%If the dataset is not coherent return 
if strcmp(moduleType, 'coherent')
    for i=1:length(microarraydataset.timepoints)-1
        if length(microarraydataset.timepoints{i}) ~=  length(microarraydataset.timepoints{i+1})
            set(handles.Text, 'String', 'Coherent definition not applicable. Use independent response.');
            TurnOnHandles(handles);
            disp('Not coherent');
            return
        end
    end
end

microarraydataset = replaceZeros(microarraydataset);

%Preprocessing
disp('Preprocessing')
results = multiple_edisa(microarraydataset, sampleSize, -1, -1, iterations, moduleType, handles.Text);
modules = size(results, 1);
maxsize = min(size(results,1), iterations);
results = results(1:maxsize, :);
disp(strcat( int2str(modules), ' Raw modules calculated' ));
set(handles.Text, 'String', strcat('Postprocessing' ));
drawnow

%Postprocessing
disp('Postprocessing: merging modules');
results = merge_modules(microarraydataset,results, min(taug, tauc), 0.95, minimalgenesize, 0.0000001);
disp(strcat(int2str(size(results,1)), ' modules after first merging'));pause(0.1);


%Extending clusters to genes
results = extend_gene_modules(microarraydataset, results, taug, tauc, minimalgenesize, moduleType, handles.Text);
%Recalculating conditions
results = recalculateConditions(microarraydataset, results, tauc, moduleType, handles.Text);

if single == 1
    results = removeNonSingle(results);
end

%Remerging modules based on gene overlap
set(handles.Text, 'String', strcat('Remerging modules' ));
results = merge_modules_genes(results, 0.75);


set(handles.Text, 'String', strcat(int2str(size(results,1)), ' modules obtained' ));
disp(strcat(int2str(size(results,1)), ' modules obtained' ));pause(0.01);


modcells = cell(size(results,1),1);
for i=1:size(results,1)
    modcells{i} = strcat('module', int2str(i), ' (', int2str(size(results{i},2)), ' genes)') ;  
end

if modules == 0
   modcells = {'No modules found'};
end
set(handles.Modules, 'Value', 1); 
set(handles.Modules, 'String', modcells);
if size(results,1) > 0
    set(handles.GeneNames, 'max', 1); set(handles.GeneNames, 'Value', 1);
    set(handles.GeneNames, 'String', microarraydataset.genes(results{get(hObject,'Value')}));
    size(results{get(hObject,'Value')},1);
    set(handles.GeneNames, 'max', size(results{get(hObject,'Value')},2));
end
TurnOnHandles(handles);
drawnow
disp('EDISA done')

overlap = 0;
for i=1:size(results,1)
    genes = results{i};
    overlap = overlap + max([length(intersect(1:50, genes)) length(intersect(51:100, genes)) length(intersect(101:150, genes)) length(intersect(151:200, genes))]);
end
disp(strcat('Score: ', num2str(overlap/200)));


% --- Reactiaves the handles
function TurnOffHandles(handles)
    set(handles.PlotModule, 'Enable', 'off'); set(handles.runEDISA, 'Enable', 'off');
    set(handles.Modules, 'Enable', 'off'); set(handles.GeneNames, 'Enable', 'off');
    set(handles.plotgenes, 'Enable', 'off'); set(handles.Store, 'Enable', 'off'); 
    set(handles.ImportDataset, 'Enable', 'off'); set(handles.Slideshow, 'Enable', 'off');  drawnow

% --- Reactiaves the handles
function TurnOnHandles(handles)
    set(handles.GeneNames, 'String',''); 
    set(handles.PlotModule, 'Enable', 'on'); set(handles.runEDISA, 'Enable', 'on');
    set(handles.Modules, 'Enable', 'on'); set(handles.GeneNames, 'Enable', 'on');
    set(handles.plotgenes, 'Enable', 'on'); set(handles.Store, 'Enable', 'on'); 
    set(handles.ImportDataset, 'Enable', 'on'); set(handles.Slideshow, 'Enable', 'on'); drawnow
    

function datasetsString = readDatasets()
    global files
    files = dir('../datasets/*.mat');
    if length(files) > 1
        getDates = struct2cell(files)';
        getDates = getDates(:,2);
        getDates = datenum(getDates);
        [X, IX] = sort(getDates, 'descend');    
        files = files(IX);
        fileName = files(1).name;
        datasetsString = fileName(1:length(fileName)-4);
        for i=2:length(files)
            fileName = files(i).name;
            datasetsString = strcat(datasetsString, '|', fileName(1:length(fileName)-4));
        end
    end
    

function datasetsString = loadDataset(number)
    global files
    global microarraydataset
    datasetName = files(number).name; 
    datasetsString = datasetName(1:length(datasetName)-4);
    microarraydataset = load(strcat('../datasets/',datasetsString));
    microarraydataset = getfield(microarraydataset, datasetsString);
    %microarraydataset = dataset;
    
% --- Executes on selection change in Modules.
function Modules_Callback(hObject, eventdata, handles)
% hObject    handle to Modules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Modules contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Modules
%contents = get(hObject,'String')
global microarraydataset
global results 
global PlotOnClickModules
global datasetname
if size(results,1) > 0
    set(handles.GeneNames, 'max', 1); set(handles.GeneNames, 'Value', 1);
    set(handles.GeneNames, 'String', microarraydataset.genes(results{get(hObject,'Value')}));
    size(results{get(hObject,'Value')},1);
    set(handles.GeneNames, 'max', size(results{get(hObject,'Value')},2));
end
if PlotOnClickModules == 1
    modulenumber = get(handles.Modules, 'Value');
    PlotModules(microarraydataset, results, modulenumber, []);
end
drawnow


% --- Executes during object creation, after setting all properties.
function Modules_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Modules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in GeneNames.
function GeneNames_Callback(hObject, eventdata, handles)
% hObject    handle to GeneNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns GeneNames contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GeneNames
global PlotOnClickGenes
global microarraydataset
global results
global datasetname
if PlotOnClickGenes == 1
    modulenumber = get(handles.Modules, 'Value');
    if length(results) < 1
        return
    end
    genelist = results{modulenumber};
    genes = get(handles.GeneNames, 'Value');
    genes = genelist(genes);
    PlotModules(microarraydataset, results, modulenumber, genes);
end

% --- Executes during object creation, after setting all properties.
function GeneNames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GeneNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveModule.
function PlotModule_Callback(hObject, eventdata, handles)
% hObject    handle to SaveModule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global microarraydataset
global results
global datasetname
modulenumber = get(handles.Modules, 'Value');
PlotModules(microarraydataset, results, modulenumber, []);


% --- Executes during object creation, after setting all properties.
function SelectMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NumberOfIterations_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ModuleDefinition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ModuleDefinition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function NumberOfSample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberOfSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function SampleSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SampleSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in PlotClickModules.
function PlotClickModules_Callback(hObject, eventdata, handles)
% hObject    handle to PlotClickModules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotClickModules
global PlotOnClickModules;
PlotOnClickModules = get(hObject,'Value');

% --- Executes on button press in PlotGeneOnClick.
function PlotGeneOnClick_Callback(hObject, eventdata, handles)
% hObject    handle to PlotGeneOnClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotGeneOnClick
global PlotOnClickGenes;
PlotOnClickGenes = get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double

function SelectMenu_Callback(hObject, eventdata, handles)

function ModuleDefinition_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in plotgenes.
function plotgenes_Callback(hObject, eventdata, handles)
% hObject    handle to plotgenes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global microarraydataset
global results
global datasetname
modulenumber = get(handles.Modules, 'Value');
if length(results) < 1
    return
end
genelist = results{modulenumber};
genes = get(handles.GeneNames, 'Value');
genes = genelist(genes);
PlotModules(microarraydataset, results, modulenumber, genes);




% --- Executes on button press in ImportDataset.
function ImportDataset_Callback(hObject, eventdata, handles)
% hObject    handle to ImportDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt   = {'Enter the name of the dataset:'};
title    = 'Import';
lines = 1;
def = {'YourDataset'};
name   = inputdlg(prompt,title,lines,def);
res = importdataset(name{1});
set(handles.SelectMenu, 'String', readDatasets());
if res == 0
    set(handles.Text, 'String', strcat('The format of your dataset could not be processed' ));
else
    set(handles.Text, 'String', strcat('Dataset successfully imported and added' ));
end


% --- Executes on button press in SaveModule.
function SaveModule_Callback(hObject, eventdata, handles)
% hObject    handle to SaveModule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveModule

function NumberOfIterations_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function  NumberOfInterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tauc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(handles.IterationsText, 'String', num2str(get(hObject,'Value')));



function NumberOfInterations_Callback(hObject, eventdata, handles)
% hObject    handle to NumberOfInterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumberOfInterations as text
%        str2double(get(hObject,'String')) returns contents of NumberOfInterations as a double
set(handles.IterationsText, 'String', num2str(get(hObject,'Value'),2));


% --- Executes on button press in SaveModules.
function SaveModules_Callback(hObject, eventdata, handles)
% hObject    handle to SaveModules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveModules


% --- Executes on slider movement.
function taug_Callback(hObject, eventdata, handles)
% hObject    handle to taug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.GenesText, 'String', num2str(get(hObject,'Value'),2));


% --- Executes during object creation, after setting all properties.
function taug_CreateFcn(hObject, eventdata, handles)
% hObject    handle to taug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function tauc_Callback(hObject, eventdata, handles)
% hObject    handle to tauc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.ConditionsText, 'String', num2str(get(hObject,'Value'),2));


% --- Executes during object creation, after setting all properties.
function tauc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tauc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Store.
function Store_Callback(hObject, eventdata, handles)
% hObject    handle to Store (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global microarraydataset
global results
global parametersString
TurnOffHandles(handles);
set(handles.Text, 'String', strcat('Please wait while storing you data' ));
directoryname = strcat(uigetdir('', 'Pick a Directory'), '\');
dlmwrite(strcat(directoryname, 'EDISAParameters' , '.txt'), '');
for i=1:length(parametersString)
    dlmwrite(strcat(directoryname, 'EDISAParameters' , '.txt'), parametersString(i), '-append','delimiter', '');
end
for i=1:size(results,1)
    PlotModules(microarraydataset, results, i, [], directoryname);
end
set(handles.Text, 'String', strcat('Data stored' ));
TurnOnHandles(handles);


% --- Executes on button press in Slideshow.
function Slideshow_Callback(hObject, eventdata, handles)
% hObject    handle to Slideshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global microarraydataset
global results
global parametersString
TurnOffHandles(handles);
set(handles.Text, 'String', strcat('Please wait while slideshow proceeds' ));
for i=1:size(results,1)
    PlotModules(microarraydataset, results, i, [], -1);
end
set(handles.Text, 'String', strcat('Slideshow done' ));
TurnOnHandles(handles);

