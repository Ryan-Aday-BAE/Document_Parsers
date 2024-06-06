% Library API
function res = compareMBLeven(str1, str2, transpose)
    % Load constants for MBLeven function
    MBLeven_consts

    len1 = length(str1);
    len2 = length(str2);
    
    if len1 < len2
        [len1, len2] = deal(len2, len1);
        [str1, str2] = deal(str2, str1);
    end
    
    %{
    if (len1 - len2) > 2
        res = -1;
        return;
    end
    %}


    if transpose
        models = MATRIX_T{abs(len1 - len2) + 1};
    else
        models = MATRIX{abs(len1 - len2) + 1};
    end
    
    res = 3;
    for modelIdx = 1:length(models)
        cost = check_model(str1, str2, len1, len2, models{modelIdx});
        if cost < res
            res = cost;
        end
    end
    
    if res == 3
        res = -1;
    end
end