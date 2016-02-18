function varargout = EMGProcessing(varargin)
% EMGPROCESSING M-file for EMGProcessing.fig
%      EMGPROCESSING, by itself, creates a new EMGPROCESSING or raises the existing
%      singleton*.
%
% This Code initializes the GUI figure for processing EMG obtained in the
% MacMobilize Laboratory.  It is assumed the user understands basic
% elements of EMG processing.  
%
% Function inputs:              varargin
%
% Subfunctions called:          QuietTrial.m
%                               MVICTrials.m
%                               NormCycle.m (normalize data to a cycle)
%                               TrialProcessing.m
%                               GraphData.m
%
% Function outputs:             varargout
%
% Created by: Elora C. Brenneman
%
% Late updated: November 12, 2014
% -----------------------------------------------------------------
% Begin initialization code - DO NOT EDIT
% -----------------------------------------------------------------
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EMGProcessing_OpeningFcn, ...
                   'gui_OutputFcn',  @EMGProcessing_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
end
% ----------------------------------------------------------------
% End initialization code - DO NOT EDIT
% ----------------------------------------------------------------

% Executes just before EMGProcessing is made visible
function EMGProcessing_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
set(handles.NormalizeEMG,'Visible','Off');
end

% Outputs from this function are returned to the command line
function varargout = EMGProcessing_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
end


% ----------------------------------------------------------------
% EDITABLE CODE START HERE
% ----------------------------------------------------------------

% Gets handle for the value typed in the Sampling rate textbox
function Sample_Rate_Callback(hObject, eventdata, handles)
samples=str2double(get(hObject,'String'));
if isnan(samples)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return
else
end
handles.samples=samples;
guidata(hObject,handles)
end

% Executes during object creation, after setting all properties
function Sample_Rate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% Gets handle for the value typed in the Number of muscles textbox
function Num_Muscles_Callback(hObject, eventdata, handles)
muscles=str2double(get(hObject,'String'));
if isnan(muscles)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return
else
end
handles.muscles=muscles;
guidata(hObject,handles)
end

% Executes during object creation, after setting all properties.
function Num_Muscles_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% Executes on selection change in Filter pass dropdown menu
function Filt_Pass_Callback(hObject, eventdata, handles)
pass=get(hObject,'String');
index_selected=get(hObject,'Value');
handles.pass=index_selected;
guidata(hObject,handles)
end

% Executes during object creation, after setting all properties
function Filt_Pass_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Single pass (time delay)';'Dual pass (no time delay)'});
end

% Gets handle for the Filter order entered in the 
function Filt_Order_Callback(hObject, eventdata, handles)
order=str2double(get(hObject,'String'));
if isnan(order)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return
else
end
handles.order=order;
guidata(hObject,handles)
end

% Executes during object creation, after setting all properties
function Filt_Order_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Filt_Cutoff_Callback(hObject, eventdata, handles)
cutoff=str2double(get(hObject,'String'));
if isnan(cutoff)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return
else
end
handles.cutoff=cutoff;
guidata(hObject,handles)
end

% Executes during object creation, after setting all properties
function Filt_Cutoff_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% Stores handle for Normalization callback
function Norm_Callback(hObject, eventdata, handles)
norm=get(hObject,'String');
index_selected=get(hObject,'Value');
handles.norm=index_selected;
if index_selected == 3
    promptMessage=sprintf('MVIC Trials are not required');
    button=questdlg(promptMessage,titleBarCaption,'Continue','Cancel','Continue');
    if strcmpi(button,'Cancel')
        return;
    end
else
end
guidata(hObject,handles)
end

% Executes during object creation, after setting all properties
function Norm_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Linear Envelope (Single peak)';'Linear Envelope (Moving average';'Integrated EMG';'Median Power Frequency';'APDF'});
end

% Executes on selection change in Quiet Listbox
function Quiet_Listbox_Callback(hObject, eventdata, handles)
dir_struct=dir;
[sorted_names,sorted_index]=sortrows({dir_struct.name}');
handles.file_names=sorted_names;
handles.is_dir=[dir_struct.isdir];
handles.sorted_index=sorted_index;
guidata(handles.figure1,handles)
set(handles.Quiet_Listbox,'String',handles.file_names,...
	'Value',1)
get(handles.figure1,'SelectionType');
end

% Executes during object creation, after setting all properties.
function Quiet_Listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% Executes on button press for selecting the quiet trial
function Quiet_Callback(hObject, eventdata, handles)
[filename,pathname]=uigetfile('*.*','Select Quiet Trial','MultiSelect','on');
samples=handles.samples;
muscles=handles.muscles;
order=handles.order;
cutoff=handles.cutoff;
[Quiet]=QuietTrial(filename,samples,muscles,order,cutoff);
end

% Executes on button press for selecting MVIC trials
function MVIC_Callback(hObject, eventdata, handles)
[filename,pathname]=uigetfile('*.*','Select all MVIC Trials','MultiSelect','on');
samples=handles.samples;
muscles=handles.muscles;
order=handles.order;
cutoff=handles.cutoff;
pass=handles.pass;
norm=handles.norm;
[MVIC_Values1]=MVICTrials(filename,pathname,samples,muscles,order,cutoff,pass,norm);
set(handles.uitable2,'Data',MVIC_Values1);
end

% Executes on button press in Normalize.
function Normalize_Callback(hObject, eventdata, handles)
normalize=get(handles.Normalize,'Value');
if get(hObject,'Value') == 1
    set(handles.NormalizeEMG,'Visible','On');
else 
    set(handles.NormalizeEMG,'Visible','Off');
end
end

% Executes on button press for Cycle 
function Cycle_Button_Callback(hObject, eventdata, handles)
[filename,pathname]=uigetfile('*.*','Select File with Cycle Normalization','MultiSelect','on');
[CycleData]=NormCycle(filename);
end

% Executes on button press in for Trial EMG
function Trial_EMG_Callback(hObject, eventdata, handles)
samples=handles.samples;
muscles=handles.muscles;
order=handles.order;
cutoff=handles.cutoff;
pass=handles.pass;
normalize=handles.normalize;
[AveProcessedEMG]=TrialProcessing(samples,muscles,order,cutoff,pass,normalize);
set(handles.uitable3,'Data',AveProcessedEMG);
end


% Executes on button press in Graph.
function Graph_Callback(hObject, eventdata, handles)
input=1;
[input1]=GraphData(input);
end
