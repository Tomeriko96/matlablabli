function [ fncs ] = rules()
    % DO NOT EDIT
    fncs = l2.getRules();
    for i=1:length(fncs)
       fncs{i} = str2func(fncs{i});
    end
end
%ADD RULES BELOW

%% Domain model
function result = ddr1( trace, params, t )
    result = {};
    if l2.exists(trace, t, 'task_load{arnie, high}')
        if l2.exists(trace, t, 'deadline{arnie, soon}')
            result = {t+1, 'work_pressure{arnie, high}'};
        end
    end
end

function result = ddr2( trace, params, t )
    result = {};
    if l2.exists(trace, t, 'work_pressure{arnie, high}')
        result = {t+1, 'stress_level{arnie, high}'};
    end
end

function result = ddr3( trace, params, t )
    result = {};
    if l2.exists(trace, t, 'stress_level{arnie, high}')
        result = {{t+1, 'performance{arnie, low}'} ...
                    {t+1, 'blood_pressure{arnie, high}'} };
    end
end

%% Analysis model (backward, based on blood pressure only)
function result = adr0( trace, params, t)
    %from observation to belief
    result = {};
    for elem = trace(t).observation
        ambient_agent = elem.arg{1};
        observation = elem.arg{2};
        result = { result{:} {t+1, 'belief', {ambient_agent, observation}} };
    end
end

function result = adr1( trace, params, t )
    %from blood pressure to stress level
    result = {};
    for belief = l2.getall(trace, t, 'belief', {NaN, predicate('blood_pressure', {NaN, NaN})})
        ambient_agent = belief.arg{1};
        blood_pressure = belief.arg{2};
        agent = blood_pressure.arg{1};
        level = blood_pressure.arg{2};
        result = { result{:} {t+1, 'belief', {ambient_agent, predicate('stress_level', {agent, level})}} };
    end
end

function result = adr2( trace, params, t )
    %from desire and stress level to assessment
    result = {};
    for elem = trace(t).desire
        ambient_agent = elem.arg{1};
        desire = elem.arg{2};
        desired = elem.arg{3};
        % a high stress level is not desired 
        if ~desired && l2.exists(trace, t, 'belief', {ambient_agent, desire})
            result = { result{:} {t+1, 'assessment', {ambient_agent, desire, 'undesirable'}} };
        end
    end
end

%% Support model (forward reasoning, added 'ask_help' affects 'task_load')
function result = sdr0( trace, params, t)
    %from assume to belief under that assumption
    result = {};
    for assume = trace(t).assume
        agent = assume.arg{1};
        assumption = assume.arg{2};
        result = { result{:} {t+1, 'assumption', {agent, assumption, assumption}} };
    end
end

function result = sdr1( trace, params, t)
    %from assumption ask_help to assumption task_load low
    result = {};
    for belief = l2.getall(trace, t, 'assumption', {NaN, NaN, predicate('ask_help', {NaN, NaN})})
        ambient_agent = belief.arg{1};
        assume = belief.arg{2};
        ask_help = belief.arg{3};         
        agent = ask_help.arg{1};
        result = { result{:} {t+1, 'assumption', {ambient_agent, assume, predicate('task_load', {agent, 'low'})}} };
    end
end

function result = sdr2( trace, params, t)
    %from belief task_load to belief work_pressure
    result = {};
    for belief = l2.getall(trace, t, 'assumption', {NaN, NaN, predicate('task_load', {NaN, NaN})})
        ambient_agent = belief.arg{1};
        assume = belief.arg{2};
        task_load = belief.arg{3};         
        agent = task_load.arg{1};
        level = task_load.arg{2}; 
        result = { result{:} {t+1, 'assumption', {ambient_agent, assume, predicate('work_pressure', {agent, level})}} };
    end
end

function result = sdr3( trace, params, t)
    %from belief work_pressure to belief stress_level
    result = {};
    for belief = l2.getall(trace, t, 'assumption', {NaN, NaN, predicate('work_pressure', {NaN, NaN})})
        ambient_agent = belief.arg{1};
        assume = belief.arg{2};
        work_pressure = belief.arg{3};         
        agent = work_pressure.arg{1}; 
        level = work_pressure.arg{2};
        result = { result{:} {t+1, 'assumption', {ambient_agent, assume, predicate('stress_level', {agent, level})}} };
    end
end

function result = sdr4( trace, params, t)
    %from assumption, belief & desire to propose action
    result = {};
    for elem = trace(t).desire
        ambient_agent = elem.arg{1};
        desire = elem.arg{2};
        desired = elem.arg{3};
        % a low stress level is desired
        if desired && l2.exists(trace, t, 'assumption', {ambient_agent, NaN, desire})
            [~, assumption] = l2.exists(trace, t, 'assumption', {ambient_agent, NaN, desire});
            result = { result{:} {t+1, 'propose', {ambient_agent, assumption.arg{2}}} };
        end
    end
end

