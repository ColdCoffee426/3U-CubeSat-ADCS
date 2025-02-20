%% sensor_visualization.m


clear; close all; clc;

%% Setup TCP/IP connection (filtered data on port 5000)
ipAddress = '192.168.219.166';  
port = 5000;            %port number
t = tcpip(ipAddress, port, 'NetworkRole', 'client');
t.Terminator = 'LF';  % Data strings are terminated by a linefeed
t.Timeout = 10;       % Timeout s
fopen(t);
disp('TCP/IP connection established.');

%% Setup history buffers and parameters
historyLength = 200;
historyAngleX = zeros(1, historyLength);
historyAngleY = zeros(1, historyLength);
historyIndex = 1; % Circular buffer index


%% figures and subplots
figure('Name','Filtered IMU Visualization','NumberTitle','off',...
       'Position',[100 100 1300 600]);

ax1 = subplot(2,1,1);
hLine1 = plot(1:historyLength, historyAngleX, 'b','LineWidth',1.5);
title(ax1, 'Filtered Angle X (degrees)');
ylim(ax1, [-90 90]);
xlabel(ax1, 'Time');
ylabel(ax1, 'Degrees');
grid(ax1, 'on');

ax2 = subplot(2,1,2);
hLine2 = plot(1:historyLength, historyAngleY, 'r','LineWidth',1.5);
title(ax2, 'Filtered Angle Y (degrees)');
ylim(ax2, [-90 90]);
xlabel(ax2, 'Time');
ylabel(ax2, 'Degrees');
grid(ax2, 'on');

drawnow;

%% Main loop for reading data and to update plots 
disp('Starting filtered sensor visualization. Close the figure to stop.');
while ishandle(gcf)
    if t.BytesAvailable > 0
        dataStr = fscanf(t);  % Read one line of data
        dataStr = strtrim(dataStr);
        % Expected format: "filtered_angle_x,filtered_angle_y"
        vals = str2double(strsplit(dataStr, ','));
        if numel(vals)==2 && all(~isnan(vals))
            angleX = vals(1);
            angleY = vals(2);
            
            % current values in plots
            title(ax1, sprintf('Filtered Angle X = %.4f°', angleX));
            title(ax2, sprintf('Filtered Angle Y = %.4f°', angleY));
            
            % Updating buffers
            historyAngleX(historyIndex) = angleX;
            historyAngleY(historyIndex) = angleY;
            
            historyIndex = historyIndex + 1;
            if historyIndex > historyLength
                historyIndex = 1;
            end
            
            % Updating with new history data
            set(hLine1, 'YData', historyAngleX);
            set(hLine2, 'YData', historyAngleY);
            
            drawnow limitrate;
        end
    end
    pause(0.01);  % Short pause to avoid high CPU usage
end

fclose(t);
delete(t);
clear t;
