function [ normalized_features ] = normalize_features( features )
%NORMALIZE_FEATURES normalizes features to have zero mean, unit variance

    normalized_features = (features - mean(features))./sqrt(var(features));

end

