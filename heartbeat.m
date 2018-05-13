% Initialize the variable "a" and associate it with the Arduino.
% clear a
% a=arduino();

% choice = 1 tells the program to collect data; (automatically calculates heart rate) 
% choice = 2 closes all figures
choice = 1; 

points = 150;   % specify the number of times to measure the output voltage
                % Since data is acquired approximately every 0.03 sec, 350
                % data points should be about 10 seconds of pulse data
                %for some reason 350 points of data is too much
                %150 plots a little over 10 seconds of pulse data

% choose the upper and lower bounds of the y axis, the lowest and highest
% Vout values you expect to see. **CHANGE THESE VALUES HERE IF DESIRED.**
lowestvoltage = 1.8;    
highestvoltage = 4.5;

% set up a row vector "data" to collect the voltage due to the reflected light 
% receieved by the photodiode. Set up row vector "time" to store the time 
% index of each data point
format shortg;
timestart = clock;                  %format to user timers (attempt to change time axis)

begxaxis = 0;
endxaxis = 10;

while (choice == 1), % while user wants to collect new waveforms, poll pulse sensor and plot output
    
    data = zeros(1, points);     % initialize vector to hold sensor voltagae data
    time = zeros(1, points);    % initialize vector to hold time index of each voltage
    
    figure;              % create a new figure window for plotting the Vout values
    axis([begxaxis endxaxis lowestvoltage highestvoltage]);  % set the lower and upper limits of the x and y values
    xlabel('time, seconds');
    ylabel('Output voltage, volts');
    hold on             % freeze the graph so that you can plot each new Vout value on the same graph
    grid on
    grid minor
    
    tstart = tic;       % start a timer
    data(1) = readVoltage(a,0); %read the voltage on pin A0 and store as the first data point
    time(1)= toc(tstart);       %store the time index of that data point in "time"
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The following lines of code read the A0 voltage and note the time
    % index. These values are stored in "data" and "time", respectively
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    minVoltage = data(1);
    maxVoltage = data(1);
    
    beattime = zeros(1,15);
    beatcount = 1;
    intervals = zeros(1,14);
    
    %{
    timenow = clock;
    if (etime(timenow,timestart) >= 2)
        fprintf('This worked');
        begxaxis = begxaxis + 1;
        endxaxis = endxaxis + 1;
        %will this work: 
        figure;
        
        axis([begxaxis endxaxis lowestvoltage highestvoltage]);  
        timestart = timenow;
    end
    %}
  
        
    
    for i=2:points,
        data(i) = readVoltage(a,0); % read voltage on pin A0, store as next data point
        
        if (data(i) > maxVoltage)
            maxVoltage = data(i);
        elseif (data(i) < minVoltage)
            minVoltage = data(i);
        end
            
        time(i) = toc(tstart);      % store corresponding time index
        
        %formatting for scrollable plot
        dx = 2;
        a = gca;
        
        
        
        plot(time(i-1:i), data(i-1:i));  %draw the line from the last Vout value to the current Vout value
        
        %actual scroller
        %Set appropriate axis limits and settings
        set(gcf, 'doublebuffer', 'on');
        %Avoiding flickering when updating
        set(a,'xlim',[0 dx]);
        set(a,'ylim',[min(y) - 1, max(y) + 1] %REMEMBER TO CHANGE X AND Y
        
        %Generate constants for use in UI Control intialization
        pos = get(a, 'position');
        Newpos = [pos(1) pos(2)-0.1 pos(3) 0.05];
        %Slider and leader room for axis labels
        xmax = max(x);
        S = ['set(gca,''xlim'',get(cbo,''value'')+[0 ' num2str(dx) '])'];
        
        %UI Control
        h = uicontrol('style','slider',...
            'units', 'normalized', 'position', Newpos,...
            'callback',S,'min',0,'max',xmax-dx);
        
        drawnow;
        
        thresh = maxVoltage * 0.95;
        if (data(i) > thresh) && (time(i) > beattime(beatcount)+0.4)
            beatcount = beatcount + 1;
            beattime(beatcount) = time(i);
        end
         
        for i=1:beatcount-1,
            intervals(i)= beattime(i+1)-beattime(i);
        end
        
        avgbeat=median(intervals);
        bpm=60/avgbeat; % Calculate average heart rate in beats per minute
        title(['Heart Rate = ', num2str(bpm, 4), ' beats per minute (using threshold = ', num2str(thresh,3),' volts)']);
        
    end

    choice = menu('Would you like to keep collecting data?', 'Collect a new set of pulse waveforms','Close');
end

%{
while (choice == 2)                    (Changing axis would be too slow
                                                Replot too much data
    
    finish=false;
    set(gcf,'CurrentCharacter','@'); % set to a dummy character
    while ~finish
    % do things in loop...
    
    % check for keys
    k=get(gcf,'CurrentCharacter');
     if k~='@' % has it changed from the dummy character?
       set(gcf,'CurrentCharacter','@'); % reset the character
       % now process the key as required
      if k=='q', finish=true; end
     end
end
    
  
if choice == 2,
    close all;
end
%}