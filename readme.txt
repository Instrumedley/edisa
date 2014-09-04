EDISA in MATLAB 

TEST FOR GITHUB Uahdusahdu

load one of the datasets
------------------------

>> load ../datasets/ArabidopsisAbioticShoot
other datasets [ArabidopsisAbioticRoot, EColiDiauxie, EColiDiauxieLarge, HomoSapiensMS, YeastCellCycle, YeastCellCycleLarge]

run the EDISA
-------------

multiple_edisa(dataset_name, sample_size, threshold t_c, threshold t_g, number_of_iterations, module_type);

- a sample_size of 20 is usually appropriate
- the two thresholds may be set manually; setting both to -1, however, activates the adaptive parameter selection
- module_type can be 'IR' or 'coherent'

>> results = multiple_edisa(ArabidopsisAbioticShoot, 20, -1, -1, 200, 'IR')

   [1x74  double]    [1x2 double]    [0.3233]
   [1x62  double]    [1x2 double]    [0.4095]
   [1x86  double]    [1x2 double]    [0.2663]

'results' is a cell array with [gene numbers] [condition numbers] [score]


run the merging procedure
-------------------------


merge_modules(dataset_name, edisa_results, score_threshold, pca_parameter, minimum_size, merge_threshold)

- from the large set of result modules, only those are accepted into the merging process, which have
a size of at least 'minimum_size' and a score better (i.e. smaller) than 'score_threshold'.

This depends on the quality of the dataset. In a noisy dataset you may have to increase the 'score_threshold'
in order to obtain results.

>> results = merge_modules (ArabidopsisAbioticShoot,results, 0.25, 0.99, 5, 0.0000001)


Refining the modules
--------------------

- The three two steps refine the results to the module definition. 

The first method 'extend_gene_modules' includes all genes into the module,
which are aligned with the module defefinition (depends on tau_g)
The second method alignes the conditions with the module definition  (depends on tau_c)
The third method removes all modules which have a gene overlap exceeding the speicied cutoff

results = extend_gene_modules(microarraydataset, results, taug, tauc, minimalgenesize, moduleType, handles.Text);
results = recalculateConditions(microarraydataset, results, tauc, moduleType, handles.Text);
results = merge_modules_genes(results, cutoff);
>> results = extend_gene_modules(ArabidopsisAbioticShoot, results, 0.1 , 0.2, 5 , 'IR');
>> results = recalculateConditions(ArabidopsisAbioticShoot, results, 0.2, 'IR');
>> results = merge_modules_genes(results, 0.8);


plotting the resulting modules
------------------------------
To plot the modules the function PlotModules can be used, as first argument the current dataset
has to be specified, the second argument are the resulting modules, the last argument specifies the
module to be plotted.

>> PlotModules(ArabidopsisAbioticShoot, results, 1);



less important parameters; you may use default values here 
----------------------------------------------------------
- for the k-means employed as part of the merging process, the 'pca_parameter' specifies that k is set to the
number of principal components which account for 'pca_parameter' percent of the variation
- a merging of two modules is allowed, if the score is decreased by at most 'merge_threshold' 

