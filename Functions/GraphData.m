function [input1]=GraphData(input)
% GRAPHDATA M-file; Subfunction called in the function EMGPROCESSING.
%
% Function inputs:          input - 'binary input to drive the function'
%
% Subfunctions called:      none
%
% Function outputs:         input1 - 'arbitrary output to finish function'
%
% Created by:               Elora C. Brenneman
%
% Date last updated:        November 12, 2014
%
% *This is an OPTIONAL function that runs upon pressing the 'Graph Data'
% button in the GUI that graphs processed data
% -------------------------------------------------------------------------
file=[dir('*.csv')];
numFiles=length(file);
  for i=1:numFiles; %call in directory of EMG data
      filename=file(i).name;
      EMG=csvread(filename,0,0);
      input1=input;
      figure(i)
      plot(EMG)
  end
end