load ../datasets/ArabidopsisAbioticShoot
results = multiple_edisa(ArabidopsisAbioticShoot, 20, -1, -1, 400, 'coherent');
results = merge_modules (ArabidopsisAbioticShoot,results, 0.25, 0.99, 5, 0.0000001)
results1 = recalculateConditions(ArabidopsisAbioticShoot, results, 0.2, 'coherent');
results2 = extend_gene_modules(ArabidopsisAbioticShoot, results1, 0.1 , 0.2, 5 , 'coherent');
results3 = recalculateConditions(ArabidopsisAbioticShoot, results2, 0.2, 'coherent');
results4 = merge_modules_genes(results3, 0.8);