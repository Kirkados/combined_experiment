close all;


% https://www.mathworks.com/help/signal/ref/designfilt.html

time_signal = rt_dataPacket(:,1);
% x
% x_position_signal = rt_dataPacket(:,5);
% x_velocity_signal = rt_dataPacket(:,8);
% x_acceleration_signal = rt_dataPacket(:,68);

% y
% x_position_signal = rt_dataPacket(:,6);
% x_velocity_signal = rt_dataPacket(:,9);
% x_acceleration_signal = rt_dataPacket(:,69);

% theta
x_position_signal = rt_dataPacket(:,7);
x_velocity_signal = rt_dataPacket(:,10);
x_acceleration_signal = rt_dataPacket(:,70);

% Downsample data (since it is repeated twice)
time_signal = downsample(time_signal,2);
x_position_signal = downsample(x_position_signal,2);
x_velocity_signal = downsample(x_velocity_signal,2);
x_acceleration_signal = downsample(x_acceleration_signal,2);

sample_frequency = 2;
cutoff_frequency = 0.5;

% Butterworth
filter_order = 2;
[b,a] = butter(filter_order, cutoff_frequency/(sample_frequency/2));

% Lowpass equiripple
% filter_order = 51;
% [b] = firceqrip(filter_order,cutoff_frequency/(sample_frequency/2), [0.005 0.003]);
% a = 1;

% Moving Average Filter
% window_length = 5;
% b = ones([window_length,1])/window_length;
% a = 1;

% Other lowpass filter (kaiser 96)
% lpFilt = designfilt('lowpassfir','PassbandFrequency',cutoff_frequency/(sample_frequency/2), ...
%          'StopbandFrequency',(cutoff_frequency + 5)/(sample_frequency/2),'PassbandRipple',0.5, ...
%          'StopbandAttenuation',65,'DesignMethod','kaiserwin');
% fvtool(lpFilt)
% [b,a] = tf(lpFilt);

% Another lowpass filter (window)
% lpFilt = designfilt('lowpassfir','FilterOrder',4,'CutoffFrequency',cutoff_frequency/(sample_frequency/2),'DesignMethod','window');
% fvtool(lpFilt)
% [b,a] = tf(lpFilt);



% Plot magnitude and phase response
figure(1)
freqz(b, a, 10000, sample_frequency)

% Plot the group delay
figure(2)
grpdelay(b, a, 10000, sample_frequency)

% Run all signals through this filter
x_position_filtered = filter(b, a, x_position_signal);
x_velocity_filtered = filter(b, a, x_velocity_signal);
x_acceleration_filtered = filter(b, a, x_acceleration_signal);

% Plot original and filtered signal
figure(3)
plot(time_signal, x_position_signal,'r', time_signal, x_position_filtered,'k')
xlabel('Time')
ylabel('Signal')
legend('Unfiltered position','Filtered position')

% Plot original and filtered signal
figure(4)
plot(time_signal, x_velocity_signal,'r', time_signal, x_velocity_filtered,'k')
xlabel('Time')
ylabel('Signal')
legend('Unfiltered velocity','Filtered velocity')

% Plot original and filtered signal
figure(5)
plot(time_signal, x_acceleration_signal,'r', time_signal, x_acceleration_filtered,'k')
xlabel('Time')
ylabel('Signal')
legend('Unfiltered acceleration','Filtered acceleration')

% Differentiate non-acceleration signals until we have 3 versions of
% acceleration
x_filtered_position_ddiff_acceleration = diff(x_position_filtered, 2)*sample_frequency*sample_frequency;
x_filtered_velocity_diff_acceleration   = diff(x_velocity_filtered, 1)*sample_frequency;
x_unfiltered_position_ddiff_acceleration = diff(x_position_signal, 2)*sample_frequency*sample_frequency;

% Plot all 4 versions of acceleration on the same plot
% Filtered at position; filtered at velocity; fitered at acceleration; raw acceleration

figure(6)
plot(time_signal,x_acceleration_signal,'r--', time_signal, x_acceleration_filtered,'ko', time_signal(2:end), x_filtered_velocity_diff_acceleration, 'b')
hold on
plot(time_signal(3:end), x_filtered_position_ddiff_acceleration,'g',time_signal(3:end), x_unfiltered_position_ddiff_acceleration,'ko','LineWidth',2)
legend('Raw','Filtered at acceleration','Filtered at velocity','Filtered at position','Raw differentiated position')
xlabel('Time (s)')
ylabel('Signal')
title('The various ways to calculate acceleration')
xlim([10 95])
ylim([-0.025 0.01])


