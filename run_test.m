clear all
close all
disp('Running the domain/analysis/support model...')

model = l2('test');
model.simulate(10);
model.plot();
