clear all; clc;
warning('off','all')
fprintf("Ryan Aday\nFull Data Combiner\n");
fprintf("Version 1.0: 05/31/2024\n");

% Specify the directory containing your .csv files
directoryPath = 'C:\Users\ryan.aday\Documents\DOORS DB\20240531\';
acifFilePath = 'C:\Users\ryan.aday\Documents\DOORS DB\20240531\_Cardinal_2.0_Detailed_Design_2.1_Requirements_2.1.3_FWCIs_8583990_ACIF_FRS.csv';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get a list of all .csv files in the directory
csvFiles = dir(fullfile(directoryPath, '_*.csv'));

% Initialize an empty cell array to store the data
combinedData = cell(0, 0);

% Read each CSV file and concatenate its data
for i = 1:length(csvFiles)
    filePath = fullfile(directoryPath, csvFiles(i).name);
    data = readtable(filePath);  % Read the CSV file
    data.Properties.VariableNames{2} = 'SecondColumn'; % Renamed to properly append tables
    combinedData = [combinedData; data];  % Concatenate vertically
end

combinedData_idx = combinedData{:, 1};

acifData = readtable(acifFilePath);
% Assuming the first column of combinedData corresponds to the first column of ACIF_FRS
for i = 1:size(acifData, 1)
    %matchingRowIndex = find(combinedData(:, 1) == acifData(i, 1));
    acifDataArray = textscan(string(acifData{i, 2}), '%s', 'Delimiter',{' ', '.', ','});

    acifDataVector = cellstr(char(acifDataArray{:}));
    logicalArray = contains(acifDataVector, '-');
    match_hyphen = acifDataVector(logicalArray);

    % Uses last char in char array for strfind comparison. If no hyphen
    % present in array, strfind skips to the next line.

    match = acifDataArray{1}{end}; 
    for j = 1:length(match_hyphen)
        % Check to see if the character string w/ the hyphen has format
        % 'ABC-123'
        if isletter(extractBefore(match_hyphen{j}, '-')) & ...
            all(ismember(extractAfter(match_hyphen{1}, '-') , '0123456789'))
            match = match_hyphen{j};
        end
    end

    pos = strfind(combinedData_idx, match);
    matchingRowIndex = find(~cellfun(@isempty,pos));
    if height(unique(combinedData(matchingRowIndex, 1))) > 1
        matchingRowIndex = matchingRowIndex(1);
    end

    %matchingRowIndex = find(strcmp(string(acifData{i, 2}), combinedData_idx) == 1)

    if ~isempty(matchingRowIndex)
        acifData(i, 2) = combinedData(matchingRowIndex, 2);
    end
end


% Write the combined data to a new CSV file
outputFilePath = 'C:\Users\ryan.aday\Documents\DOORS DB\20240531\combined_data.csv';
writetable(acifData, outputFilePath);
disp(['Output CSV file saved at: ' outputFilePath]);

% Clear all vars except outputTable
clearvars -except acifData