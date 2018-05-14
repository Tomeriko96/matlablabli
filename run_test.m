clear all
close all
%test%
disp('Running the domain/analysis/support model...')

model = l2('test');
model.simulate(10, 'domain');
model.plot();
set(gcf,'name','Domain model','numbertitle','off')
model.simulate(10, 'analysis');
model.plot();
set(gcf,'name','Analysis model','numbertitle','off')
model.simulate(10, 'support');
model.plot();
set(gcf,'name','Support Model','numbertitle','off')
% model.simulate(10, 'support');
% model.plot();
% set(gcf,'name','Parameter Adaptation Model','numbertitle','off')