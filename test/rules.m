function [ fncs ] = rules()
    % DO NOT EDIT
    fncs = l2.getRules();
    for i=1:length(fncs)
       fncs{i} = str2func(fncs{i});
    end
end
%ADD RULES BELOW

%% Domain model
%function result = ddr0( trace, params, t)
%   result = {};
%   a=arduino();
%   value = readVoltage(a, 'A0') * 10;
%   result = { result{:} {t+1, 'emg', {value}} };
%end

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

            if belief ~= desire
                assessment = predicate('undesirable', {predicate('mtemp', belief)});
            else
                assessment = predicate('desirable', {predicate('mtemp', belief)});
            end

            result = {result{:} {t+1, 'assessment', assessment}};
        end
    end
    end

    %%ADR13 Assessment on Jump Height
    function result = adr13(trace, params, t)
    result = {};

    for jump_height_belief = l2.getall(trace, t, 'belief', {predicate('jump_height', {NaN})})
        belief = jump_height_belief.arg{1}.arg{1};
        for jump_height_desire = l2.getall(trace, t, 'desire', {predicate('jump_height', {NaN})})
            desire = jump_height_desire.arg{1}.arg{1};

            assessment = 0;

            if belief ~= desire
                assessment = predicate('undesirable', {predicate('jump_height', belief)});
            else
                assessment = predicate('desirable', {predicate('jump_height', belief)});
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

            if belief ~= desire
                assessment = predicate('undesirable', {predicate('emg', belief)});
            else
                assessment = predicate('desirable', {predicate('emg', belief)});
            end

            result = {result{:} {t+1, 'assessment', assessment}};
        end
    end
end

%% Support Model
%SDR1 From Power Desire -> Muscle Temperature Desire
function result = sdr1(trace, params, t)
    result = {};

    for mtemp_assessment = l2.getall(trace, t, 'assessment', {predicate('undesirable', {predicate('mtemp', {NaN})})})
        mtemp = mtemp_assessment.arg{1}.arg{1}.arg{1};
        for power_desire = l2.getall(trace, t, 'desire', {predicate('power', {NaN})})
            desire = power_desire.arg{1}.arg{1};
            if mtemp == 'low'
                result = {result{:} {t+1, 'desire', {predicate('mtemp', 'high')}}};
            else
                result = {result{:} {t+1, 'desire', {predicate('mtemp', 'low')}}};
            end
        end
    end
end

%SDR2 From Muscle Temperature Desire -> Warmup Advice Desire
function result = sdr2(trace, params, t)
    result = {};

    for mtemp_desire = l2.getall(trace, t, 'desire', {predicate('mtemp', {NaN})})
        temp = mtemp_desire.arg{1}.arg{1};
        if  temp == 'normal'
            result = {result{:} {t+1, 'desire', {predicate('warmup', false)}}};
        else
            result = {result{:} {t+1, 'desire', {predicate('warmup', true)}}};
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
%            a=arduino();
%            playTone(a,'D3',10,30);
        else
            result = {result{:} {t+1, 'propose', {predicate('warmup', false)}}};
        end
    end
end

%SDR4 From Power Desire -> Force Desire
function result = sdr4(trace, params, t)
    result = {};
    for power_desire = l2.getall(trace, t, 'desire', {predicate('power', {NaN})})
        desire = power_desire.arg{1}.arg{1}(1);
        velocity = (params.g * t)/2;
        desired_force = desire(1) / velocity;
        result = {result{:} {t+1, 'desire', {predicate('force', desired_force)}}};
    end
end

%SDR5 From Force Desire -> Work Desire
function result = sdr5(trace, params, t)
    result = {};
    for force_desire = l2.getall(trace, t, 'desire', {predicate('force', {NaN})})
        desire = force_desire.arg{1}.arg{1}(1);
        for jump_height = l2.getall(trace, t, 'jump_height', {NaN})
            height = jump_height.arg{1};
            desired_work = desire(1) * height;

            result = {result{:} {t+1, 'desire', {predicate('work', desired_work)}}};
        end
    end
end

