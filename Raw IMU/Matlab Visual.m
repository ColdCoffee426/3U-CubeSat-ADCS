%% sensor_visualization.m
%n This scripts used tcp to read csv and then display graphs 
% Accelerometer values (in g) are converted to m/s^2 (1 g = 9.80665 m/s^2).
% The top subplots display accelerometer channels in m/s^2 (fixed range: [-5,5]),
% and the bottom subplots display gyroscope channels in °/s (fixed range: [-25,25]).


%% Setup TCP/IP connection
ipAddress = '192.168.219.166';  % ip addres of raspberry pi
port = 5001;                    % port number in script
t = tcpip(ipAddress, port, 'NetworkRole', 'client');
t.Terminator = 'LF';  % Data strings are terminated by a linefeed
t.Timeout = 10;       % Timeout (in seconds)
fopen(t);
disp('TCP/IP connection established.');

%% history buffers
historyLength = 200;
historyAx = zeros(1, historyLength);
historyAy = zeros(1, historyLength);
historyAz = zeros(1, historyLength);
historyGx = zeros(1, historyLength);
historyGy = zeros(1, historyLength);
historyGz = zeros(1, historyLength);
historyIndex = 1; % Circular buffer index


%% Figers and subplots
figure('Name','Sensor Visualization','NumberTitle','off','Position',[100 100 1300 800]);

% one row for accelerometer with fixed range
ax1 = subplot(2,3,1);
hLine1 = plot(1:historyLength, historyAx, 'b','LineWidth',1.5);
title(ax1, 'ax (m/s^2)');
ylim(ax1, [-5 5]);
xlabel(ax1, 'Time');
ylabel(ax1, 'm/s^2');
grid(ax1, 'on');

ax2 = subplot(2,3,2);
hLine2 = plot(1:historyLength, historyAy, 'b','LineWidth',1.5);
title(ax2, 'ay (m/s^2)');
ylim(ax2, [-5 5]);
xlabel(ax2, 'Time');
ylabel(ax2, 'm/s^2');
grid(ax2, 'on');

ax3 = subplot(2,3,3);
hLine3 = plot(1:historyLength, historyAz, 'b','LineWidth',1.5);
title(ax3, 'az (m/s^2)');
ylim(ax3, [-5 5]);
xlabel(ax3, 'Time');
ylabel(ax3, 'm/s^2');
grid(ax3, 'on');

% 2nd row for gyrscope with fixed range
ax4 = subplot(2,3,4);
hLine4 = plot(1:historyLength, historyGx, 'r','LineWidth',1.5);
title(ax4, 'gx (°/s)');
ylim(ax4, [-25 25]);
xlabel(ax4, 'Time');
ylabel(ax4, '°/s');
grid(ax4, 'on');

ax5 = subplot(2,3,5);
hLine5 = plot(1:historyLength, historyGy, 'r','LineWidth',1.5);
title(ax5, 'gy (°/s)');
ylim(ax5, [-25 25]);
xlabel(ax5, 'Time');
ylabel(ax5, '°/s');
grid(ax5, 'on');

ax6 = subplot(2,3,6);
hLine6 = plot(1:historyLength, historyGz, 'r','LineWidth',1.5);
title(ax6, 'gz (°/s)');
ylim(ax6, [-25 25]);
xlabel(ax6, 'Time');
ylabel(ax6, '°/s');
grid(ax6, 'on');

drawnow;


%% Main loop to read data and to update plots
disp('Starting sensor visualization. Press Ctrl+C to stop.');
while true
    if t.BytesAvailable > 0
 
        dataStr = fscanf(t); %data read line by line 
        dataStr = strtrim(dataStr);
        % Expected format: "ax,ay,az,gx,gy,gz"
        vals = str2double(strsplit(dataStr, ','));
        if numel(vals)==6 && all(~isnan(vals))
          
            axVal = vals(1) 
            ayVal = vals(2) 
            azVal = vals(3) 
            % Gyroscope values in °/s
            gxVal = vals(4);
            gyVal = vals(5);
            gzVal = vals(6);
            
            % Update subplot titles with current values
            title(ax1, sprintf('ax = %.4f m/s^2', axVal));
            title(ax2, sprintf('ay = %.4f m/s^2', ayVal));
            title(ax3, sprintf('az = %.4f m/s^2', azVal));
            title(ax4, sprintf('gx = %.4f °/s', gxVal));
            title(ax5, sprintf('gy = %.4f °/s', gyVal));
            title(ax6, sprintf('gz = %.4f °/s', gzVal));
            
            % Update history buffers (circular buffer)
            historyAx(historyIndex) = axVal;
            historyAy(historyIndex) = ayVal;
            historyAz(historyIndex) = azVal;
            historyGx(historyIndex) = gxVal;
            historyGy(historyIndex) = gyVal;
            historyGz(historyIndex) = gzVal;
            
            historyIndex = historyIndex + 1;
            if historyIndex > historyLength
                historyIndex = 1;
            end
            
            % Update plotted lines with new history data
            set(hLine1, 'YData', historyAx);
            set(hLine2, 'YData', historyAy);
            set(hLine3, 'YData', historyAz);
            set(hLine4, 'YData', historyGx);
            set(hLine5, 'YData', historyGy);
            set(hLine6, 'YData', historyGz);
            
            drawnow limitrate;
        end
    end
    pause(0.01);  % Short pause to avoid overloading the CPU
end


fclose(t);
delete(t);
clear t;
