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
    Blood_saturation = 'normal';
    for heart_rate = l2.getall(trace, t, 'heart_rate', {NaN})
        heart = heart_rate.arg{1};
        if  heart < params.heart_rate
            Blood_saturation = 'low';
        elseif heart > params.heart_rate
            Blood_saturation = 'high';
        else
            Blood_saturation = 'normal';
        end
        result = { result{:} {t+1, 'BOS', {Blood_saturation}} };
    end
end

function result = ddr2( trace, params, t)
    % from blood-oxygen saturation to muscle temperature
    result = {};
    if l2.exists(trace, t, 'BOS{low}')
        result = {t+1, 'mtemp{low}'};
    elseif l2.exists(trace, t, 'BOS{high}')
        result = {t+1, 'mtemp{high}'};
    else
        result = {t+1, 'mtemp{normal}'};
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
            for mtemp = l2.getall(trace, t, 'mtemp', {NaN})
                Temp = mtemp.arg{1};
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

%%ADR1 Observation of Power
function result = adr1( trace, params, t)
result = {};

for power = l2.getall(trace, t, 'power', {NaN})
    pow = power.arg{1};
    
    result = {result{:} {t+1, 'observation', predicate('power', pow)}};
end
end

%%ADR2 Observation of Heart Rate
function result = adr2( trace, params, t)
result = {};

for heart_rate = l2.getall(trace, t, 'heart_rate', {NaN})
    heart = heart_rate.arg{1};
    
    result = {result{:} {t+1, 'observation', predicate('heart_rate', heart)}};
end
end

%%ADR3 Observation of EMG
function result = adr3( trace, params, t)
result = {};

for emg = l2.getall(trace, t, 'emg', {NaN})
    value = emg.arg{1};
    
    result = {result{:} {t+1, 'observation', predicate('emg', value)}};
end
end

%%ADR4 Observation of Acceleration
function result = adr4( trace, params, t)
result = {};

for acceleration = l2.getall(trace, t, 'acceleration', {NaN})
    value = acceleration.arg{1};
    
    result = {result{:} {t+1, 'observation', predicate('acceleration', value)}};
end
end

%%ADR5 Observation of Jump Height
function result = adr5( trace, params, t)
result = {};

for jump_height = l2.getall(trace, t, 'jump_height', {NaN})
    height = jump_height.arg{1};
    
    result = {result{:} {t+1, 'observation', predicate('jump_height', height)}};
end
end

%%ADR6 Belief of Power
function result = adr6( trace, params, t)
result = {};

for observation = l2.getall(trace, t, 'observation', {predicate('power', {NaN})})
    belief = observation.arg{1};
    
    result = {result{:} {t+1, 'belief', belief}};
end
end

%%ADR7 Belief of Muscle Temperature
function result = adr7( trace, params, t)
result = {};

for power_belief = l2.getall(trace, t, 'belief', {predicate('power', {NaN})})
    belief = power_belief.arg{1};
    for mtemp = l2.getall(trace, t, 'mtemp', {NaN})
        temp = mtemp.arg{1};
        
        if belief == 'low'
            temp = 'low';
            
            result = {result{:} {t+1, 'belief', {predicate('mtemp', temp)}}};
        end
    end
end
end

%%ADR8 Belief of EMG
function result = adr8(trace, params, t)
result = {};

for power_belief = l2.getall(trace, t, 'belief', {predicate('power', {NaN})})
    belief = power_belief.arg{1};
    for emg_level = l2.getall(trace, t, 'emg', {NaN})
        emg = emg_level.arg{1};
        
        result = {result{:} {t+1, 'belief', {predicate('emg', emg)}}};
    end
end
end

%%ADR9 Belief of Force
function result = adr9( trace, params, t)
result = {};

for power_belief = l2.getall(trace, t, 'belief', {predicate('power', {NaN})})
    belief = power_belief.arg{1};
    for force = l2.getall(trace, t, 'force', {NaN})
        forc = force.arg{1};
        
        result = {result{:} {t+1, 'belief', {predicate('force', forc)}}};
    end
end
end

%%ADR10 Belief of Work
function result = adr10(trace, params, t)
result = {};
for force_belief = l2.getall(trace, t, 'belief', {predicate('force', {NaN})})
    belief = force_belief.arg{1};  
    for work = l2.getall(trace, t, 'work', {NaN})
        working = work.arg{1};
        result = {result{:} {t+1, 'belief', {predicate('work', working)}}};
    end
end
end

%%ADR11 Belief on Jump Height
function result = adr11(trace, params, t)
result = {};
for work_belief = l2.getall(trace, t, 'belief', {predicate('work', {NaN})})
    belief = work_belief.arg{1};
    for jump_height = l2.getall(trace, t, 'jump_height', {NaN})
        height = jump_height.arg{1};
        
        result = {result{:} {t+1, 'belief', {predicate('jump_height', height)}}};
    end
end
end

%%ADR12 Assessment on Muscle Temperature
function result = adr12(trace, params, t)
result = {};

