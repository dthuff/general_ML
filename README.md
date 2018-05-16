General matlab functions for training different sorts of classifiers.

All classifers/train_* functions have the same input/ouput signature.

	Inputs:
	
		features - an N by F matrix for a dataset with N observations and F features.
		
		labels - an N by 1 matrix of ground truth target labels.  For C classes, integers from 0 to C-1 are interpreted as different class labels.
		
		cv_folds - number of cross validation folds to perform
		
		positive_class - integer label for the positive class.  Should be one of set 0 to C-1

	Outputs:
	
		cv_X, cv_Y - two N+1 by 3 matrices containing the x and y coordinates of the classifier ROC curve (1st column), with lower and upper bounds for pointwise uncertainty (2nd and 3rd columns).
		
		cv_T - an N+1 by 1 matrix with the thresholds corresponding to each pt on the ROC curve
		
		cv_AUC - a 3 by 1 matrix with the classifier AUC averaged over cv folds, plus lower and upper bounds

All classifiers are set up to do hyperparameter optimization.

Included classifiers are:

	kNN - k Nearest Neighbors
	
	RF  - Random Forest
	
	SVM - Support Vector Machine
	
	NB  - Naive Bayes
	
Other utility functions

	classifiers_walkthrough - heavily commented walkthrough of how to use the classifiers
	
	normalize_features - performs zero mean, unit variance feature-wise normalization
	
	dummy_data - for creating dummy data sets for debugging/learning


