function result = lightsensor(controller)
    pin = 'A0';
    result = predicate('lightsensor', readVoltage(controller, pin));
end