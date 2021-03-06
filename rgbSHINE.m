%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Name         : RGB Luminance Optimizer                                  %
%                                                                         %
% Description  : to normalize RGB images by using SHINE toolbox function  %
%                                                                         %
%                                                                         %
% Last updated : 7 July 2015                                              %
%                                                                         %
% Copyright 2015, Research Center for Brain Communication,                                %
% Kochi university of technology.                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Function : rgbSHINE
% Input : 
%  - width  : width of resized images, 
%             positive integer
%  - height : height of resized images, 
%             positive integer
% Output : 
%  - rmseAvg  : Vector of averaged Root-Mean-Square error, 
%               rmseAvg(1, 1) as Red Images
%               rmseAvg(1, 2) as Green Images
%               rmseAvg(1, 3) as Blue Images
%  - rmseStd  : Vector of STD Root-Mean-Square error, 
%               rmseStd(1, 1) as Red Images
%               rmseStd(1, 2) as Green Images
%               rmseStd(1, 3) as Blue Images
%  - ssimAvg  : Vector of averaged Structural Similarity, 
%               ssimAvg(1, 1) as Red Images
%               ssimAvg(1, 2) as Green Images
%               ssimAvg(1, 3) as Blue Images
%  - ssimStd  : Vector of STD Structural Similarity, 
%               ssimStd(1, 1) as Red Images
%               ssimStd(1, 2) as Green Images
%               ssimStd(1, 3) as Blue Images
function [rmseAvg, rmseStd, ssimAvg, ssimStd] = rgbSHINE (width, height)
    disp('START SHINE');

    % Check Input / Output path
    inputpath  = strcat(pwd, '/Input/');
    outputpath = strcat(pwd, '/Output/');
    addpath(inputpath);
    
    % Read all filenames
    allFiles     = dir(inputpath);
    allFilenames = {allFiles(arrayfun(@(x) ~x.isdir, allFiles)).name};
    
    % Get number of filenames
    allFileSize  = size(allFilenames, 2);
    
    % allocated memory
    inputImageCell       = cell(1, allFileSize);
    outputImageCell      = cell(1, allFileSize);
    inputRedImagesCell   = cell(1, allFileSize);
    inputGreenImagesCell = cell(1, allFileSize);
    inputBlueImagesCell  = cell(1, allFileSize);
    rmseVector           = zeros(3, allFileSize);
    ssimVector           = zeros(3, allFileSize);
    rmseAvg              = zeros(1, 3);
    rmseStd              = zeros(1, 3);
    ssimAvg              = zeros(1, 3);
    ssimStd              = zeros(1, 3);
    
    for i = 1: 1: allFileSize
        % Read images
        try 
            inputImageCell{1, i} = imread(allFilenames{1, i});
        catch
            error(strcat('Error at file : ', allFilenames{1, i}))
        end
        
        % Resize images
        inputImageCell{1, i} = ...
            imresize(inputImageCell{1, i}, [height, width]);
        
        % Seperated RGB images
        inputRedImagesCell{1, i}   = inputImageCell{1, i}(:, :, 1);
        inputGreenImagesCell{1, i} = inputImageCell{1, i}(:, :, 2);
        inputBlueImagesCell{1, i}  = inputImageCell{1, i}(:, :, 3);
    end
    
    % SHINE toolbox, call SHINE function
    disp(sprintf('\n'));  %#ok<DSPS>
    disp('RED IMAGES');
    outputRedImagesCell   = SHINE(inputRedImagesCell);
    disp(sprintf('\n'));  %#ok<DSPS>
    disp('GREEN IMAGES');
    outputGreenImagesCell = SHINE(inputGreenImagesCell);
    disp(sprintf('\n'));  %#ok<DSPS>
    disp('BLUE IMAGES');
    outputBlueImagesCell  = SHINE(inputBlueImagesCell);
    
    for i = 1: 1: allFileSize
        % Get size of images to create output images
        [outputWidth, outputHeight]    = size(outputRedImagesCell{1});
        outputImageCell{1, i}          = ...
            uint8(zeros(outputWidth, outputHeight, 3));

        % put it back ...
        outputImageCell{1, i}(:, :, 1) = outputRedImagesCell{1, i};
        outputImageCell{1, i}(:, :, 2) = outputGreenImagesCell{1, i};
        outputImageCell{1, i}(:, :, 3) = outputBlueImagesCell{1, i};

        % save output images
        imwrite(outputImageCell{1, i}, strcat(outputpath, allFilenames{1, i}));

        % calculate RMSE & SSIM
        for j = 1: 1: 3
            rmseVector(j, i) = ...
                getRMSE ( ...
                    inputImageCell{1, i}(:, :, j), ...
                    outputImageCell{1, i}(:, :, j));
            ssimVector(j, i) = ...
                ssim_index ( ...
                    inputImageCell{1, i}(:, :, j), ...
                    outputImageCell{1, i}(:, :, j));
        end
    end

    % Calculate mean and std of RMSE & SSIM in RGB images
    for i = 1: 1: 3
        rmseAvg(1, i) = mean(rmseVector(i, :));
        rmseStd(1, i) = std(rmseVector(i, :));
        ssimAvg(1, i) = mean(ssimVector(i, :));
        ssimStd(1, i) = std(ssimVector(i, :));
    end
    
    disp(sprintf('\n'));  %#ok<DSPS>
    disp(strcat(num2str(allFileSize), ' images were done.'));
    return;
end

% EOF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
