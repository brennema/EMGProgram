function [AveProcessedEMG]=TrialProcessing(samples,muscles,order,cutoff,pass,normalize)
% TRIALPROCESSING M-file; Subfunction called in the function EMGPROCESSING.
%
% Function inputs:          samples - 'sampling rate of the EMG from Noraxon (typically 1500)'
%                           muscles - 'number of muscles collected'
%                           order - 'filter order'
%                           cutoff - 'filter cutoff for linear envelope'
%                           pass - 'denotes single pass versus dual pass filter'
%                           normalize - 'denotes whether trial data is to be normalized to some sort of time function (i.e., cycle)'
%
% Subfunctions called:      none
%
% Function outputs:         AveProcessedEMG - 'vector containing average EMG over a defined time fram (i.e., cycle)'
%
% Created by:               Elora C. Brenneman
%
% Date last updated:        November 12, 2014
% -------------------------------------------------------------------------
disp('Message #4')
disp('Program is working. Please wait for prompt before continuing.')
file=[dir('*.xls')];
numFiles=length(file);
n=1;
  for i=1:numFiles; %call in directory of EMG data
      filename=file(i).name;
      analog=dlmread(filename,'\t',5,1);
      last_channel=24+muscles;
      EMG=analog(:,25:last_channel);
      Wn=samples/2;
      
      [c,d]=butter(order,500/Wn,'low'); %bandpass filter from 10-500 Hz
      [e,f]=butter(order,10/Wn,'high');
      lowpass=filtfilt(c,d,EMG);
      bandpass=filtfilt(e,f,lowpass);

      meanEMG=mean(bandpass);
      BiasRemoved=zeros(size(bandpass)); %preallocate variable for speed
      for k=1:length(bandpass);
          BiasRemoved(k,:)=bandpass(k,:)-meanEMG; %removal of bias
      end
      FWR=abs(BiasRemoved);
      [a,b]=butter(order,cutoff/Wn,'low');
      
      LEEMG=zeros(size(FWR)); %preallocate variable for speed
      if pass == 1 %'if' statement that denotes filter pass (single versus dual)
          LEEMG=filter(a,b,FWR);
      elseif pass == 2
          LEEMG=filtfilt(a,b,FWR);
      else
      end
    
      TrueEMG=LEEMG*1000;
      Quiet=evalin('base','Quiet');
      QuietRemoved=zeros(size(TrueEMG)); %preallocate
      for j=1:length(TrueEMG)
          QuietRemoved(j,:)=TrueEMG(j,:)-Quiet;
      end
        
      MVIC_Values=evalin('base','MVIC_Values');
      MVIC_Values1=MVIC_Values';
      MVIC=max(MVIC_Values1);
      NormEMG=bsxfun(@rdivide,QuietRemoved,MVIC);
      NormalizedEMG=NormEMG*100; %convert trial data to match output from MyoResearch (different units)
      
      if  normalize == 1 %'if' statement that normalizes data to cycle, or calculates trial EMG
          CycleData=evalin('base','CycleData');
          CycleData1=CycleData*1000;
          XNorm=NormalizedEMG(CycleData1(n,1):CycleData1(n,2),:);
          Length_EMGData=length(XNorm);
          Upsample=Length_EMGData/100;
          X=1:Length_EMGData;
          Xi=0:Upsample:Length_EMGData;
          ProcessedEMG=interp1(X,XNorm,Xi,'cubic');
      else
          ProcessedEMG=NormalizedEMG;
      end
         
      f=1;
      c=muscles/2;
      r=2;
      n=repmat(cumsum(ones(1,r*c)),1,f);
      h=ceil((i:f*r*c)/(r*c));
      for jx=1:f*r*c %'for' loop that subplots bias removed data for each muscle examined
          figure(1)
          subplot(r,c,n(jx))
          plot(BiasRemoved(:,jx)) 
          title(filename)
      end
      pause
      for jx=1:f*r*c
          figure(2)
          subplot(r,c,n(jx))
          plot(NormalizedEMG(:,jx))
          title(filename)
      end
      pause
      
      AveProcessedEMG(i,:)=mean(ProcessedEMG);
      csvwrite([filename, '.csv'],ProcessedEMG)
      n=n+1;
  end
  assignin('base','AveProcessedEMG',AveProcessedEMG)
  disp('DONE!')
end