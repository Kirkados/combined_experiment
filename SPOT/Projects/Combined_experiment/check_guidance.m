% This script analyzes expeirmental results

% If it's a simulation
%rt_dataPacket = dataPacket;

close all

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,65))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,71))
yyaxis right
%plot(rt_dataPacket(:,1),rt_dataPacket(:,91))
%plot(rt_dataPacket(:,1),rt_dataPacket(:,92))
legend('Accel X command', 'True Ax','Thrusters On','Thruster sum')
yyaxis left

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,66))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,72))
yyaxis right
%plot(rt_dataPacket(:,1),rt_dataPacket(:,91))
%plot(rt_dataPacket(:,1),rt_dataPacket(:,92))
%plot(rt_dataPacket(:,1),rt_dataPacket(:,3))
%plot(rt_dataPacket(:,1),rt_dataPacket(:,89))
legend('Accel Y command', 'True Ay', 'Thrusters on','Thruster sum')
yyaxis left

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,67))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,73))
legend('Alpha command', 'True Alpha')

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,68))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,81))  
plot(rt_dataPacket(:,1),rt_dataPacket(:,78))
yyaxis right
plot(rt_dataPacket(:,1),rt_dataPacket(:,75))
legend('Shoulder  \alpha command', 'Shoulder \omega command', 'True shoulder \omega','\theta shoulder')

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,69))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,82))  
plot(rt_dataPacket(:,1),rt_dataPacket(:,79))
yyaxis right
plot(rt_dataPacket(:,1),rt_dataPacket(:,76))
legend('Elbow  \alpha command', 'Elbow \omega command', 'True Elbow \omega','\theta elbow')

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,70))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,83))  
plot(rt_dataPacket(:,1),rt_dataPacket(:,80))
yyaxis right
plot(rt_dataPacket(:,1),rt_dataPacket(:,77))
legend('Wrist  \alpha command', 'Wrist \omega command', 'True wrist \omega','\theta wrist')

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,85))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,8))
legend('Vx command', 'True Vx')

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,86))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,9))
legend('Vy command', 'True Vy')

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,87))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,10))
legend('\omega command', 'True \omega')

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,88))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,2))
legend('F_x', 'F_x saturated')

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,89))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,3))
legend('F_y', 'F_y saturated')

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,90))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,4))
legend('\tau', '\tau saturated')

