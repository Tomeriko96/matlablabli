disp('Running the model...')

% clear all
% close all
% model = l2('JAAP')
% model.simulate(20, 'COM3')
% model.simulate(2)
% model.plot()

clear all
close all

model = l2('JAAP');
model.simulate(10);
model.plot();