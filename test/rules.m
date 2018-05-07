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
    % from heart rate to blood-oxygen saturation
    result = {};
    BOS = 'normal';
    for heart_rate = l2.getall(trace, t, 'heart_rate', {NaN})
        heart = heart_rate.arg{1};
        if  heart < params.heart_rate
            BOS = 'low';
        elseif heart > params.heart_rate
            BOS = 'high';
        else
            BOS = 'normal';
        end
        result = { result{:} {t+1, 'BOS', {BOS}} };
    end
end

function result = ddr2( trace, params, t)
    % from blood-oxygen saturation to muscle temperature
    result = {};
    if l2.exists(trace, t, 'BOS{low}')
        result = {t+1, 'Mtemp{low}'};
    elseif l2.exists(trace, t, 'BOS{high}')
        result = {t+1, 'Mtemp{high}'};
    else
        result = {t+1, 'Mtemp{normal}'};
    end
end

function result = ddr3( trace, params, t)
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

function result = ddr4( trace, params, t)
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

function result = ddr5( trace, params, t)
    % from work to rest interval
    result = {};
    for work = l2.getall(trace, t, 'work', {NaN})
        if work > 10000
            result = {t+1, 'rest{long}'};
        elseif work < 10000
            result = {t+1, 'rest{short}'};
        end
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
            for Mtemp = l2.getall(trace, t, 'Mtemp', {NaN})
                Temp = Mtemp.arg{1};
                for emgmeasure = l2.getall(trace, t, 'emg', {NaN})
                    emg = emgmeasure.arg{1};
                    sum = (F * v * Temp * emg)/10000;
                    if sum < 20000
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
    for belief = l2.getall(trace, t, 'belief',{NaN, predicate('power', {NaN, NaN})})
        belieff = belief
    end
end
