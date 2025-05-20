function model = forwardSelectionWald(X, y)
% Performs forward selection using Wald's criterion
% Inclusion: p < 0.05
% Exclusion: p > 0.1
%
% INPUTS:
%   X - Predictor matrix (n x p)
%   y - Response vector (n x 1)
%
% OUTPUT:
%   model - Final fitted linear model object

% Convert to table for fitlm compatibility
data = array2table(X);
data.y = y;

% Initialization
[n, p] = size(X);
included = false(1, p);
remaining = 1:p;
threshold_in = 0.05;
threshold_out = 0.1;
changed = true;

while changed
    changed = false;

    % Try adding variables
    pvals = ones(1, p);
    for j = remaining
        test_vars = find(included);
        test_vars = [test_vars, j];
        predictors = data(:, [test_vars, p+1]); % +1 because y is last column
        predictors.Properties.VariableNames{end} = 'y';

        formula_str = ['y ~ ', strjoin(predictors.Properties.VariableNames(1:end-1), ' + ')];
        model_temp = fitlm(predictors, formula_str);

        coef_table = model_temp.Coefficients;
        idx = strcmp(coef_table.Properties.RowNames, predictors.Properties.VariableNames{end-1});
        if any(idx)
            pvals(j) = coef_table.pValue(idx);
        end
    end

    [min_pval, best_j] = min(pvals);
    if min_pval < threshold_in
        included(best_j) = true;
        remaining = setdiff(1:p, find(included));
        changed = true;
    end

    % Try removing variables
    current_vars = find(included);
    if isempty(current_vars)
        continue;
    end

    for j = current_vars
        test_vars = setdiff(current_vars, j);
        if isempty(test_vars)
            formula_str = 'y ~ 1';
            model_temp = fitlm(data, formula_str);
        else
            predictors = data(:, [test_vars, p+1]);
            predictors.Properties.VariableNames{end} = 'y';
            formula_str = ['y ~ ', strjoin(predictors.Properties.VariableNames(1:end-1), ' + ')];
            model_temp = fitlm(predictors, formula_str);
        end
        coef_table = model_temp.Coefficients;

        if j <= height(coef_table)-1
            if coef_table.pValue(j+1) > threshold_out
                included(j) = false;
                remaining = setdiff(1:p, find(included));
                changed = true;
            end
        end
    end
end

% Final model
included_vars = find(included);
if isempty(included_vars)
    formula_str = 'y ~ 1';
    model = fitlm(data, formula_str);
else
    predictors = data(:, [included_vars, p+1]);
    predictors.Properties.VariableNames{end} = 'y';
    formula_str = ['y ~ ', strjoin(predictors.Properties.VariableNames(1:end-1), ' + ')];
    model = fitlm(predictors, formula_str);
end
end

