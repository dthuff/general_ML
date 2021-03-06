addpath('./classifiers/');
addpath('./util/');
%% Data Creation
% First, lets create some fake data to train our classifier on.  We'll
% create two sets of points clustered around center1 and center2 in a
% 3-dimensional feature space.  We give some variance to the feature values
% to let the clusters overlap a bit.
center1 = [10, 10, 10];
center2 = [50, 50, 30];
n_obs = 200;
feat_var = [25, 40, 20];

[features, labels] = create_dummy_data(n_obs, feat_var, center1, center2);

% We normalize each feature to have zero mean and unit variance.  This
% prevents features with inherently larger values from dominating the
% performance of some classifiers
n_features = normalize_features(features);

% We can plot our data in feature space and color the points based on their
% labels to assess the difficulty of our classification problem.  If the
% clusters are well separated, the problem should be easier.  In general,
% datasets with more than three features are not as easily visualized
% without some dimensionality reduction.
figure('position',[50, 200, 1000, 500]);
subplot(1, 2, 1);
scatter3(features(:,1), features(:,2), features(:,3), 10, labels)
xlabel('x (feature 1)');
ylabel('y (feature 2)');
zlabel('z (feature 3)');
title('Points in Feature Space');

%plot normalized clusters
subplot(1, 2, 2);
scatter3(n_features(:,1), n_features(:,2), n_features(:,3), 10, labels)
xlabel('x\_norm (feature 1)');
ylabel('y\_norm (feature 2)');
zlabel('z\_norm (feature 3)');
title('Points in Normalized Feature Space');

%% Training
% Now we're ready to train our classifier.  We set up a number of cross
% validation folds to prevent model overfitting and estimate the model
% performance independent of which subset of the data is used for training
% We also define the positive class, which is one of our labels, and
% optionally decide whether or not to perform hyperparameter optimization.
% Setting opt to true may increase performance, but can increase training
% time significantly. For now, we will not worry about it.
cv_folds = 4;
positive_class = 1;
opt = false;

% Here we train a support vector machine, which classifies data by 
% determining an optimal hyperplane in feature space to separate the data 
% by class.  Training should take 30-60 sec per cv_fold.
[ ROC, pred, Mdl ] = train_svm( n_features, labels,...
                                          cv_folds, ...
                                          positive_class, ...
                                          opt );

%% Model Assessment
% The training functions return information to construct an ROC curve
% describing our classifier performance.  Lets see how we did.  Increasing
% cluster separation, or decreasing feature variance should improve
% performance.  Increasing the number of cross validation folds should
% decrease the uncertainty in the ROC points and the AUC.

% plot mean ROC with errorbars
f = figure('pos',[100,100,600,500]);
set(gcf, 'color','w');
plot(1-ROC.cv_X(:,1)', ROC.cv_Y(:,1)', 'k', 'LineWidth', 1.5); 
hold on; box on; grid on;

% pick some indices for plotting errorbars at
some_inds = round(1:size(ROC.cv_X,1)/20:size(ROC.cv_X,1));

errorbar(1-ROC.cv_X(some_inds,1), ROC.cv_Y(some_inds,1),...
        abs(ROC.cv_Y(some_inds,1)-ROC.cv_Y(some_inds,2)),...
        abs(ROC.cv_Y(some_inds,1)-ROC.cv_Y(some_inds,3)),...
        abs(ROC.cv_X(some_inds,1)-ROC.cv_X(some_inds,2)),...
        abs(ROC.cv_X(some_inds,1)-ROC.cv_X(some_inds,3)),...
        '.','color','k', 'linewidth',1.5);
xlim([0,1]);
ylim([0,1]);
set(gca,'Xdir','reverse');
xlabel('Specificity','fontsize',14)
ylabel('Sensitivity','fontsize',14)

mean_auc_str = sprintf('%.2f', ROC.cv_AUC(1));
sd_auc_str = sprintf('%.2f', abs(ROC.cv_AUC(1)-ROC.cv_AUC(2)));

text(0.02, 0.05, ['AUC = ' mean_auc_str '\pm' sd_auc_str],...
                'fontsize',14,...
                'HorizontalAlignment','right');
title(['SVM Classification Performance (k = ' num2str(cv_folds) ')'],...
        'fontsize',14);

