%% --- LEO GUI --- %%%
% This file contains a simple graphical user interface that enables 
% application of Likelihood Estimation of Occupancy without explicit 
% programming skills. To apply the algorithm to your data, please modify 
% the dummy excel files so that they contain your VT values. The number 
% of ROIs is arbitrary, but make sure you use the same ROIs (in the same 
% order) for both the test-retest and the baseline-block data.
% 
% If you do not have test-retest data available, you can only execute LEO 
% using the Identity matrix as covariance matrix. 
% 
% Before you launch this GUI, make sure you have added all necessary files 
% to you matlab path. In addition to the files included in the repository, 
% you should also add the files written by Professor Michael Wolf and 
% Dr. Oliver Ledoit at Department of Economics, University of Zurich, 
% Switzerland. These files perform the non-linear shrinkage of the sample 
% covariance matrix (QuEST). The files can be downloaded from 
% http://www.econ.uzh.ch/en/people/faculty/wolf/publications.html#9 
% under the heading: Ledoit O. and Wolf, M. (2017). Numerical 
% implementation of the QuEST function. Computational Statistics & Data 
% Analysis 115, 199-223. 
% 
% For some mac-users, the standard routine to print data into an excel 
% file doesn?t work well. If you use a mac, download the file cell2csv.m 
% from 
% https://www.mathworks.com/matlabcentral/fileexchange/7601-cell2csv?focused=5063322&tab=function 
% and add it to the MATLAB path. 
% 
% To launch the graphical user interface, please make sure all files are 
% in the MATLAB path. In the prompt, type:
% >>LEO_GUI
% 
% To bypass the graphical interface, please see comments in LEO.m
% 
% For comments or questions regarding this code, please contact
% Martin Schain.
%% ------------------- %%


function varargout = LEO_GUI(varargin)

    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @LEO_GUI_OpeningFcn, ...
                       'gui_OutputFcn',  @LEO_GUI_OutputFcn, ...
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

function LEO_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    handles.doQuEST = 0;
    handles.doDiag = 0;
    handles.doIdentity = 0;
    set(handles.checkbox2,'Enable','off')
    set(handles.checkbox3,'Enable','off');
    guidata(hObject, handles);

function varargout = LEO_GUI_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;

function pushbutton2_Callback(hObject, eventdata, handles)
    [trt_fName,trt_fPth] = uigetfile('*.xls*','Please select the file holding test-retest data');
    if isequal(trt_fName,0) || isequal(trt_fPth,0),
        disp('Test-retest data must be entered to activate QuEST and Diagonal cov matrices')
    else
        handles.trtFile = [trt_fPth filesep trt_fName];
        handles.outPath = trt_fPth;
        set(handles.checkbox2,'Enable','on')
        set(handles.checkbox3,'Enable','on')
    end
    guidata(hObject,handles);


function pushbutton4_Callback(hObject, eventdata, handles)
    [bb_fName,bb_fPth] = uigetfile('*.xls*','Please select the file holding test-retest data');
    handles.bbFile = [bb_fPth filesep bb_fName];
    guidata(hObject,handles);

function checkbox2_Callback(hObject, eventdata, handles)
    handles.doQuEST = get(hObject,'Value');
    guidata(hObject,handles);

function checkbox3_Callback(hObject, eventdata, handles)
    handles.doDiag = get(hObject,'Value');
    guidata(hObject,handles);

function checkbox4_Callback(hObject, eventdata, handles)
    handles.doIdentity = get(hObject,'Value');
    guidata(hObject,handles);

function pushbutton5_Callback(hObject, eventdata, handles)
    [cov_fName,cov_fPth] = uigetfile('*.xls*','Please select your own cov matrix');
    handles.covFile = [cov_fPth filesep cov_fName];
    guidata(hObject,handles);

function edit3_Callback(hObject, eventdata, handles)
    handles.outputFileName = [handles.outPath filesep get(hObject,'String')];
    guidata(hObject,handles);

function pushbutton6_Callback(hObject, eventdata, handles)
    okToGo = 1;
    if ~isfield(handles,'bbFile') || isequal(handles.bbFile,0)
        disp('Please select baseline-block data before running LEO')
        okToGo = 0;
    end
    if isempty(handles.outputFileName)
        disp('Please specify output file name')
        okToGo = 0;
    end
    if ~any([handles.doQuEST handles.doDiag handles.doIdentity]) 
        disp('At least one covariance matrix method must be selected')
        okToGo = 0;
    end
    
    trtData = LEO_readFromExcel(handles.trtFile,'trt');
    bbData = LEO_readFromExcel(handles.bbFile,'bb');    
    if length(trtData(1).ROIs) ~= length(bbData(1).ROIs)
        disp('The number of ROIs in test-retest and baseline-block data are not equal, preventing LEO from running')
        okToGo = 0;
    end
    if ~isequal(bbData(1).ROIs,trtData(1).ROIs)
        reply = questdlg('The ROI names in test-retest and baseline-block datasets does not match. The same ROIs should be used. Do you want to continue anyway?', 'Warning');
        if strcmpi(reply,'Yes')
            okToGo = 1;
        else
            okToGo = 0;
        end
    end
    if okToGo
        LEO(trtData,bbData,handles.doQuEST,handles.doDiag,handles.doIdentity,handles.outputFileName)
        close(handles.figure1)
    end

function edit3_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pushbutton8_Callback(hObject, eventdata, handles)
    web('http://www.econ.uzh.ch/en/people/faculty/wolf/publications.html#9','-browser')

function pushbutton9_Callback(hObject, eventdata, handles)
    web('http://www.mathworks.com/matlabcentral/fileexchange/7601-cell2csv?focused=5063322&tab=function','-browser')
