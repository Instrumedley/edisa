function microarraydataset = replaceZeros(microarraydataset)
    %Extract dataset and information
    dataset = microarraydataset.submatrix;
    maxentry = max(max(dataset));

    %Detect zero entries and replace with random non-zero entries
    zeroentries = find(dataset == 0);
    randomnum = maxentry/100 * rand(length(zeroentries), 1);
    dataset(zeroentries) = randomnum;
    microarraydataset.submatrix = dataset;
