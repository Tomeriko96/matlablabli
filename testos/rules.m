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

% function result = ddr2( trace, params, t)
%     result = {};
%     a=arduino();
%     configurePin(a,'D9', 'DigitalOutput')
%     configurePin(a,'D10', 'DigitalInput')
%     writeDigitalPin('D9', 0);
%     writeDigitalPin('D9', 1);
%     writeDigitalPin('D9', 0);
%     duration = pulseIn('D10', 1);
%     distance= duration*0.034/2
%     result = { result{:} {t+1, 'jump_height', {distance}} };
% end