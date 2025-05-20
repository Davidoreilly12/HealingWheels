function dist = Dist_metric(Var, Group)
% Compute the distance of each value from the mean of the other group.
%
% Input:
%   Var   - numeric vector of values.
%   Group - two-way categorical or numeric vector (length must match Var).
%
% Output:
%   dist  - numeric vector of distances from the mean of the other group.

    % Check input validity
    if length(Var) ~= length(Group)
        error('Inputs Var and Group must be the same length.');
    end

    % Normalize Var while handling NaNs
    Var_norm = (Var - nanmean(Var)) ./ nanstd(Var);

    % Identify unique groups (assumed to be two)
    g = unique(Group);
    if numel(g) ~= 2
        error('This function requires exactly two groups.');
    end

    % Compute means of each group
    mean_g1 = mean(Var_norm(Group == g(1) & ~isnan(Var_norm)), 'omitnan');
    mean_g2 = mean(Var_norm(Group == g(2) & ~isnan(Var_norm)), 'omitnan');

    % Allocate output
    dist = NaN(size(Var_norm));

    % Compute distance from the opposite group's mean
    for ii = 1:length(Var_norm)
        if ~isnan(Var_norm(ii))
            if Group(ii) == g(1)
                dist(ii) = abs(Var_norm(ii) - mean_g2);
            elseif Group(ii) == g(2)
                dist(ii) = abs(Var_norm(ii) - mean_g1);
            end
        end
    end
end

