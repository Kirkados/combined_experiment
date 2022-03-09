% The following script is the initializer for SPOT 2.0; in this script,
% users define all initials parameters and/or constants required for
% simulation and experiment.

% Version: 3.07 (Beta Release)

% Authors: Alexander Crain
% Legacy: David Rogers & Kirk Hovell

clear;
clc;
close all force;
addpath(genpath('../../Custom_Library'))

warning('off','all')

fprintf('|----------------------------------------------------------------|\n')
fprintf('|----------------------------------------------------------------|\n')
fprintf('|                       -------------------                      |\n')
fprintf('|                     | Welcome to SPOT 3.0 |                    |\n')
fprintf('|                       -------------------                      |\n')
fprintf('|                                                                |\n')
fprintf('|Authors (v3.0): Alex Crain                                      |\n')
fprintf('|Authors (v2.0): Alex Crain and Kirk Hovell                      |\n')
fprintf('|Authors (Legacy): Dave Rogers and Kirk Hovell                   |\n')
fprintf('|                                                                |\n')
fprintf('|Current Version: 3.07 (Beta Release)                            |\n')
fprintf('|                                                                |\n')
fprintf('|Last Edit: 2021-03-02                                           |\n')
fprintf('|                                                                |\n')
fprintf('|----------------------------------------------------------------|\n')
fprintf('|----------------------------------------------------------------|\n')

%% User-defined constants:

% The folder name of the model used (where the physical parameters will be pulled from)
model_folder = '9day_newProperties_newthrust_DECAY1_a02_alpha05_spin_rcdc-2021-07-22_11-35'

initial_condition_number = 3 % [1, 2, or 3] describing the three initial conditions being tested (defined at line 312)

% Arm limit and post-capture parameters
joint_limit_buffer_angle = 0; % [deg] how early the arm will try and stop before reading 90 deg
bring_arm_to_rest_time = 3; % [s] how long to spend gradually bringing the arm to rest after capture

% Velocity PI controller gains (commented because this controller isn't
% used as of July 13, 2021--feedforward instead).
%Kp_vel_PI = 40; %50
%KI_vel_PI = 0; %0 

%Kp_vel_PI_theta = 0.6;
%KI_vel_PI_theta = 0;


% Loading in mass properties from the relevant Python environment for use in the feedforward controller
fileID = fopen(strcat('Guidance Models/', model_folder, '/code/environment_manipulator.py'));
environment_file = fscanf(fileID,'%s');

% Body speed limit parameters
value = 'self.MAX_VELOCITY';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
max_x_velocity = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));
max_y_velocity = max_x_velocity;

value = 'self.MAX_BODY_ANGULAR_VELOCITY';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
max_body_omega = str2num(erase(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2),'np.'));

% Arm speed limit parameters
value = 'self.MAX_ARM_ANGULAR_VELOCITY';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
shoulder_max_omega = str2num(erase(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2),'np.'));
elbow_max_omega = shoulder_max_omega; % [rad/s]
wrist_max_omega = shoulder_max_omega; % [rad/s]


value = 'self.PHI';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
phi = str2num(erase(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2),'np.'));

value = 'self.B0';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
b0 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.MASS';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
m0 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.M1';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
m1 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.M2';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
m2 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.M3';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
m3 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.A1';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
a1 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.B1';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
b1 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.A2';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
a2 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.B2';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
b2 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.A3';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
a3 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.B3';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
b3 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.INERTIA';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
I0 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.INERTIA1';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
I1 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.INERTIA2';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
I2 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

value = 'self.INERTIA3';
search_start = strfind(environment_file,value);
search_end = strfind(environment_file(search_start(1):end),'#');
I3 = str2double(environment_file(search_start(1)+length(value)+1:search_start(1)+search_end(1)-2));

% Converting from degrees to radians and vis versa:

d2r                            = pi/180;
r2d                            = 180/pi;

