function [MVIC_Values1]=MVICTrials(filename,pathname,samples,muscles,order,cutoff,pass,norm)
% MVICTRIALS M-file; Subfunction called in the function EMGPROCESSING.
%
% Function inputs:          filename - 'array of strings listing names of files selected for processing'
%                           pathname - 'string of the path used to retrieve the filenames'
%                           samples - 'sampling rate of the EMG from Noraxon (typically 1500)'
%                           muscles - 'number of muscles collected'
%                           order - 'filter order'
%                           cutoff - 'filter cutoff for linear envelope'
%                           pass - 'denotes single pass versus dual pass filter'
%                           norm - 'normalization technique (most often single peak)'
%
% Subfunctions called:      none
%
% Function outputs:         MVIC_Values1 - 'vector containing peak MVIC values for each muscle collected'
%
% Created by:               Elora C. Brenneman
%
% Date last updated:        November 12, 2014
% -------------------------------------------------------------------------
disp('Message #2')
disp('Program is working. Please wait for prompt before continuing.')
path=char(pathname);
[row files_selected]=size(filename);
filename=cellstr(filename);
celldisp(filename)
for i=1:files_selected %'for' loop that processes each file at a time in a multiselect
    tempfile=char(filename(i));
    data=dlmread([path,tempfile],'\t',5,0);
    Wn=samples/2;
    numMuscles=muscles+1;
    newData=data(:,2:numMuscles);
    
    [c,d]=butter(order,500/Wn,'low'); %bandpass filter from 10-500 Hz
    [e,f]=butter(order,10/Wn,'high');
    lowpass=filtfilt(c,d,newData);
    bandpass=filtfilt(e,f,lowpass);

    meanMVIC=mean(bandpass);
    BiasRemoved=zeros(size(bandpass)); %preallocate variable for speed
    for k=1:length(bandpass);
        BiasRemoved(k,:)=bandpass(k,:)-meanMVIC; %remove bias (mean of the signal)
    end
    FWR=abs(BiasRemoved); %full wave rectify
    [a,b]=butter(order,cutoff/Wn,'low');
    
    LEMVIC=zeros(size(FWR)); %preallocate variable for speed
    if pass == 1 %'if' statement that determines which filter pass to use based on the GUI pop-down menu
        LEMVIC=filter(a,b,FWR);
    elseif pass == 2
        LEMVIC=filtfilt(a,b,FWR);
    else
    end
    
    Quiet=evalin('base','Quiet');
    QuietRemovedMVIC=zeros(size(LEMVIC)); %preallocate variable for speed
    for j=1:length(LEMVIC)
        QuietRemovedMVIC(j,:)=LEMVIC(j,:)-Quiet;
    end
    
    MVIC=zeros(size(QuietRemovedMVIC)); %preallocate variable for speed
    if norm == 1 %'if' statement that determines MVIC method (single peak or moving average)
        MVIC=max(QuietRemovedMVIC);
    elseif norm == 2
        samplerate=1000;
        window=samplerate*0.25;
        rows=length(LEMVIC);
        for ix=(1:rows-window)
            MVIC=max(LEMVIC(ix:ix+window,:));
        end
    else
    end
    
    MVIC_Values(i,:)=MVIC;
    f=1;
    c=muscles/2;
    r=2;
    n=repmat(cumsum(ones(1,r*c)),1,f);
    h=ceil((i:f*r*c)/(r*c));
    for jx=1:f*r*c %'for' loop that subplots bias removed data of each muscle; paused afterward until user presses any button to continue
        figure(1)
        subplot(r,c,n(jx))
        plot(BiasRemoved(:,jx))
    end
    pause
    for jx=1:f*r*c %'for' loop that subplots processed data of each muscle; paused afterward until user processes any button to continue
        figure(2)
        subplot(r,c,n(jx))
        plot(QuietRemovedMVIC(:,jx))
    end
    pause
    disp('Still working...') %tells the user that the program is still working smoothly; will display on every loop iteration
end
MVIC_Values1=MVIC_Values';
assignin('base','MVIC_Values',MVIC_Values1);
disp('DONE!')
end