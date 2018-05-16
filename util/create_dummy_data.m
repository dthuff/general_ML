function [features, labels] = create_dummy_data(N, va, center1, center2)
%CREATE_DUMMY_DATA - creates a set of 3 dimensional feature values and 
% class labels for use in a two class classification problem.  

%   features is a 2*n_obs by 3 matrix of feature values
%   labels is a 2*n_obs by 1 matrix of class labels (0 or 1)

    features = [center1(1)+va(1).*randn([N,1]),...
                center1(2)+va(2).*randn([N,1]),...
                center1(3)+va(3).*randn([N,1]);...
                center2(1)+va(1).*randn([N,1]),...
                center2(2)+va(2).*randn([N,1]),...
                center2(3)+va(3).*randn([N,1])];
            
    labels = [zeros([N,1]); ones([N,1])];

    % shuffle features, labels
    r = randperm(size(features,1));
    features = features(r,:);
    labels = labels(r,:);
    
end

