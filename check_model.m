function cost = check_model(str1, str2, len1, len2, mdel)

    % Load constants for MBLeven function
    MBLeven_consts

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

            option = mdel(cost);
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
