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
