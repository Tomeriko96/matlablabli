disp('Running the demo model...')

clear all
close all
model = l2('testos');
model.simulate(10);
model.plot();