function [CycleData]=NormCycle(filename)
% NORMCYCLE M-file; Subfunction called in the function EMGPROCESSING.
%
% Function inputs:          filename - 'array of strings listing names of files selected for processing'
%
% Subfunctions called:      none
%
% Function outputs:         CycleData - 'matrix containing time values for normalizing data to a cycle (i.e., lift)'
%
% Created by:               Elora C. Brenneman
%
% Date last updated:        November 12, 2014
% -------------------------------------------------------------------------
disp('Message #3')
disp('Program is working. Please wait for prompt before continuing.')
data=dlmread(filename,'\t',5,1); %import .txt data from V3D
x=2;
Start=data(1:x:end)';
End=data(2:x:end)';
CycleData=[Start End]; %concatenize data (start and end of cycle)
assignin('base','CycleData',CycleData); %assign cycle data into Base workspace

promptMessage=sprintf('Continue to process EMG'); %prompt user to continue processing EMG
titleBarCaption='Continue?';
button=questdlg(promptMessage,titleBarCaption,'Continue','Cancel','Continue');
if strcmpi(button,'Cancel')
	return;
end
end