% Initialize the table size for use in the GUI (don't delete):

xLength                        = 3.51155;   % [m]
yLength                        = 2.41935;   % [m]

% Initialize the PID gains for the RED platform:

Kp_xr                          = 2;
Kd_xr                          = 5;

Kp_yr                          = 2;
Kd_yr                          = 5;

Kp_tr                          = 0.1;
Kd_tr                          = 0.4;

% Initialize the PID gains for the BLACK platform:

Kp_xb                          = 2;
Kd_xb                          = 5;

Kp_yb                          = 2;
Kd_yb                          = 5;

Kp_tb                          = 0.1/5; % Set to 0 because Black's attitude oscillates 
Kd_tb                          = 0.4/5; % Set to 0 because Black's attitude oscillates 

% Initialize the PID gains for the BLUE platform:

Kp_xblue                       = 2;
Kd_xblue                       = 5;

Kp_yblue                       = 2;
Kd_yblue                       = 5;

Kp_tblue                       = 0.1;
Kd_tblue                       = 0.4;

% Set the noise variance level for the RED and BLACK platforms:

noise_variance_RED             = 0;
noise_variance_BLACK           = 0;
noise_variance_BLUE            = 0;

%% Set the base sampling rate: 

% This variable will change the frequency at which the template runs. If
% the frequency of the template changes, the frequency of the server must
% also be changed, i.e. open the StreamData.sln under the PhaseSpace Server
% folder, and change line 204 from owl.frequency(10) to 
% owl.frequency(serverRate):

baseRate                       = 1/20;      % 20 Hz

%% Set the frequency that the data is being sent up from the PhaseSpace:

% This variable must be less then the baseRate; in simulation, setting this
% equal to the baseRate causes the simulation fail, while in experiment
% setting this equal to or higher then the baseRate causes the data to
% buffer in the UDP send.

serverRate                     = 1/10;       % 10 Hz

%% Set the duration of each major phase in the experiment, in seconds:

Phase0_Duration                = 5;        % [s]
Phase1_Duration                = 5;         % [s]
Phase2_Duration                = 25;        % [s]
Phase3_Duration                = 60;        % [s]
Phase4_Duration                = 20;        % [s]
Phase5_Duration                = 5;         % [s]

% Set the duration of the sub-phases. Sub-phases occur during the
% experiment phase (Phase3_Duration) and must be manually inserted into the
% diagram. The total duration of the sub-phases must equal the length of
% the Phase3_Duration.

Phase3_SubPhase1_Duration      = 0;        % [s]
Phase3_SubPhase2_Duration      = 0;        % [s]
Phase3_SubPhase3_Duration      = 0;        % [s]
Phase3_SubPhase4_Duration      = 60;       % [s]

% Determine the total experiment time from the durations:

tsim                           = Phase0_Duration + Phase1_Duration + ...
                                 Phase2_Duration + Phase3_Duration + ...
                                 Phase4_Duration + Phase5_Duration;        

% Determine the start time of each phase based on the duration:

Phase0_End                     = Phase0_Duration;
Phase1_End                     = Phase0_Duration + Phase1_Duration;           
Phase2_End                     = Phase0_Duration + Phase1_Duration + ...
                                 Phase2_Duration;         
Phase3_End                     = Phase0_Duration + Phase1_Duration + ...
                                 Phase2_Duration + Phase3_Duration;      
Phase4_End                     = Phase0_Duration + Phase1_Duration + ...
                                 Phase2_Duration + Phase3_Duration + ...
                                 Phase4_Duration; 
Phase5_End                     = Phase0_Duration + Phase1_Duration + ...
                                 Phase2_Duration + Phase3_Duration + ...
                                 Phase4_Duration + Phase5_Duration;                              
                             
% Determine the start time of each sub-phase based on the duration:  

Phase3_SubPhase1_End           = Phase2_End + Phase3_SubPhase1_Duration;
Phase3_SubPhase2_End           = Phase2_End + Phase3_SubPhase1_Duration + ...
                                 Phase3_SubPhase2_Duration;
Phase3_SubPhase3_End           = Phase2_End + Phase3_SubPhase1_Duration + ...
                                 Phase3_SubPhase2_Duration +...
                                 Phase3_SubPhase3_Duration;
Phase3_SubPhase4_End           = Phase2_End + Phase3_SubPhase1_Duration + ...
                                 Phase3_SubPhase2_Duration +...
                                 Phase3_SubPhase3_Duration +...
                                 Phase3_SubPhase4_Duration;                             
                          
%% Load in any required data:

% Define the mass properties for the RED, BLACK, and BLUE platforms:

model_param(1)                 = 11.211000; % RED Mass
model_param(2)                 = 0.202150; % RED Inertia
model_param(3)                 = 12.039000; % BLACK Mass
model_param(4)                 = 0.225692; % BLACK Inertia
model_param(5)                 = 12.7621; % BLUE Mass
model_param(6)                 = 0.1930;  % BLUE Inertia

% Initialize the thruster positions for the RED, BLACK, and BLUE platforms,
% as well as the expected maximum forces.

%F_thrusters_RED               = 0.183.*ones(8,1);
F_red_X_nominal = 0.2196; % [N] nominal thrust with only 2 or less thrusters firing
F_red_Y_nominal = 0.2825; % [N] nominal thrust with only 2 or less thrusters firing
F_thrusters_RED  = [F_red_X_nominal; F_red_X_nominal; F_red_Y_nominal; F_red_Y_nominal; F_red_X_nominal; F_red_X_nominal; F_red_Y_nominal; F_red_Y_nominal];
thruster_count_threshold = 0.0; % how much duty cycle is needed to count this thruster as on (to the point where it disrupts thrust to other thrusters)
%thrusters_on_X_RED       = [0, 1, 2,   3,   4];
%thruster_strengths_X_RED = [1, 1, 1, 1, 1]; % [fraction of nominal thrust] corresponding to above number of thrusters; used to be [1,1,1,0.7,0.7]
%thrusters_on_Y_RED =       [0, 1, 2,   3,   4];
%thruster_strengths_Y_RED = [1, 1, 1, 1, 1]; % [fraction of nominal thrust] corresponding to above number of thrusters; used to be [1,1,1,0.7,0.7]


F_thrusters_BLACK             = 0.183.*ones(8,1);
F_thrusters_BLUE              = 0.183.*ones(8,1);
thruster_dist2CG_RED          = [69.38;-56.62;50.01;-81.49;61.12;-68.38;78.99;-52.01];
thruster_dist2CG_BLACK        = [72.80;-65.20;61.75;-79.75;65.20;-65.20;74.25;-54.75];
thruster_dist2CG_BLUE         = [83.42;-52.58;55.94;-60.05;54.08;-53.92;77.06;-55.94];


%%  Set the drop, initial, and home positions for each platform:

if initial_condition_number == 1
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% INITIAL CONDITION 1 IS COMPLETE AND REPEATABLE         %%% 
    %%% Note: Target angular rate is not hard-coded in python! %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Arm initial conditions (only used when running Set_arm_angles)
    initial_shoulder_angle = 0*pi/180; % [rad]
    initial_elbow_angle = 0*pi/180; % [rad]
    initial_wrist_angle = 0*pi/180; % [rad]

    % Target parameters
    target_angular_velocity = 5*pi/180;
    target_starting_angle = 0;

    drop_states_RED           = [ 1.16; 1.2; 0]; % [m; m; rad]
    drop_states_BLACK         = [ 2.33; 1.2; target_starting_angle];  % [m; m; rad]
    drop_states_BLUE          = [ xLength/2+0.9; yLength/2+0.5; 0];         % [m; m; rad]

    init_states_RED           = [ 1.16; 1.2; 0]; % [m; m; rad]
    init_states_BLACK         = [ 2.33; 1.2; target_starting_angle];      % [m; m; rad]
    init_states_BLUE          = [ xLength/2+0.9; yLength/2+0.5; 0];      % [m; m; rad]

    home_states_RED           = [ 1.16; 1.2; 0]; % [m; m; rad]
    home_states_BLACK         = [ 2.33; 1.2; target_starting_angle];  % [m; m; rad]
    home_states_BLUE          = [ xLength/2-0.9; yLength/2+0.5; 0];  % [m; m; rad]

elseif initial_condition_number == 2
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% INITIAL CONDITION 2 IS COMPLETE AND REPEATABLE         %%% 
    %%% Note: Target angular rate is not hard-coded in python! %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Arm initial conditions (only used when running Set_arm_angles)
    initial_shoulder_angle = pi/3; % [rad]
    initial_elbow_angle = -pi/4; % [rad]
    initial_wrist_angle = 80*pi/180; % [rad]

    % Target parameters
    target_angular_velocity = 10*pi/180;
    target_starting_angle = -7*pi/6;

    drop_states_RED           = [ 1.16; 0.6; pi]; % [m; m; rad]
    drop_states_BLACK         = [ 2.33; 1.2; target_starting_angle];  % [m; m; rad]
    drop_states_BLUE          = [ xLength/2+0.9; yLength/2+0.5; 0];         % [m; m; rad]

    % Change this if re-calibrating phasespace doesn't help
    init_states_RED           = [ 1.16; 0.6; pi]; % [m; m; rad]
    
    init_states_BLACK         = [ 2.33; 1.2; target_starting_angle];      % [m; m; rad]
    init_states_BLUE          = [ xLength/2+0.9; yLength/2+0.5; 0];      % [m; m; rad]

    home_states_RED           = [ 1.16; 0.6; pi]; % [m; m; rad]
    home_states_BLACK         = [ 2.33; 1.2; target_starting_angle];  % [m; m; rad]
    home_states_BLUE          = [ xLength/2-0.9; yLength/2+0.5; 0];  % [m; m; rad]
   
elseif initial_condition_number == 3
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% INITIAL CONDITION 3 IS COMPLETE AND not REPEATABLE     %%% 
    %%% Note: Target angular rate is not hard-coded in python! %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    % Arm initial conditions (only used when running Set_arm_angles)
    initial_shoulder_angle = pi/2; % [rad]
    initial_elbow_angle = pi/2; % [rad]
    initial_wrist_angle = 0; % [rad]

    % Target parameters
    target_angular_velocity = -5*pi/180;
    target_starting_angle =  -100*pi/180 - target_angular_velocity*Phase2_Duration; % The angle is the desired one at the beginning of Phase 3

    %drop_states_RED           = [ 0.5; 0.8; pi/4]; % [m; m; rad] v1
    drop_states_RED           = [ 0.5; 1.6; pi/4]; % [m; m; rad] v2
    %drop_states_RED           = [ 2.0; 2.0; pi/4]; % [m; m; rad] v3
    drop_states_BLACK         = [ 2.33; 1.2; target_starting_angle];  % [m; m; rad]
    drop_states_BLUE          = [ xLength/2+0.9; yLength/2+0.5; 0];         % [m; m; rad]

    init_states_RED           = drop_states_RED;
    init_states_BLACK         = [ 2.33; 1.2; target_starting_angle];      % [m; m; rad]
    init_states_BLUE          = [ xLength/2+0.9; yLength/2+0.5; 0];      % [m; m; rad]

    home_states_RED           = drop_states_RED;
    home_states_BLACK         = [ 2.33; 1.2; target_starting_angle];  % [m; m; rad]
    home_states_BLUE          = [ xLength/2-0.9; yLength/2+0.5; 0];  % [m; m; rad]
end
                                              
%% Start the graphical user interface:
(target_starting_angle + target_angular_velocity*Phase2_Duration)*180/pi
run('GUI_v3_07')


