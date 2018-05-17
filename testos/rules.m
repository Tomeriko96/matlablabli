function [ fncs ] = rules()
    % DO NOT EDIT
    fncs = l2.getRules();
    for i=1:length(fncs)
        fncs{i} = str2func(fncs{i});
    end
end

%ADD RULES BELOW

function result = ddr1( trace, params, t)
    result = {};
    a=arduino();
    value = readVoltage(a, 'A0');
    result = { result{:} {t+1, 'emg', {value}} };
end