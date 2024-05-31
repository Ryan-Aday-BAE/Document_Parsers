clear all; clc;

fprintf("Ryan Aday\nDamareau Levenshtein File Comparer\n");
fprintf("Version 1.0: 05/31/2024\n");

% Specify the folder containing the .csv files
folderPath = 'C:\Users\ryan.aday\Documents\DOORS DB\20240531\';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get a list of .csv files in the folder
csvFiles = dir(fullfile(folderPath, '*.csv'));
txtFiles = dir(fullfile(folderPath, '*.txt'));
% Initialize variables
mainCsvFile = fullfile(folderPath, csvFiles(1).name);
compareTxtFile = fullfile(folderPath, txtFiles(1).name);

% Read the .csv file with the least rows
mainCsvData = readtable(mainCsvFile);
compareTxtData = readtable(compareTxtFile);

% Extract the second column (main_2)
main_2 = mainCsvData{:, 2};  %%%HACK TO SPEED THINGS UP, CHANGE!!!
compare_1 = compareTxtData{:, 1}; %%%HACK TO SPEED THINGS UP, CHANGE!!!
%compare_1 = compare_1(cellfun(@(x)contains(x, ' '),compare_1));
%main_2 = main_2(~cellfun(@(x)contains(x, 'figure', 'IgnoreCase', true), main_2));
%compare_1 = compare_1(cellfun(@(x)length(split(x))>4, compare_1));

% Initialize a cell array to store the most similar rows
similarRows = cell(length(main_2), 1);

% Iterate through each row of main_2
for i = 1:length(main_2)
    % Compare main_2 with all rows of compare1 (from other .csv file)
    % Implement Damerau-Levenshtein algorithm here (you can use external functions)
    % Find the most similar row in compare1

    main_row = main_2(i);
    if length(char(main_row)) < 3 | ...
            contains(char(main_row), 'figure', 'IgnoreCase', true)
    else
        min_dist = inf;
        min_dist_idx = -1;
           
        for j = 1:length(compare_1)
            DL_length = lev(char(main_row), char(compare_1(j)));
            %DL_length = editDistance(char(main_row), char(compare_1(j)), 'InsertCost',Inf,'DeleteCost',Inf);
            if ...%abs(length(char(main_row)) - length(char(compare_1(j)))) > 20 || ...
                     DL_length < min_dist
                min_dist = DL_length;
                min_dist_idx = j;
            end
        end
    
        % For demonstration purposes, let's assume the most similar row is 'similarRow'
        similarRow = char(compare_1(min_dist_idx));
        similarRows{i} = similarRow;
    end
    fprintf('%f percent done...\n', i/length(main_2) * 100.00)
end

% Create the output table
outputTable = table(mainCsvData{:, 1}, main_2, similarRows, ...
    'VariableNames', {'main_1', 'main_2', 'compare_1'});

% Write the output table to a new .csv file
outputFilePath = fullfile(folderPath, 'output.csv');
writetable(outputTable, outputFilePath);

disp(['Output saved to: ' outputFilePath]);

% https://blogs.mathworks.com/cleve/2017/08/14/levenshtein-edit-distance-between-strings/
function d = lev(s,t)
% Levenshtein distance between strings or char arrays.
% lev(s,t) is the number of deletions, insertions,
% or substitutions required to transform s to t.
% https://en.wikipedia.org/wiki/Levenshtein_distance

    s = char(s);
    t = char(t);
    m = length(s);
    n = length(t);
    x = 0:n;
    y = zeros(1,n+1);   
    for i = 1:m
        y(1) = i;
        for j = 1:n
            c = (s(i) ~= t(j)); % c = 0 if chars match, 1 if not.
            y(j+1) = min([y(j) + 1
                          x(j+1) + 1
                          x(j) + c]);
        end
        % swap
        [x,y] = deal(y,x);
    end
    d = x(n+1);
end