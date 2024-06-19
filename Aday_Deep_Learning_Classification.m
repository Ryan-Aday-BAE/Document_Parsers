clear all; clc;
warning('off');

fprintf("Ryan Aday\nDeep Learning Classifier\n");
fprintf("Version 1.0: 06/14/2024\n");


%% User inputs.

% Specify the folder containing the .csv files
folderPath = 'C:\Users\ryan.aday\Documents\DOORS DB\20240531\';

% Set up the training parameters
net.trainParam.epochs = 100; % Number of training epochs
net.trainParam.lr = 0.01;   % Learning rate
net.trainParam.goal = 1e-6; % Training goal (mean squared error)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

txtFiles = dir(fullfile(folderPath, '*.txt'));
compareFile = fullfile(folderPath, txtFiles(1).name);
compareData = readtable(compareFile);

%{
features = compareData{:, 4}; 
labels = compareData{:, 3}; 

% Create tokenizer
vocabulary = [convertCharsToStrings(unique(split([features{:}])))' ...
    "[PAD]" "[CLS]" "[UNK]" "[SEP]"];

tokenizer = bertTokenizer(vocabulary)
[tokenCodes,segments] = encode(tokenizer,features);

% Load your data (assuming you have 'features' and 'labels' variables)
% features: N-by-D matrix (N samples, D features)
% labels: N-by-1 vector (class labels)

% Create a feedforward neural network
hiddenLayerSize = 10; % Number of neurons in the hidden layer
net = feedforwardnet(hiddenLayerSize);



% Train the network
net = train(net, features', labels');

% Classify new data (assuming you have 'new_features' for testing)
predicted_labels = net(new_features');

% Display the predicted labels
disp(predicted_labels);
%}

cvp = cvpartition(compareData.SectionTitle, Holdout=0.375);
dataTrain = compareData(training(cvp),:);
dataValidation = compareData(test(cvp),:);

%documentsTrain = preprocessText(dataTrain.Description);

%% Training Data
% Create tokenizer
documentsTrain = preprocessText(dataTrain.Description);

TTrain = categorical(dataTrain.SectionTitle);
classNames = unique(TTrain)
numObservations = numel(TTrain)

%% Validation Data
documentsValidation = preprocessText(dataValidation.Description);
TValidation = categorical(dataValidation.SectionTitle);


enc = wordEncoding(documentsTrain);
numWords = enc.NumWords
XTrain = doc2sequence(enc,documentsTrain);
XValidation = doc2sequence(enc,documentsValidation);


embeddingDimension = 50;
ngramLengths = [2 3 4 5];
numFilters = 30;

minLength = min(doclength(documentsTrain));
layers = [ 
    sequenceInputLayer(1,MinLength=minLength)
    wordEmbeddingLayer(embeddingDimension,numWords,Name="emb")];
net = dlnetwork(layers);
%net = addLayers(net,layers);

numBlocks = numel(ngramLengths);
for j = 1:numBlocks
    N = ngramLengths(j);
    
    block = [
        convolution1dLayer(N,numFilters,Name="conv"+N,Padding="same")
        batchNormalizationLayer(Name="bn"+N)
        reluLayer(Name="relu"+N)
        dropoutLayer(0.2,Name="drop"+N)
        globalMaxPooling1dLayer(Name="max"+N)];
    
    net = addLayers(net,block);
    net = connectLayers(net,"emb","conv"+N);
end

numClasses = numel(classNames);

layers = [
    concatenationLayer(1,numBlocks,Name="cat")
    fullyConnectedLayer(numClasses,Name="fc")
    softmaxLayer(Name="soft")];

net = addLayers(net,layers);

for j = 1:numBlocks
    N = ngramLengths(j);
    net = connectLayers(net,"max"+N,"cat/in"+j);
end

figure
plot(net)
title("Network Architecture")


options = trainingOptions("adam", ...
    MiniBatchSize=20, ...
    ValidationData={XValidation,TValidation}, ...
    OutputNetwork="best-validation", ...
    Plots="training-progress", ...
    Metrics="accuracy", ...
    Verbose=false, ...
    InputDataFormats='CTB');

net = trainnet(XTrain,TTrain,net,"crossentropy",options);

%scores = minibatchpredict(net,XValidation,InputDataFormats="CTB");
%scores = predict(net, XValidation);
%{
YValidation = scores2label(scores,classNames);

figure
confusionchart(TValidation,YValidation)

accuracy = mean(TValidation == YValidation)
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function documents = preprocessText(textData)

% Tokenize the text.
documents = tokenizedDocument(textData);

% Convert to lowercase.0
documents = lower(documents);

% Erase punctuation.
documents = erasePunctuation(documents);

end
