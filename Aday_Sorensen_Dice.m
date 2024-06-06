clear all; clc;
warning('off');

fprintf("Ryan Aday\nDSorensen Dice File Comparer\n");
fprintf("Version 1.0: 06/05/2024\n");
fprintf("NOTE: Run this for long strings of text only." + ...
    "\nThis fails to accurately map for smaller string " + ...
    "sizes due to higher significance for matched pairs" + ...
    "relative to overall size.\n");

% Specify the folder containing the .csv files
folderPath = 'C:\Users\ryan.aday\Documents\DOORS DB\20240531\';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get a list of .csv files in the folder
csvFiles = dir(fullfile(folderPath, '*.csv'));
txtFiles = dir(fullfile(folderPath, '*.txt'));
% Initialize variables
mainFile = fullfile(folderPath, txtFiles(1).name);
compareFile = fullfile(folderPath, csvFiles(1).name);

% Read the .csv file with the least rows
mainData = readtable(mainFile);
compareData = readtable(compareFile);

% Extract the second column (main_2)
main_2 = mainData{:, 4};
main_2_idx = mainData{:, 1};
compare_1 = compareData{29:493, 2}; %%%HACK TO SPEED THINGS UP, CHANGE!!!
compare_1_idx = compareData{29:493, 1}; %%%HACK TO SPEED THINGS UP, CHANGE!!!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Manipulation for different files, commented out
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
main_2 = mainCsvData{:, 4}; 
main_2_idx = mainCsvData{:, 1};
main_2_cat = mainCsvData{:, 3};
compare_1 = compareTxtData{:, 4};
compare_1_idx = compareTxtData{:, 1};
compare_1_cat = mainCsvData{:, 3};
%}

%compare_1 = compare_1(cellfun(@(x)contains(x, {'shall', '[ACIF_F'}),compare_1)); % Only isolate for the 'shall' requirements
%compare_1 = compare_1(~cellfun(@(x)contains(x, 'figure', 'IgnoreCase', true),compare_1)); % Remove all Figure data
%compare_1 = compare_1(~cellfun(@(x)contains(x, 'Table '),compare_1)); % Remove all Table data
%compare_1 = compare_1(cellfun(@(x)contains(x, '[ACIF_F'),compare_1)); % Only isolate for the 'bracketed' requirements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[~, fileName, ~] = fileparts(compareFile);
outputFilePath = fullfile(folderPath, [fileName '_compare_1.csv']);
writecell(compare_1, outputFilePath);

[~, fileName, ~] = fileparts(compareFile);
outputFilePath = fullfile(folderPath, [fileName '_compare_1_idx.csv']);
writecell(compare_1_idx, outputFilePath);

% Initialize a cell array to store the most similar rows
similarRows = cell(length(main_2), 1);
similarRowsIdx = cell(length(main_2), 1);
distance = cell(length(main_2), 1);

% Create cluster for parfor
% Documentation: https://www.mathworks.com/help/parallel-computing/parfor.html
fprintf("\nSetting up parcluster for parfor.\n");
fprintf("Execution speed determined heavily by hardware.\n");
cluster = parcluster;
fprintf("\nParcluster created.\n");

% Start timer
tic 

% Iterate through each row of main_2
fprintf("\nPerforming Srenstein Dice (O(n/prll processes) time)...\n\n");
parfor i = 1:length(main_2)
    % Compare main_2 with all rows of compare1 (from other .csv file)
    % Implement Damerau-Levenshtein algorithm here (you can use external functions)
    % Find the most similar row in compare1
       
    % Iterate for the absolute minDist between all compare_1 
    main_row = main_2(i);
    if length(char(main_row)) < 5 | ...
            contains(char(main_row), 'figure', 'IgnoreCase', true)
    else
        max_corr = -inf;
        max_corr_idx = -1;
           
        for j = 1:length(compare_1)
            corr = sSimilarity(char(main_row), char(compare_1(j)));
            %DL_length = compareMBLeven(char(main_row), char(compare_1(j)), false);

            % In-built function, too damned slow...
            %DL_length = editDistance(char(main_row), char(compare_1(j)), 'InsertCost',Inf,'DeleteCost',Inf); 
            
            if ...%abs(length(char(main_row)) - length(char(compare_1(j)))) > 20 || ...
                     corr > max_corr
                max_corr = corr;
                max_corr_idx = j;
            end
        end
    
        % For demonstration purposes, let's assume the most similar row is 'similarRow'
        similarRows{i} = char(compare_1(max_corr_idx));
        similarRowsIdx{i} = compare_1_idx(max_corr_idx);
        distance{i} = max_corr;

    end

    % Status timer printout (commented out for speed)
    %fprintf('%f percent done...\n', i/length(main_2) * 100.00)

end

% End timer
toc

% Create the output table
outputTable = table(main_2_idx, main_2, similarRows, similarRowsIdx, ...
    distance, ...
    'VariableNames', {'main_2_idx', 'main_2', 'compare_1', ...
    'compare_1_idx', 'max_correlation'});
%{
outputTable = table(main_2_idx, main_2_cat, main_2, similarRows, similarRowsIdx, compare_1_cat,...
    'VariableNames', {'main_2_idx', 'main_2_cat', 'main_2', 'compare_1', 'compare_1_idx', 'compare_1_cat'});
%}

% Write the output table to a new .csv file
[~, fileName, ~] = fileparts(compareFile);
outputFilePath = fullfile(folderPath, [fileName '_output.csv']);
writetable(outputTable, outputFilePath);

disp(['Output saved to: ' outputFilePath]);

% Clear all vars except outputTable & compare_1
clearvars -except outputTable compare_1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function similarity = sSimilarity(sa1, sa2)
    % Compare two strings to see how similar they are.
    % Answer is returned as a value from 0 - 1.
    % 1 indicates a perfect similarity (100%) while 0 indicates no similarity (0%).
    % Algorithm is set up to closely mimic the mathematical formula from
    % the article describing the algorithm, for clarity.
    % Algorithm source site: http://www.catalysoft.com/articles/StrikeAMatch.html

    % Convert input strings to lowercase and remove whitespace
    %s1 = regexprep(sa1, '\s', '');
    %s2 = regexprep(sa2, '\s', '');

    % Get pairs of adjacent letters in each string
    pairs_s1 = sa1(1:end-1) + sa1(2:end);
    pairs_s2 = sa2(1:end-1) + sa2(2:end);

    % Calculate intersection of pairs
    common_pairs = intersect(pairs_s1, pairs_s2);

    % Calculate similarity
    similarity_num = 2 * numel(common_pairs);
    similarity_den = numel(pairs_s1) + numel(pairs_s2);
    similarity = similarity_num / similarity_den;
end