for muscle_temperature_belief = l2.getall(trace, t, 'belief', {predicate('mtemp', {'low'})})
    belief = muscle_temperature_belief.arg{1}.arg{1};
    for muscle_temperature_desire = l2.getall(trace, t, 'desire', {predicate('mtemp', {'low'})})
        desire = muscle_temperature_desire.arg{1}.arg{1};
        assessment = 0;
        
        if belief ~ desire;
            assessment = {'undesirable'};
        else
            assessment = {'desirable'};
        end
        
        result = {result{:} {t+1, 'assessment', assessment}};
    end
end
end

%%ADR13 Assessment on Jump Height
function result = adr13(trace, params, t)
result = {};

for jump_height_belief = l2.getall(trace, t, 'belief', {predicate('jump_height', {10})})
    belief = jump_height_belief.arg{1}.arg{1};
    for jump_height_desire = l2.getall(trace, t, 'desire', {predicate('jump_height', {20})})
        desire = jump_height_desire.arg{1}.arg{1};
        
        assessment = 0;
        
        if belief <= desire
            assessment = 'undesirable';
        else
            assessment = 'desirable';
        end
        result = {result{:} {t+1, 'assessment', assessment}};
    end
end
end

%%ADR14 Assessment on Muscle Activity
function result = adr14(trace, params, t)
result = {};

for muscle_activity_belief = l2.getall(trace, t, 'belief', {predicate('emg', {NaN})})
    belief = muscle_activity_belief.arg{1}.arg{1};
    for muscle_activity_desire = l2.getall(trace, t, 'desire', {predicate('emg', {NaN})})
        desire = muscle_activity_desire.arg{1}.arg{1};
        assessment = 0;
        
        if belief <= desire
            assessment = 'undesirable';
        else
            assessment = 'desirable';
        end
        
        result = {result{:} {t+1, 'assessment', assessment}};
    end
end
end

%% Support Model
%SDR1 From Power Desire -> Muscle Temperature Desire
function result = sdr1(trace, params, t)
result = {};

for mtemp_assessment = l2.getall(trace, t, 'assessment', {predicate('mtemp', {NaN})})
    mtemp = mtemp_assessment.arg{1}.arg{1};
    for power_desire = l2.getall(trace, t, 'desire', {predicate('power', {NaN})})
        desire = power_desire.arg{1}.arg{1};
        %CHANGE IF STATEMENT TO ''IF ASSESSMENT = UNDESIRABLE''
        if mtemp == 'low'
            result = {result{:} {t+1, 'desire', {predicate('mtemp', 'high')}}};
        else
        end
    end
end
end

%SDR2 From Muscle Temperature Desire -> Warmup Advice Desire
function result = sdr2(trace, params, t)
result = {};

for mtemp_desire = l2.getall(trace, t, 'desire', {predicate('mtemp', {NaN})})
    temp = mtemp_desire.arg{1}.arg{1};
    if (temp - 37.5) > 1.0
        result = {result{:} {t+1, 'desire', {predicate('warmup', true)}}};
    else
        result = {result{:} {t+1, 'desire', {predicate('warmup', false)}}};
    end
end
end

%SDR3 From Warmup Advice Desire -> Warmup Advice Proposal
function result = sdr3(trace, params, t)
result = {};

for warmup_desire = l2.getall(trace, t, 'desire', {predicate('warmup', {NaN})})
    warmup = warmup_desire.arg{1}.arg{1};
    if warmup == true
        result = {result{:} {t+1, 'propose', {predicate('warmup', true)}}};
    else
        result = {result{:} {t+1, 'propose', {predicate('warmup', false)}}};
    end
end
end

%SDR4 From Power Desire -> Force Desire
function result = sdr4(trace, params, t)
result = {};
for power_desire = l2.getall(trace, t, 'desire', {predicate('power', {NaN})})
    desire = power_desire.arg{1}.arg{1};
    velocity = (params.g * t)/2;
    desired_force = desire / velocity;
    result = {result{:} {t+1, 'desire', {predicate('force', desired_force)}}};
end
end

%SDR5 From Force Desire -> Work Desire
function result = sdr5(trace, params, t)
result = {};
for force_desire = l2.getall(trace, t, 'desire', {predicate('force', {NaN})})
    desire = force_desire.arg{1}.arg{1};
    for jump_height = l2.getall(trace, t, 'jump_height', {NaN})
        height = jump_height.arg{1};
        desired_work = desire * height;
        
        result = {result{:} {t+1, 'desire', {predicate('work', desired_work)}}};
    end
end
end

%SDR6 From Work Desire -> Distance Desire
function result = sdr6(trace, params, t)
result = {};
for work_desire = l2.getall(trace, t, 'desire', {predicate('work', {NaN})})
    work = work_desire.arg{1}.arg{1};
    for force_desire = l2.getall(trace, t, ' desire', {predicate('force', {NaN})})
        force = force_desire.arg{1}.arg{1};
        desired_distance = work / force;
        result = {result{:} {t+1, 'desire', {predicate('jump_height', desired_distance)}}};
    end
end
end

%SDR7 From Power Desire -> Emg Desire

%SDR8

%SDR9

%SDR10
