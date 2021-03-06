function [ ROC, pred ] = train_univariate( features, labels, cv_folds, positive_class )
%Use a univariate feature as a predictor of labels.

% Inputs
%   features - N x 1 feature vector.  Each row is an observation
%   labels - N x 1 labels matrix.  Class labels for each observation
%   cv_folds - an int.  number of cross validation folds
%   positive_class - type must match labels.  Identifies the positive label
%   class for computing ROC metrics.
%   opt - boolean to perform hyperparameter optimization or not.  Increases
%   training time significantly.
% 
% Outputs
%   ROC - structure containing ROC statistic information
%       cv_X, cv_Y - coordinates of cv-averaged ROC curve with pointwise
%       uncertainties
%       cv_T - score thresholds corresponding to each pt on ROC curve
%       cv_AUC - cv-averaged Area Under the ROC Curve, with lower and upper
%       bounds

%   pred - structure containing prediction information
%        cv_true_labels_dict - test sets true labels
%        cv_pred_labels_dict - test sets predicted labels
%        cv_score_dict - test sets predicted scores 

%%
    % set up cv partitions
    cv = cvpartition(length(features),'KFold',cv_folds);

    cv_true_label_dict = cell(cv_folds, 1);
    cv_pred_label_dict = cell(cv_folds, 1);
    cv_pred_score_dict = cell(cv_folds, 1);

    % for each cv fold
    for i=1:cv_folds
        
        % divide data into training, testing sets
        test_ind = find(training(cv, i) == 0);

        % use univariate feature value as a test score
        labels_test = labels(test_ind,:);

        %store test labels, predictions
        cv_true_label_dict{i} = labels_test;
        cv_pred_score_dict{i} = features(test_ind, :);
        
        %close plots generated by OptimizeHyperParamters
        close all; 
    end
        
    % perform cv-fold averaging of test set predictions
    [ cv_X, cv_Y, cv_T, cv_AUC ] = perfcurve(cv_true_label_dict, ...
                                             cv_pred_score_dict, ...
                                             positive_class);
    
    %% store useful things in output structs

    % true labels, predicted labels and prediction scores
    pred.cv_true_labels_dict = cv_true_label_dict;
    pred.cv_pred_labels_dict = cv_pred_label_dict;
    pred.cv_score_dict = cv_pred_score_dict;
    
    % ROC curve points, thresholds, AUC
    ROC.cv_X = cv_X;
    ROC.cv_Y = cv_Y;
    ROC.cv_T = cv_T;
    ROC.cv_AUC = cv_AUC;
end



function oobErr = oobErrRF(params, X, Y)
% helper function for hyperparameter tuning.  If you add more tunable
% hyperparameters, add them to TreeBagger here too
    randomForest = TreeBagger(params.num_trees, X, Y,'Method','classification',...
        'OOBPrediction','on','MinLeafSize',params.min_ls,...
        'NumPredictorstoSample',params.num_pts);
    oobErr = oobError(randomForest, 'Mode', 'ensemble');
end

