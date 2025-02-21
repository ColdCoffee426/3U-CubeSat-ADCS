%better viuslization % sensor_visualization.m
% - Ultra zoomed-in view (1 second window)
% - Very high sampling rate (200 Hz) for real-time tracking

%% Setup TCP/IP connection
ipAddress = '192.168.219.166';  
port = 5000;
t = tcpip(ipAddress, port, 'NetworkRole', 'client');
t.Terminator = 'LF';
t.Timeout = 10;
fopen(t);
disp('TCP/IP connection established.');

%% Define parameters
samplingRate = 200;  % High sampling rate (Hz)
timeWindow = 1;      % Ultra zoomed-in window (1 second)
historyLength = samplingRate * timeWindow;  

% Circular buffer initialization
historyAx = zeros(1, historyLength);
historyAy = zeros(1, historyLength);
historyAz = zeros(1, historyLength);
historyGx = zeros(1, historyLength);
historyGy = zeros(1, historyLength);
historyGz = zeros(1, historyLength);
historyIndex = 1;

% Moving mean filter window size
windowSize = 5;  % Small averaging for quick response

%% Create zoomed-in figures
figure('Name', 'Sensor Visualization (Ultra Zoomed-In)', 'NumberTitle', 'off', 'Position', [100 100 1300 800]);

ax1 = subplot(2,3,1); hLine1 = plot(1:historyLength, historyAx, 'b','LineWidth',1.5);
title(ax1, 'ax (m/s^2)'); ylim([-1 1]); grid on;

ax2 = subplot(2,3,2); hLine2 = plot(1:historyLength, historyAy, 'b','LineWidth',1.5);
title(ax2, 'ay (m/s^2)'); ylim([-1 1]); grid on;

ax3 = subplot(2,3,3); hLine3 = plot(1:historyLength, historyAz, 'b','LineWidth',1.5);
title(ax3, 'az (m/s^2)'); ylim([-1 1]); grid on;

ax4 = subplot(2,3,4); hLine4 = plot(1:historyLength, historyGx, 'r','LineWidth',1.5);
title(ax4, 'gx (°/s)'); ylim([-5 5]); grid on;

ax5 = subplot(2,3,5); hLine5 = plot(1:historyLength, historyGy, 'r','LineWidth',1.5);
title(ax5, 'gy (°/s)'); ylim([-5 5]); grid on;

ax6 = subplot(2,3,6); hLine6 = plot(1:historyLength, historyGz, 'r','LineWidth',1.5);
title(ax6, 'gz (°/s)'); ylim([-5 5]); grid on;

drawnow;

%% Main loop for real-time visualization
disp('Starting sensor visualization. Press Ctrl+C to stop.');
while true
    if t.BytesAvailable > 0
        dataStr = fscanf(t); 
        dataStr = strtrim(dataStr);
        vals = str2double(strsplit(dataStr, ','));
        
        if numel(vals) == 6 && all(~isnan(vals))
            % Read values
            axVal = vals(1);
            ayVal = vals(2);
            azVal = vals(3);
            gxVal = vals(4);
            gyVal = vals(5);
            gzVal = vals(6);

            % Update titles with real-time values
            title(ax1, sprintf('ax = %.4f m/s^2', axVal));
            title(ax2, sprintf('ay = %.4f m/s^2', ayVal));
            title(ax3, sprintf('az = %.4f m/s^2', azVal));
            title(ax4, sprintf('gx = %.4f °/s', gxVal));
            title(ax5, sprintf('gy = %.4f °/s', gyVal));
            title(ax6, sprintf('gz = %.4f °/s', gzVal));

            % Update history buffer (circular)
            historyAx(historyIndex) = axVal;
            historyAy(historyIndex) = ayVal;
            historyAz(historyIndex) = azVal;
            historyGx(historyIndex) = gxVal;
            historyGy(historyIndex) = gyVal;
            historyGz(historyIndex) = gzVal;

            % Moving mean filter for smoothing
            smoothAx = movmean(historyAx, windowSize);
            smoothAy = movmean(historyAy, windowSize);
            smoothAz = movmean(historyAz, windowSize);
            smoothGx = movmean(historyGx, windowSize);
            smoothGy = movmean(historyGy, windowSize);
            smoothGz = movmean(historyGz, windowSize);

            % Increment index in circular buffer
            historyIndex = mod(historyIndex, historyLength) + 1;

            % Update plots with smoothed data
            set(hLine1, 'YData', smoothAx);
            set(hLine2, 'YData', smoothAy);
            set(hLine3, 'YData', smoothAz);
            set(hLine4, 'YData', smoothGx);
            set(hLine5, 'YData', smoothGy);
            set(hLine6, 'YData', smoothGz);

            drawnow expose;
        end
    end
    pause(0.002); % Super fast refresh rate
end

% Cleanup
fclose(t);
delete(t);
clear t;
