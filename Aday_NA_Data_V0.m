clear all; clc;

fprintf("Ryan Aday\nN/A Data Lister\n");
fprintf("Version 1.0: 05/31/2024\n");

% Specify the directory containing your .csv files
directoryPath = 'C:\Users\ryan.aday\Documents\DOORS DB\20240531\';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get a list of all .csv files in the directory
csvFiles = dir(fullfile(directoryPath, '_*.csv'));

% Loop through each .csv file
for fileIdx = 1:length(csvFiles)
    % Read the current .csv file
    curFilePath = fullfile(directoryPath, csvFiles(fileIdx).name);
    data = readtable(curFilePath);
    
    % Check if the second column contains "n/a" or variations
    secondColumn = data{:, 2};
    naIndices = (contains(lower(secondColumn), 'n/a') | ...
        contains(lower(secondColumn), 'n/a')) & strlength(secondColumn) >= 3;
    
    % Extract the adjacent data from the first column
    extractedData = data{naIndices, 1};
    
    % Create a new .csv file to store the extracted data
    [~, fileName, ~] = fileparts(curFilePath);
    newCsvFilePath = fullfile(directoryPath, [fileName '_extracted_NA.csv']);
    writecell(extractedData, newCsvFilePath);
    
    fprintf('Extracted data from %s to %s\n', csvFiles(fileIdx).name, newCsvFilePath);
end

% Clear all vars except outputTable
clearvars