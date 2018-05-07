disp('Running the model...')

% clear all
% close all
% model = l2('JAAP')
% model.simulate(20, 'COM3')
% model.simulate(2)
% model.plot()
% 
% clear all
% close all
% 
% model = l2('Group3');
% model.simulate(10);
% model.plot();

disp('Running the domain/analysis/support model...')

clear all
close all
model = l2('Group3')
model.simulate(10);
model.plot();
set(gcf,'name','Domain model','numbertitle','off')
model.simulate(10, 'analysis');
model.plot();
set(gcf,'name','Analysis model','numbertitle','off')
model.simulate(10, 'support');
model.plot();
set(gcf,'name','Support model','numbertitle','off')