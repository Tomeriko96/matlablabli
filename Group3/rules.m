function [ fncs ] = rules()
    % DO NOT EDIT
    fncs = l2.getRules();
    for i=1:length(fncs)
       fncs{i} = str2func(fncs{i});
    end
end
%ADD RULES BELOW

%% Domain model
function result = ddr1( trace, params, t)
    % From acceleration and mass to force
    result = {};
    force = 0;
    for acceleration = l2.getall(trace, t, 'acceleration', {NaN})
        a = acceleration.arg{1};
        M = params.mass;
        force = M * a;
    end

    result = {t+1, predicate('force', force)};
end

function result = ddr2( trace, params, t)
    % from jump height and force to work
    result = {};
    Work = 0;
    for force = l2.getall(trace, t, 'force', {NaN})
        F = force.arg{1};
        for jump_height = l2.getall(trace, t, 'force', {NaN})
            d = jump_height.arg{1};
        end
        Work = F * d;
    end
    result = {t+1, predicate('work', Work)};
end

function result = ddr3( trace, params, t)
    % from work to rest interval
    result = {};
    rest = 0;
    for work = l2.getall(trace, t, 'work', {NaN})
        if work >=params.maximal_Work
            rest = 60;
        elseif work <= params.minimal_Work
            rest = 50;
        end
        result = { result{:} {t+1, 'rest', {rest}} };
    end
end

function result = ddr4( trace, params, t)
    % from heart rate to blood-oxygen saturation
    result = {};
    BOS = params.BOS;
    for heart_rate = l2.getall(trace, t, 'heart_rate', {NaN})
        if abs(params.heart_rate - heart_rate) > 0
            BOS = params.BOS - (abs(params.heart_rate - heart_rate)/2);
        else
            BOS = params.BOS;
        end
        result = { result{:} {t+1, 'blood_oxygen_saturation', {BOS}} };
    end
end

function result = ddr5( trace, params, t)
    % from blood-oxygen saturation to muscle temperature
    result = {};
    Mtemp = params.muscle_temp;
    for BOS = l2.getall(trace, t, 'blood_oxygen_saturation', {NaN})
        if abs(params.BOS - BOS) > 0
            Mtemp = params.muscle_temp - (abs(params.BOS - BOS)/20);
        else
            Mtemp = params.muscle_temp;
        end
        result = { result{:} {t+1, 'muscle_temperature', {Mtemp}} };
    end
end

function result = ddr6( trace, params, t)
    % from flight time to vertical velocity
    result = {};
    velocity = (params.g * t)/2;
    result = { result{:} {t+1, 'velocity', {velocity}} };
end

function result = ddr7( trace, params, t)
    % From force, vertical velocity, muscle temperature, and emg to power
    result = {};
    power = 'low';
    for force = l2.getall(trace, t, 'force', {NaN})
        F = force.arg{1};
        for velocity = l2.getall(trace, t, 'velocity', {NaN})
            v = velocity.arg{1};
            for Mtemp = l2.getall(trace, t, 'muscle_temperature', {NaN})
                Temp = Mtemp.arg{1};
                for emgmeasure = l2.getall(trace, t, 'emg', {NaN})
                    emg = emgmeasure.arg{1};
                    sum = (F * v * Temp * emg)/10000;
                    if sum < params.power_range_1
                        power = 'low';
                    else
                        power = 'high';
                    end
                end
            end

        end

    end
    result = { result{:} {t+1, 'power', {power}} };
end

%% Analysis model
function result = adr0( trace, params, t)
    %from observation to belief
    result = {};
    for elem = trace(t).observation
        observation = elem.arg{1};
        result = { result{:} {t+1, 'belief', {observation}} };
    end
end
function result = adr1( trace, params, t )
    %from power to force
    result = {};
    for belief = l2.getall(trace, t, 'belief', {NaN, predicate('power', {NaN, NaN})})
        power = belief.arg{1};
        force = power.arg{1};
        result = { result{:} {t+1, 'belief', {predicate('force', {force})}} };
    end
end
function result = adr2( trace, params, t )
    %from power to emg
    result = {};
    for belief = l2.getall(trace, t, 'belief', {NaN, predicate('power', {NaN, NaN})})
        power = belief.arg{1};
        emg = power.arg{1}
        result = { result{:} {t+1, 'belief', {predicate('emg', {emg})}} };
    end
end
function result = adr3( trace, params, t )
    %from power to muscle temperature
    result = {};
    for belief = l2.getall(trace, t, 'belief', {NaN, predicate('power', {NaN, NaN})})
        power = belief.arg{1};
        muscle_temp = power.arg{1}
        result = { result{:} {t+1, 'belief', {predicate('muscle_temperature', {muscle_temp})}} };
    end
end
function result = adr4( trace, params, t )
    %from force to work
    result = {};
    for belief = l2.getall(trace, t, 'belief', {NaN, predicate('force', {NaN, NaN})})
        force = belief.arg{1}
        work = force.arg{1}
        result = { result{:} {t+1, 'belief', {predicate('work', {work})}} };
    end
end
function result = adr5( trace, params, t )
    %from work to jump height
    result = {};
    for belief = l2.getall(trace, t, 'belief', {NaN, predicate('work', {NaN, NaN})})
        work = belief.arg{1};
        jump_height = work.arg{1}
        result = { result{:} {t+1, 'belief', {predicate('jump_height', {jump_height})}} };
    end
end
%% Support model
function result = sdr0( trace, params, t)
    %from assume to belief under that assumption
    result = {};
    for assume = trace(t).assume
        assumption = assume.arg{1};
        result = { result{:} {t+1, 'assumption', {assumption, assumption}} };
    end
end

function result = sdr1( trace, params, t)
    %from assumption ems to assumption power low
    result = {};
    for belief = l2.getall(trace, t, 'assumption', {NaN, NaN, predicate('ems', {NaN, NaN})})
        assume = belief.arg{1}      
        result = { result{:} {t+1, 'assumption', {assume, predicate('power', {agent, 'low'})}} };
    end
end