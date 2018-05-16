disp('Running the demo model...')

clear all
close all
model = l2('testos')
model.simulate(20)
model.plot()