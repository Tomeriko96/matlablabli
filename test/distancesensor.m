function result = jump_height(controller)
    pin = 'A5';
    result = predicate('jump_height', readVoltage(controller, pin));
end