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
    
    lightvalue = trace(t).lightsensor;
    value = lightvalue.arg{1};
    
    light = '';
    
    if value < 1
        light = 'on';
        pin = 'D4';
        writeDigitalPin(model.controller, pin, 0)
        pause(1)
    else
        light = 'off';
        pin = 'D4';
        writeDigitalPin(model.controller, pin, 1)
        pause(1)
    end
    
    result = {t+1, 'light', light};
end