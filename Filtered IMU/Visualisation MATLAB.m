%% sensor_visualization.m
% This script connects to a sensor server via TCP/IP and visualizes csv
% The top subplots display accelerometer channels in m/s^2 (fixed range: [-5,5]),
% and the bottom subplots display gyroscope channels in °/s (fixed range: [-25,25]).


%% Setup TCP/IP connection
ipAddress = '192.168.219.166';  %ip
port = 5000;                    % port
t = tcpip(ipAddress, port, 'NetworkRole', 'client');
t.Terminator = 'LF';  % Data strings are terminated by a linefeed
t.Timeout = 10;       % Timeout 
fopen(t);
disp('TCP/IP connection established.');

%% Setup history buffers and parameters
historyLength = 200;
historyAngleX = zeros(1, historyLength);
historyAngleY = zeros(1, historyLength);
historyIndex = 1; % Circular buffer index

%% Create figure and subplots
figure('Name','Sensor Visualization','NumberTitle','off',...
       'Position',[100 100 1300 600]);

ax1 = subplot(2,1,1);
hLine1 = plot(1:historyLength, historyAngleX, 'b','LineWidth',1.5);
title(ax1, 'Filtered Angle X (degrees)');
ylim(ax1, [-180 180]);
xlabel(ax1, 'Time');
ylabel(ax1, 'Degrees');
grid(ax1, 'on');

ax2 = subplot(2,1,2);
hLine2 = plot(1:historyLength, historyAngleY, 'r','LineWidth',1.5);
title(ax2, 'Filtered Angle Y (degrees)');
ylim(ax2, [-180 180]);
xlabel(ax2, 'Time');
ylabel(ax2, 'Degrees');
grid(ax2, 'on');

drawnow;


%% Main loop to read data and to update plots
disp('Starting sensor visualization. Press Ctrl+C to stop.');
while true
    if t.BytesAvailable > 0
 
        dataStr = fscanf(t); %data read line by line 
        dataStr = strtrim(dataStr);
      
        vals = str2double(strsplit(dataStr, ','));
        if numel(vals)==2 && all(~isnan(vals))
          
            axVal = vals(1);
            ayVal = vals(2);
            if axVal > 180
                axVal = axVal - 360;
            elseif axVal < -180
                axVal = axVal + 360;
            end
            if ayVal > 180
                ayVal = ayVal - 360;
            elseif ayVal < -180
                ayVal = ayVal + 360;
            end
            
            title(ax1, sprintf('Filtered Angle X = %.4f°', axVal));
            title(ax2, sprintf('Filtered Angle Y = %.4f°', ayVal));
            
            historyAngleX(historyIndex) = axVal;
            historyAngleY(historyIndex) = ayVal;
            
            historyIndex = historyIndex + 1;
            if historyIndex > historyLength
                historyIndex = 1;
            end
            
            set(hLine1, 'YData', historyAngleX);
            set(hLine2, 'YData', historyAngleY);
            
            drawnow limitrate;
        end
    end
    pause(0.01);  % Short pause to avoid overloading the CPU
end

fclose(t);
delete(t);
clear t;
