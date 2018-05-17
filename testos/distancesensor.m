function result = emg(controller)
    pin = 'A0';
    result = predicate('emg', readVoltage(controller, pin));
end