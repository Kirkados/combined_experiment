%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2017 ROBOTIS CO., LTD.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author: Ryu Woon Jung (Leon)

%
% *********     Read and Write Example      *********
%
%
% Available Dynamixel model on this example : All models using Protocol 2.0
% This example is designed for using a Dynamixel PRO 54-200, and an USB2DYNAMIXEL.
% To use another Dynamixel model, such as X series, see their details in E-Manual(emanual.robotis.com) and edit below variables yourself.
% Be sure that Dynamixel PRO properties are already set as %% ID : 1 / Baudnum : 1 (Baudrate : 57600)
%

clc;
clear all;
addpath(genpath('DynamixelSDK-3.7.31/c/include'))
addpath('DynamixelSDK-3.7.31/c/build/win64/output')
addpath(genpath('DynamixelSDK-3.7.31/matlab'))

lib_name = '';

if strcmp(computer, 'PCWIN')
  lib_name = 'dxl_x86_c';
elseif strcmp(computer, 'PCWIN64')
  lib_name = 'dxl_x64_c';
elseif strcmp(computer, 'GLNX86')
  lib_name = 'libdxl_x86_c';
elseif strcmp(computer, 'GLNXA64')
  lib_name = 'libdxl_x64_c';
elseif strcmp(computer, 'MACI64')
  lib_name = 'libdxl_mac_c';
end

% Load Libraries
if ~libisloaded(lib_name)
    [notfound, warnings] = loadlibrary(lib_name, 'dynamixel_sdk.h', 'addheader', 'port_handler.h', 'addheader', 'packet_handler.h');
end

% Control table address
ADDR_TORQUE_ENABLE       = 64;         % Control table address is different in Dynamixel model
ADDR_PRESENT_POSITION    = 132;
ADDR_PRESENT_VELOCITY = 128;
ADDR_DRIVE_MODE = 10;
ADDR_OPERATING_MODE = 11;
ADDR_VELOCITY_LIMIT = 44;
ADDR_PROFILE_ACCELERATION = 108;
ADDR_GOAL_VELOCITY = 104;

% Protocol version
PROTOCOL_VERSION            = 2.0;          % See which protocol version is used in the Dynamixel

% Default setting
DXL_ID                      = 1;            % Dynamixel ID: 1
BAUDRATE                    = 1000000;
DEVICENAME                  = 'COM3';       % Check which port is being used on your controller
                                            % ex) Windows: 'COM1'   Linux: '/dev/ttyUSB0' Mac: '/dev/tty.usbserial-*'

TORQUE_ENABLE               = 1;            % Value for enabling the torque
TORQUE_DISABLE              = 0;            % Value for disabling the torque

ESC_CHARACTER               = 'e';          % Key for escaping loop

COMM_SUCCESS                = 0;            % Communication Success result value
COMM_TX_FAIL                = -1001;        % Communication Tx Failed

% Initialize PortHandler Structs
% Set the port path
% Get methods and members of PortHandlerLinux or PortHandlerWindows
port_num = portHandler(DEVICENAME);

% Initialize PacketHandler Structs
packetHandler();

index = 1;
dxl_comm_result = COMM_TX_FAIL;           % Communication result

dxl_error = 0;                              % Dynamixel error
dxl_present_position = 0;                   % Present position


% Initialize Groupsyncwrite Structs
groupwrite_num = groupSyncWrite(port_num, PROTOCOL_VERSION, ADDR_GOAL_VELOCITY, 4);

% Open port
if (openPort(port_num))
    fprintf('Succeeded to open the port!\n');
else
    unloadlibrary(lib_name);
    fprintf('Failed to open the port!\n');
    input('Press any key to terminate...\n');
    return;
end


% Set port baudrate
if (setBaudRate(port_num, BAUDRATE))
    fprintf('Succeeded to change the baudrate!\n');
else
    unloadlibrary(lib_name);
    fprintf('Failed to change the baudrate!\n');
    input('Press any key to terminate...\n');
    return;
end

% Set the Operating Mode
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_OPERATING_MODE, 1);
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
end

% Set the Drive Mode (time-based accelerations)
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_DRIVE_MODE, 1);
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
end

% Set the Profile acceleration time to 125 ms (a block in serverRate in Simulink)
write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_PROFILE_ACCELERATION, typecast(int32(125), 'uint32'));
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
end

% Set the Velocity limit to 5 rev/min (pi/6 rad/s). This corresponds to '22'
write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_VELOCITY_LIMIT, typecast(int32(200), 'uint32'));
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
end



% Enable Dynamixel Torque
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_TORQUE_ENABLE, TORQUE_ENABLE);
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
else
    fprintf('Dynamixel has been successfully connected \n');
end

acceleration =  20;
counter = 0;
goal_velocities = 0;
while counter < 20
    
    % Read present position
    dxl_present_position = read4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_PRESENT_POSITION);
    dxl_present_position = mod(dxl_present_position, 4096); % wrap rotation
    dxl_present_position = dxl_present_position * 0.088; % convert to degrees
    dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
    dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
    if dxl_comm_result ~= COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
    elseif dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
    end
    
    % Read present velocity
    dxl_present_velocity = read4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_PRESENT_VELOCITY);
    dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
    dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
    if dxl_comm_result ~= COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
    elseif dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
    end
    
    % Calculate goal velocity
    goal_velocities = goal_velocities + acceleration * 0.5;
    
    % Check if the limits are passed
    if (dxl_present_position >= 265 && goal_velocities > 0 ) || (dxl_present_position < 95 && goal_velocities < 0)
        %goal_velocities = 0;
    end

    % Add Dynamixel#1 goal velocity value to the Syncwrite storage
    dxl_addparam_result = groupSyncWriteAddParam(groupwrite_num, 1, typecast(int32(goal_velocities), 'uint32'), LEN_PRO_GOAL_POSITION);
    if dxl_addparam_result ~= true
        fprintf('[ID:%03d] groupSyncWrite addparam failed', DXL1_ID);
        return;
    end
    
    % Syncwrite goal velocity
    groupSyncWriteTxPacket(groupwrite_num);
    dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
    if dxl_comm_result ~= COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
    end

    % Clear syncwrite parameter storage
    groupSyncWriteClearParam(groupwrite_num);
    
    fprintf('[ID:%03d] GoalVel:%03d  PresPos:%03d deg   PresVel:%03d\n', DXL_ID, goal_velocities, typecast(uint32(dxl_present_position), 'int32'), typecast(uint32(dxl_present_velocity), 'int32'));    
    
    pause(0.5)
    counter = counter + 1;
end


% Disable Dynamixel Torque
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_TORQUE_ENABLE, TORQUE_DISABLE);
dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
if dxl_comm_result ~= COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
elseif dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
end

% Close port
closePort(port_num);

% Unload Library
unloadlibrary(lib_name);

close all;
clear all;
