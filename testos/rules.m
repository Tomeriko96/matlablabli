function [ fncs ] = rules()
    % DO NOT EDIT
    fncs = l2.getRules();
    for i=1:length(fncs)
        fncs{i} = str2func(fncs{i});
    end
end

%ADD RULES BELOW

function result = ddr1(model, trace, params, t)
    result = {};
    
    distancesensor = trace(t).distancesensorsensor;
    value = distancesensor.arg{1}
    
    result = {t+1, 'distancesensor', value};
end