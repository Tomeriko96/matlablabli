function result = lightsensor(controller)
    pin = 'A0';
    result = predicate('acceleration', readSpeed(controller, pin));
end

