% Library API
function res = compareMBLeven(str1, str2, transpose)
    len1 = length(str1);
    len2 = length(str2);
    
    if len1 < len2
        [len1, len2] = deal(len2, len1);
        [str1, str2] = deal(str2, str1);
    end
    
    if (len1 - len2) > 2
        res = -1;
        return;
    end
    
    if transpose
        models = MATRIX_T{len1 - len2};
    else
        models = MATRIX{len1 - len2};
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

function cost = check_model(str1, str2, len1, len2, model)
    idx1 = 1;
    idx2 = 1;
    cost = 0;
    pad = 0;
    
    while idx1 <= len1 && idx2 <= len2
        if str1(idx1) ~= str2(idx2 - pad)
            cost = cost + 1;
            if cost > 2
                return;
            end
            
            option = model{cost};
            if option == DELETE
                idx1 = idx1 + 1;
            elseif option == INSERT
                idx2 = idx2 + 1;
            elseif option == REPLACE
                idx1 = idx1 + 1;
                idx2 = idx2 + 1;
                pad = 0;
            elseif option == TRANSPOSE
                if idx2 + 1 <= len2 && str1(idx1) == str2(idx2 + 1)
                    idx1 = idx1 + 1;
                    idx2 = idx2 + 1;
                    pad = 1;
                else
                    cost = 3;
                    return;
                end
            end
        else
            idx1 = idx1 + 1;
            idx2 = idx2 + 1;
            pad = 0;
        end
    end
    
    cost = cost + (len1 - idx1) + (len2 - idx2);
end
