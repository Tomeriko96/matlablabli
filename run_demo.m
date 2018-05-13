disp('Running the demo model...')

clear all
close all
model = l2('demo')
model.simulate(20, 'COM3')
model.plot()