%SDR6 From Work Desire -> Distance Desire
function result = sdr6(trace, params, t)
result = {};
    for work_desire = l2.getall(trace, t, 'desire', {predicate('work', {NaN})})
        work = work_desire.arg{1}.arg{1}(1);
        for force_desire = l2.getall(trace, t, 'desire', {predicate('force', {NaN})})
            force = force_desire.arg{1}.arg{1};
            desired_distance = work / force(1);
            result = {result{:} {t+1, 'desire', {predicate('jump_height', desired_distance)}}};
        end
    end
end

%SDR7 From Power Desire -> Emg Desire
function result = sdr7(trace,params,t)
    result = {};
    for power_desire = l2.getall(trace,t,'desire', {predicate('power', {NaN})})
        power = power_desire.arg{1}.arg{1};
        if power == 'high'
            desire = params.emg;
        else
            power = 'low';
        end
        result = {result{:} {t+1, 'desire', {predicate('emg', desire')}}};
    end
end
    
%SDR8 From Emg Desire -> EMS Desire
function result = sdr8(trace,params,t)
    result = {};
    for emg = l2.getall(trace, t, 'emg', {NaN})
        value = emg.arg{1};
        ems = false;
        if value <= params.emg
            ems = true;
        else
            ems = false;
        end
        result = {result{:} {t+1, 'desire', {predicate('ems', ems)}}};
    end
end

%SDR9 From EMS Desire -> EMS Proposal
function result = sdr9(trace,params,t)
    result = {};

    for ems_desire = l2.getall(trace, t, 'desire', {predicate('ems', {NaN})})
        ems = ems_desire.arg{1}.arg{1};
        if ems == true
            result = {result{:} {t+1, 'propose', {predicate('ems', true)}}};
%            a=arduino();
%            s = servo(a, 'D4', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
%            for angle = 0:0.2:1
%               writePosition(s, angle);
%            end
        else
            result = {result{:} {t+1, 'propose', {predicate('ems', false)}}};
        end
    end
end
    
%SDR10 From EMG Desire & Jump Height Desire -> Audio Encouragement Desire
function result = sdr10(trace,params,t)
result = {};
for emg_desire = l2.getall(trace,t,'desire', {predicate('emg', {NaN})})
    emg = emg_desire.arg{1}.arg{1};
    for jump_height_desire = l2.getall(trace,t,'desire', {predicate('jump_height', {NaN})})
        height = jump_height_desire.arg{1}.arg{1};
        if emg <= params.emg && height <= 80
            result = {result{:} {t+1, 'desire', {predicate('aud', true)}}};
        else
            result = {result{:} {t+1, 'desire', {predicate('aud', false)}}};
        end
    end
end
end

%SDR11 From Audio Encouragement Desire -> Audio Encouragement Proposal
function result = sdr11(trace,params,t)
result = {};
for aud_desire = l2.getall(trace,t,'desire', {predicate('aud', {NaN})})
    aud = aud_desire.arg{1}.arg{1};
    if aud == true
        result = {result{:} {t+1, 'propose', {predicate('aud', true)}}};
%        a=arduino();
%        playTone(a,'D5',2400,10);
    else
        result = {result{:} {t+1, 'propose', {predicate('aud', false)}}};
    end
end
end
%% Parameter Adaptation Model

%PADR1 Deviation Belief Heart Rate
function result = padr1(trace, params, t)
result = {};
for observed_heart_rate = l2.getall(trace,t,'observation', {predicate('heart_rate', {NaN})})
    observed = observed_heart_rate.arg{1}.arg{1};
    for belief_heart_rate = l2.getall(trace,t,'observation', {predicate('heart_rate', {NaN})})
        belief = belief_heart_rate.arg{1}.arg{1};
        deviation = abs(observed - belief);
        result = {result{:} {t+1, 'belief', {predicate('deviation', {predicate('heart_rate', deviation)})}}};
    end
end   
end

%PADR2 Deviation Belief EMG
function result = padr2(trace, params, t)
result = {};
for observed_emg = l2.getall(trace,t,'observation', {predicate('emg', {NaN})})
    observed = observed_emg.arg{1}.arg{1};
    for belief_emg = l2.getall(trace,t,'observation', {predicate('emg', {NaN})})
        belief = belief_emg.arg{1}.arg{1};
        deviation = abs(observed - belief);
        result = {result{:} {t+1, 'belief', {predicate('deviation', {predicate('emg', deviation)})}}};
    end
end   
end

%PADR3 Deviation Belief Acceleration
function result = padr3(trace, params, t)
result = {};
for observed_acceleration = l2.getall(trace,t,'observation', {predicate('acceleration', {NaN})})
    observed = observed_acceleration.arg{1}.arg{1};
    for belief_acceleration = l2.getall(trace,t,'observation', {predicate('acceleration', {NaN})})
        belief = belief_acceleration.arg{1}.arg{1};
        deviation = abs(observed - belief);
        result = {result{:} {t+1, 'belief', {predicate('deviation', {predicate('acceleration', deviation)})}}};
    end
end   
end

%PADR4 Deviation Belief Jump Height
function result = padr4(trace, params, t)
result = {};
for observed_jump_height = l2.getall(trace,t,'observation', {predicate('jump_height', {NaN})})
    observed = observed_jump_height.arg{1}.arg{1};
    for belief_jump_height = l2.getall(trace,t,'observation', {predicate('jump_height', {NaN})})
        belief = belief_jump_height.arg{1}.arg{1};
        deviation = abs(observed - belief);
        result = {result{:} {t+1, 'belief', {predicate('deviation', {predicate('jump_height', deviation)})}}};
    end
end   
end

%PADR5 Prediction1 Heart Rate
function result = padr5(trace,params,t)
result = {};

    weight1 = 0.6;
    weight2 = 0.7;
    change_x = abs(abs(params.v1_heart_rate * weight1) - abs(params.v2_heart_rate * weight2));
    change_p = abs(params.v1_heart_rate - params.v2_heart_rate);
    sensitivity = change_x / change_p;
    result = {result{:} {t+1, 'belief', {predicate('sensitivity', {predicate('heart_rate', sensitivity)})}}};
end

%PADR6 Prediction1 EMG
function result = padr6(trace,params,t)
result = {};

    weight1 = 0.8;
    weight2 = 0.9;
    change_x = abs(abs(params.v1_emg * weight1) - abs(params.v2_emg * weight2));
    change_p = abs(params.v1_emg - params.v2_emg);
    sensitivity = change_x / change_p;
    result = {result{:} {t+1, 'belief', {predicate('sensitivity', {predicate('emg', sensitivity)})}}};
end

%PADR7 Prediction1 Acceleration
function result = padr7(trace,params,t)
result = {};

    weight1 = 0.6;
    weight2 = 0.7;
    change_x = abs(abs(params.v1_acceleration * weight1) - (params.v2_acceleration * weight2));
    change_p = abs(params.v1_acceleration - params.v2_acceleration);
    sensitivity = change_x / change_p;
    result = {result{:} {t+1, 'belief', {predicate('sensitivity', {predicate('acceleration', sensitivity)})}}};
end

%PADR8 Prediction1 Jump Height
function result = padr8(trace,params,t)
result = {};

    weight1 = 0.6;
    weight2 = 0.7;
    change_x = abs(abs(params.v1_jump_height * weight1) - abs(params.v2_jump_height * weight2));
    change_p = abs(params.v1_jump_height - params.v2_jump_height);
    sensitivity = change_x / change_p;
    result = {result{:} {t+1, 'belief', {predicate('sensitivity', {predicate('jump_height', sensitivity)})}}};
end

%PADR9 Belief Adapatation Option Heart Rate
function result = padr9(trace,params,t)
result = {};
for deviation_HR = l2.getall(trace,t, 'belief', {predicate('deviation', {predicate('heart_rate', {NaN})})});
    deviation = deviation_HR.arg{1}.arg{1}.arg{1};
    for adaptation_belief = l2.getall(trace,t, 'belief', {predicate('adaptation_speed', {NaN})});
        adaptation_speed = adaptation_belief.arg{1}.arg{1};
        for sensitivity_HR = l2.getall(trace, t, 'belief', {predicate('sensitivity', {predicate('heart_rate', {NaN})})});
            sensitivity = sensitivity_HR.arg{1}.arg{1}.arg{1};
            weight1 = 0.6;
            weight2 = 0.7;
            change_x = abs(abs(params.v1_heart_rate * weight1) - abs(params.v2_heart_rate * weight2));
            change_p = adaptation_speed * change_x * (1 - weight1) / sensitivity;
            result = {result{:} {t+1, 'belief', {predicate('adaptation_option', {predicate('heart_rate', params.v2_heart_rate + change_p)})}}};
        end
    end
end
end

%PADR10 Belief Adapatation Option EMG
function result = padr10(trace,params,t)
result = {};
for deviation_EMG = l2.getall(trace,t, 'belief', {predicate('deviation', {predicate('emg', {NaN})})});
    deviation = deviation_EMG.arg{1}.arg{1}.arg{1};
    for adaptation_belief = l2.getall(trace,t, 'belief', {predicate('adaptation_speed', {NaN})});
        adaptation_speed = adaptation_belief.arg{1}.arg{1};
        for sensitivity_EMG = l2.getall(trace, t, 'belief', {predicate('sensitivity', {predicate('emg', {NaN})})});
            sensitivity = sensitivity_EMG.arg{1}.arg{1}.arg{1};
            weight1 = 0.8;
            weight2 = 0.9;
            change_x = abs(abs(params.v1_emg * weight1) - abs(params.v2_emg * weight2));
            change_p = adaptation_speed * change_x * (1 - weight1) / sensitivity;
            result = {result{:} {t+1, 'belief', {predicate('adaptation_option', {predicate('emg', params.v2_emg + change_p)})}}};
        end
    end
end
end

%PADR11 Belief Adapatation Option Acceleration
function result = padr11(trace,params,t)
result = {};
for deviation_acceleration = l2.getall(trace,t, 'belief', {predicate('deviation', {predicate('acceleration', {NaN})})});
    deviation = deviation_acceleration.arg{1}.arg{1}.arg{1};
    for adaptation_belief = l2.getall(trace,t, 'belief', {predicate('adaptation_speed', {NaN})});
        adaptation_speed = adaptation_belief.arg{1}.arg{1};
        for sensitivity_acceleration = l2.getall(trace, t, 'belief', {predicate('sensitivity', {predicate('acceleration', {NaN})})});
            sensitivity = sensitivity_acceleration.arg{1}.arg{1}.arg{1};
            weight1 = 0.6;
            weight2 = 0.7;
            change_x = abs(abs(params.v1_acceleration * weight1) - abs(params.v2_acceleration * weight2));
            change_p = adaptation_speed * change_x * (1 - weight1) / sensitivity;
            result = {result{:} {t+1, 'belief', {predicate('adaptation_option', {predicate('acceleration', params.v2_acceleration + change_p)})}}};
        end
    end
end
end


%PADR12 Belief Adapatation Option Jump Height
function result = padr12(trace,params,t)
result = {};
for deviation_jump_height = l2.getall(trace,t, 'belief', {predicate('deviation', {predicate('jump_height', {NaN})})});
    deviation = deviation_jump_height.arg{1}.arg{1}.arg{1};
    for adaptation_belief = l2.getall(trace,t, 'belief', {predicate('adaptation_speed', {NaN})});
        adaptation_speed = adaptation_belief.arg{1}.arg{1};
        for sensitivity_jump_height = l2.getall(trace, t, 'belief', {predicate('sensitivity', {predicate('jump_height', {NaN})})});
            sensitivity = sensitivity_jump_height.arg{1}.arg{1}.arg{1};
            weight1 = 0.6;
            weight2 = 0.7;
            change_x = abs(abs(params.v1_jump_height * weight1) - abs(params.v2_jump_height * weight2));
            change_p = adaptation_speed * change_x * (1 - weight1) / sensitivity;
            result = {result{:} {t+1, 'belief', {predicate('adaptation_option', {predicate('jump_height', params.v2_jump_height + change_p)})}}};
        end
    end
end
end


%% plot functions






