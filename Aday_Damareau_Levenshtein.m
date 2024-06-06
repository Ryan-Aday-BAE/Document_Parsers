clear all; clc;
warning('off');

fprintf("Ryan Aday\nDamareau Levenshtein File Comparer\n");
fprintf("Version 1.2: 06/05/2024\n");
fprintf("Using parfor for faster computing.\n");
fprintf("NOTE: Run this for either long or short string of text." + ...
    "\nThis looks for the magnitude of changes needed to " + ...
    "convert one string to the other. ..." + ...
    "\nDownside is speed relative to the size of dataesets fed.\n");

% Specify the folder containing the .csv files
folderPath = 'C:\Users\ryan.aday\Documents\DOORS DB\20240531\';

% Specify tolerance for matches
DL_tol = 0.52; %Found by trial and error

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get a list of .csv files in the folder
csvFiles = dir(fullfile(folderPath, '*.csv'));
txtFiles = dir(fullfile(folderPath, '*.txt'));
% Initialize variables
mainFile = fullfile(folderPath, csvFiles(1).name);
compareFile = fullfile(folderPath, txtFiles(1).name);

% Read the .csv file with the least rows
mainData = readtable(mainFile);
compareData = readtable(compareFile);

% Extract the second column (main_2)
main_2 = mainData{:, 2};
main_2_idx = mainData{:, 1};
compare_1 = compareData{:, 4}; 
compare_1_idx = compareData{:, 1}; 

[~, fileName, ~] = fileparts(compareFile);
outputFilePath = fullfile(folderPath, [fileName '_compare_1.csv']);
writecell(compare_1, outputFilePath);

[~, fileName, ~] = fileparts(compareFile);
outputFilePath = fullfile(folderPath, [fileName '_compare_1_idx.csv']);
writematrix(compare_1_idx, outputFilePath);

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
fprintf("\nPerforming Damareau Levenshtein (O(m*n/prll processes) time)...\n\n");
parfor i = 1:length(main_2)
    % Compare main_2 with all rows of compare1 (from other .csv file)
    % Implement Damerau-Levenshtein algorithm here (you can use external functions)
    % Find the most similar row in compare1

    main_row = main_2(i);

    min_dist = inf;
    min_dist_idx = -1;
       
    % Iterate for the absolute minDist between all compare_1 
    for j = 1:length(compare_1)
        DL_length = lev(char(main_row), char(compare_1(j)));

        % In-built function, too damned slow...
        %DL_length = editDistance(char(main_row), char(compare_1(j)), 'InsertCost',Inf,'DeleteCost',Inf); 
        
        if ...%abs(length(char(main_row)) - length(char(compare_1(j)))) > 20 || ...
                 DL_length < min_dist
            min_dist = DL_length;
            min_dist_idx = j;
        end
    end

    % For demonstration purposes, let's assume the most similar row is 'similarRow'
    if min_dist <= DL_tol
        similarRows{i} = char(compare_1(min_dist_idx));
        similarRowsIdx{i} = compare_1_idx(min_dist_idx);
    else
        similarRows{i} = char(compare_1(min_dist_idx));
        similarRowsIdx{i} = 'N/A';
    end
    distance{i} = min_dist;



    % Status timer printout (commented out for speed)
    %fprintf('%f percent done...\n', i/length(main_2) * 100.00)

end

% End timer
toc

% Create the output table
outputTable = table(main_2_idx, main_2, similarRows, similarRowsIdx, ...
    distance, ...
    'VariableNames', {'main_2_idx', 'main_2', 'compare_1', ...
    'compare_1_idx', 'Relative Distance'});
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
    d = x(n+1)/m;
end

