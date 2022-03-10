% This script analyzes expeirmental results

close all

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,65))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,68))
legend('Accel X command', 'True Ax')


figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,66))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,69))
legend('Accel Y command', 'True Ay')

figure()
plot(rt_dataPacket(:,1),rt_dataPacket(:,67))
hold on;
plot(rt_dataPacket(:,1),rt_dataPacket(:,70))
plot(rt_dataPacket(:,1),rt_dataPacket(:,10))
legend('Alpha command', 'True Alpha', 'True Omega')