function result = distancesensor(controller)
    pin = 'D10';
    result = predicate('distancesensor', readVoltage(controller, pin));
end