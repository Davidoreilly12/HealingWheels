function [dist] = Dist_metric(Var,Group)


%A function to quantify the pointwise distance of each sample from the mean (i.e. the signal) of each group/condition.

%Input: 
    % Var is a single variable consisting of samples from different
        %groups/conditions etc.
    %Group is a categorical variable describing the affiliation of each
    %sample in Var

%Output: dist is a cell array of transformed variables where dist{1} is the
%distance of each sample in Var from Group==1 and so forth.



Var_norm=normalize(Var); %Normalize the data to unit variance

g=unique(Group);

avgs=[];
for i=1:length(g)
    avgs=[avgs,mean(Var_norm(g(i)))]; %Extract group-specific means from the normalised data
end

dist={};
for i=1:size(avgs,2)
    d=[];
    for ii=1:length(Var_norm)
        d=[d;abs(avgs(i)-Var_norm(ii))]; %Quantify the distance of each sample in each group from the mean each group (inclusive)
    end
    dist=cat(2,dist,d);
end

end
