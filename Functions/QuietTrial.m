function [Quiet]=QuietTrial(filename,samples,muscles,order,cutoff)
% QUIETTRIAL M-file; Subfunction called in the function EMGPROCESSING.
%
% Function inputs:          filename - 'array of strings listing names of files selected for processing'
%                           samples - 'sampling rate of the EMG from Noraxon (typically 1500)'
%                           muscles - 'number of muscles collected'
%                           order - 'filter order'
%                           cutoff - 'filter cutoff for linear envelope'
%
% Subfunctions called:      none
%
% Function outputs:         Quiet - 'vector containing values from quiet trial for subtraction from data'
%
% Created by:               Elora C. Brenneman
%
% Date last updated:        November 12, 2014
% -------------------------------------------------------------------------
disp('Message #1')
disp('Program is working. Please wait for prompt before continuing.')
data=dlmread(filename,'\t',5,0); %read in .txt file from MyoResearch
Wn=samples/2;
numMuscles=muscles+1;
newData=data(:,2:numMuscles); %create matrix with only the EMG data

[c,d]=butter(order,500/Wn,'low'); %bandpass filter from 10-500 Hz
[e,f]=butter(order,10/Wn,'high');
lowpassQuiet=filtfilt(c,d,newData);
bandpassQuiet=filtfilt(e,f,lowpassQuiet);

meanQuiet=mean(bandpassQuiet);
for i=1:length(bandpassQuiet);
    BiasRemoved(i,:)=bandpassQuiet(i,:)-meanQuiet; %remove bias (subtract the mean)
end
FWR=abs(BiasRemoved); %full wave rectify

[a,b]=butter(order,cutoff/Wn,'low');
LEQuiet=filtfilt(a,b,FWR);
Quiet=mean(LEQuiet(5000:6000,:));
assignin('base','Quiet',Quiet); %assign the 'Quiet' variable into the Base workspace 

promptMessage=sprintf('Continue to process EMG'); %prompt message to enable the user to continue processing EMG
titleBarCaption='Continue?';
button=questdlg(promptMessage,titleBarCaption,'Continue','Cancel','Continue');
if strcmpi(button,'Cancel')
	return;
end
end
