function data = Mypdist(data, disttype)
    try
        data = pdist(data, disttype);
        return
    catch
        msgstr = strcat(lasterr, ' in correlation');
        error(msgstr);
        %disp('Problems with pdist: Your dataset may be to large for available the memory');
    end
    try 
        data = pdist(data, 'euclidean');
        return
    catch
        msgstr = strcat(lasterr, ' in euclidean');
        error('msgstr');
        %disp('Problems with pdist: Your dataset may be to large for available the memory');
    end
