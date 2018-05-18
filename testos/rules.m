function [ fncs ] = rules()
    % DO NOT EDIT
    fncs = l2.getRules();
    for i=1:length(fncs)
        fncs{i} = str2func(fncs{i});
    end
end

%ADD RULES BELOW

% function result = ddr1( trace, params, t)
%     result = {};
%     a=arduino();
%     value = readVoltage(a, 'A0');
%     result = { result{:} {t+1, 'emg', {value}} };
% end

% function result = ddr2(trace, params, t)
%     result={};
%     a=arduino();
%     playTone(a,'D5',2400,10);
% end
% 
% function result = ddr3(trace, params, t)
%     result={};
%     a=arduino();
%     
%     playTone(a,'D3',10,30);
% end

function result = ddr4(trace, params, t)
    result={};
    a=arduino();
    s = servo(a, 'D4', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
    for angle = 0:0.2:1
        writePosition(s, angle);
        current_pos = readPosition(s);
        current_pos = current_pos*180;
        fprintf('Current motor position is %d degrees\n', current_pos);
        pause(2);
    end
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