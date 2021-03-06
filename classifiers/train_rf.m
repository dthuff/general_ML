function [ ROC, pred, Mdl ] = train_rf( features, labels, cv_folds, positive_class, opt )
%Trains a Random Forest model on data features with classes labels.

% Inputs
%   features - N x F features matrix.  Each row is an observation, each
%   column is a feature
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

%   Mdl - trained model object
%%
    if opt
        % list hyperparameters you want to tune, add them to hyperparametersRF
        % minimum leaf size
        min_ls = optimizableVariable('min_ls',[1, 20],'Type','integer');
        % number of predictors to sample
        num_pts = optimizableVariable('num_pts',[1, size(features,2)+1],'Type','integer');
        % number of trees
        num_trees = optimizableVariable('num_trees',[50, 500],'Type','integer');
        hyperparametersRF = [min_ls; num_pts; num_trees];

        % determine optimal hyperparamters
        opt_fun = @(params) oobErrRF(params, features, labels);

        results = bayesopt(opt_fun, hyperparametersRF,...
           'AcquisitionFunctionName','expected-improvement-plus','Verbose',0);

        opt_h_params = results.XAtMinObjective;
    end

    % set up cv partitions
    cv = cvpartition(length(features),'KFold',cv_folds);

    cv_true_label_dict = cell(cv_folds, 1);
    cv_pred_label_dict = cell(cv_folds, 1);
    cv_pred_score_dict = cell(cv_folds, 1);

    % for each cv fold
    for i=1:cv_folds
        
        % divide data into training, testing sets
        train_ind = find(training(cv, i) > 0);
        test_ind = find(training(cv, i) == 0);

        features_train = features(train_ind, :);
        features_test = features(test_ind, :);

        labels_train = labels(train_ind);
        labels_test = labels(test_ind);

        % create and train random forest model
        if opt
            Mdl = TreeBagger(opt_h_params.num_trees, features_train, labels_train,...
                'OOBPrediction','On','Method','classification',...
                'MinLeafSize',opt_h_params.min_ls,...
                'NumPredictorstoSample',opt_h_params.num_pts);
        else
            Mdl = TreeBagger(100, features_train, labels_train,...
                'OOBPrediction','On','Method','classification');
        end

        % use trained RF to produce test set predictions
        [predicted_test_labels, predicted_test_scores] = predict(Mdl, features_test);

        %store test labels, predictions
        cv_true_label_dict{i} = labels_test;
        cv_pred_label_dict{i} = predicted_test_labels;
        cv_pred_score_dict{i} = predicted_test_scores(:,2);
        
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

