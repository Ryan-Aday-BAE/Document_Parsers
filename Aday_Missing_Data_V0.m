clear all; clc;

fprintf("Ryan Aday\nMissing Data Lister\n");
fprintf("Version 1.0: 05/31/2024\n");


% Specify all file paths to your CSV files
csvFilePath = 'C:\Users\ryan.aday\Documents\DOORS DB\20240531\_Cardinal_2.0_Detailed_Design_2.1_Requirements_2.1.1_HWCIs_8580064_ACIF.csv';
outputFilePath = 'C:\Users\ryan.aday\Documents\DOORS DB\20240531\list_missing_data.csv';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read the CSV file
T = readtable(csvFilePath);

% Initialize variables to store relevant information
missingInfo = cell(size(T, 1), 1);

% Iterate through the second column
for i = 1:size(T, 1)-1
    cellstr1 = string(T{i, 2}); % Convert observed cell to a string

    % Check if the first character is a number (header)
    if isnumeric(str2double(extract(cellstr1, 1))) && ~isnan(str2double(extract(cellstr1, 1)))
        cellstr2 = string(T{i+1, 2}); % Convert next cell to a string


        % Compare with the next cell
        if i < size(T, 1) && isnumeric(str2double(extract(cellstr2, 1))) && ~isnan(str2double(extract(cellstr2, 1)))
            % Count the number of '.' characters in both cells
            count1 = count(cellstr1, ".");
            count2 = count(cellstr2, ".");
            
            % If counts match, consider the first header cell as missing information
            if count1 == count2
                missingInfo{i} = T{i, 1};
                missingInfo{i+1} = T{i+1, 1};
            end
        end
    end
end

% Remove all empty cells
missingInfo = missingInfo(~cellfun('isempty',missingInfo));

% Create a new table with relevant information
outputTable = table(missingInfo, 'VariableNames', {'MissingInfo'});

% Write the output table to a new CSV file
writetable(outputTable, outputFilePath);

%disp(outputTable)
disp(['Output CSV file saved at: ' outputFilePath]);

% Clear all vars except outputTable
clearvars -except outputTable