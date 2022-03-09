classdef guidance_server_arm < matlab.System ...
        & coder.ExternalDependency ...
        & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    %
    % System object template for a sink block.
    % 
    % This template includes most, but not all, possible properties,
    % attributes, and methods that you can implement for a System object in
    % Simulink.
    %
    % NOTE: When renaming the class name Sink, the file name and
    % constructor name must be updated to use the class name.
    %
    
    % Copyright 2016 The MathWorks, Inc.
    %#codegen
    %#ok<*EMCA>
    
    properties

    end
    
    properties (Nontunable)

    end
    
    properties (Access = private)

    end
    
    methods
        % Constructor
        function obj = guidance_server_arm(varargin)
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(~)
            if isempty(coder.target)
                % Place simulation setup code here
            else
                % Call C-function implementing device initialization
                coder.cinclude('TCP_Server_arm.h');
                coder.ceval('createServerNewSocket');
            end
        end
        
        function [guided_acceleration_x, guided_acceleration_y, guided_angular_acceleration, guided_shoulder_acceleration, guided_elbow_acceleration, guided_wrist_acceleration, is_captured] = stepImpl(~, time, red_x, red_y, red_angle, red_vx, red_vy, red_dangle,...
            black_x, black_y, black_angle,black_vx, black_vy, black_dangle, shoulder_angle, elbow_angle, wrist_angle, shoulder_omega, elbow_omega, wrist_omega) 
            
            guided_acceleration_x = double(0);
            guided_acceleration_y = double(0);
            guided_angular_acceleration = double(0);
            guided_shoulder_acceleration = double(0);
            guided_elbow_acceleration = double(0);
            guided_wrist_acceleration = double(0);
            is_captured = double(0);
            
            if isempty(coder.target)
                % Place simulation output code here 
            else
                % Call C-function implementing device output
                %coder.ceval('sink_output',u);
                 coder.ceval("run_guidance", time, red_x, red_y, red_angle, red_vx, red_vy, red_dangle, black_x, black_y, black_angle, black_vx, black_vy, black_dangle, shoulder_angle, elbow_angle, wrist_angle, shoulder_omega, elbow_omega, wrist_omega, ... 
                coder.ref(guided_acceleration_x), coder.ref(guided_acceleration_y), coder.ref(guided_angular_acceleration), coder.ref(guided_shoulder_acceleration), coder.ref(guided_elbow_acceleration), coder.ref(guided_wrist_acceleration), coder.ref(is_captured));
                
            end
        end
        
        function releaseImpl(obj) %#ok<MANU>
            if isempty(coder.target)
                % Place simulation termination code here
            else
                % Call C-function implementing device termination
                 coder.ceval('terminate');
            end
        end
    end
    
    methods (Access=protected)
        %% Define input properties
        function num = getNumInputsImpl(~)
            num = 19;
        end
        
        function num = getNumOutputsImpl(~)
            num = 7;
        end
        
        function flag = isInputSizeLockedImpl(~,~)
            flag = true;
        end
        
        function flag = isOutputSizeImpl(~,~)
            flag = true;
        end
        
        function varargout = isInputFixedSizeImpl(~,~)
            varargout{1} = true;
        end
        
        function varargout = isOutputFixedSizeImpl(~,~)
            varargout{1} = true;
            varargout{2} = true;
            varargout{3} = true;
            varargout{4} = true;
            varargout{5} = true;
            varargout{6} = true;
            varargout{7} = true;
        end
        
        function flag = isInputComplexityLockedImpl(~,~)
            flag = true;
        end
        
        function varargout = getOutputSizeImpl(~)
            varargout{1} = [1,1];
            varargout{2} = [1,1];
            varargout{3} = [1,1];
            varargout{4} = [1,1];
            varargout{5} = [1,1];
            varargout{6} = [1,1];
            varargout{7} = [1,1];
        end
        
        function varargout = getOutputDataTypeImpl(~)
            varargout{1} = 'double';
            varargout{2} = 'double';
            varargout{3} = 'double';
            varargout{4} = 'double';
            varargout{5} = 'double';
            varargout{6} = 'double';
            varargout{7} = 'double';
        end
        
        function varargout = isOutputComplexImpl(~)
            varargout{1} = false;
            varargout{2} = false;
            varargout{3} = false;
            varargout{4} = false;
            varargout{5} = false;
            varargout{6} = false;
            varargout{7} = false;
        end
        
        function icon = getIconImpl(~)
            % Define a string as the icon for the System block in Simulink.
            icon = 'Deep Guidance with Arm';
        end  
        
    end
    
    methods (Static, Access=protected)
        function simMode = getSimulateUsingImpl(~)
            simMode = 'Interpreted execution';
        end
        
        function isVisible = showSimulateUsingImpl
            isVisible = false;
        end
        
        function header = getHeaderImpl
            header = matlab.system.display.Header('guidance_server','Title',...
                'TCP Server','Text',...
                ['This simulink block sends and receives data to and from the Jetson using a TCP/IP Server. '...
                'This block should be used once. This version also sends and receives arm commands and returns whether the target has been captured.' newline]);
        end
        
    end
    
    methods (Static)
        function name = getDescriptiveName()
            name = 'guidance_server_arm';
        end
        
        function b = isSupportedContext(context)
            b = context.isCodeGenTarget('rtw');
        end
        
        function updateBuildInfo(buildInfo, context)
            if context.isCodeGenTarget('rtw')
                % Update buildInfo
                srcDir = fullfile(fileparts(mfilename('fullpath')),'src');
                includeDir = fullfile(fileparts(mfilename('fullpath')),'include');
                addIncludePaths(buildInfo,includeDir);
                
                % Add the INCLUDE files for the PhaseSpace camera
                addIncludeFiles(buildInfo,'TCP_Server_arm.h',includeDir);
                
                % Add the SOURCE files for the PhaseSpace camera
                addSourceFiles(buildInfo,'TCP_Server_arm.cpp',srcDir);
                
                %addLinkFlags(buildInfo,{'-lSource'});
                %addLinkObjects(buildInfo,'sourcelib.a',srcDir);
                %addCompileFlags(buildInfo,{'-D_DEBUG=1'});
                %addDefines(buildInfo,'MY_DEFINE_1')
            end
        end
    end
end
