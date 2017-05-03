function varargout = StockAnalysis(varargin)
% STOCKANALYSIS MATLAB code for StockAnalysis.fig
%      STOCKANALYSIS, by itself, creates a new STOCKANALYSIS or raises the existing
%      singleton*.
%
%      H = STOCKANALYSIS returns the handle to a new STOCKANALYSIS or the handle to
%      the existing singleton*.
%
%      STOCKANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STOCKANALYSIS.M with the given input arguments.
%
%      STOCKANALYSIS('Property','Value',...) creates a new STOCKANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StockAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StockAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StockAnalysis

% Last Modified by GUIDE v2.5 01-May-2017 21:18:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StockAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @StockAnalysis_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before StockAnalysis is made visible.
function StockAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StockAnalysis (see VARARGIN)

% Choose default command line output for StockAnalysis
handles.output = hObject;

% Application variables
handles.DatabaseConn = '';
handles.SelectedStock = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StockAnalysis wait for user response (see UIRESUME)
% uiwait(handles.MainFigure);


% --- Outputs from this function are returned to the command line.
function varargout = StockAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LoadDataButton.
function LoadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    path_to_database = '/Users/littledino2112/Documents/01_Work/04_Investment/01_StockAnalysis/01_App/StockDB.db';
    handles.DatabaseConn = database(path_to_database,'','','org.sqlite.JDBC',strcat('jdbc:sqlite:',path_to_database));
    db_conn = handles.DatabaseConn;
    if isempty(db_conn.Message)
        set(handles.LoadDataStatus,'String','Connected to Database');
        % Populate Stock Selection Dropdown list
        sql_query = 'SELECT DISTINCT SYMBOL FROM STOCK';
        data = fetch(db_conn, sql_query);
        set(handles.StockSelectionMenu,'String',data.SYMBOL);
    else
        set(handles.LoadDataStatus,'String','Error connect to Database');
    end
    guidata(hObject, handles);





% --- Executes on mouse press over figure background.
function MainFigure_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on MainFigure or any of its controls.
function MainFigure_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on MainFigure and none of its controls.
function MainFigure_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in StockSelectionMenu.
function StockSelectionMenu_Callback(hObject, eventdata, handles)
% hObject    handle to StockSelectionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns StockSelectionMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StockSelectionMenu
   [valid, selected_stock] = query_stock(handles);
    handles.SelectedStock = selected_stock;
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function StockSelectionMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StockSelectionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DurationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DurationEdit as text
%        str2double(get(hObject,'String')) returns contents of DurationEdit as a double
    [valid, selected_stock] = query_stock(handles);
    handles.SelectedStock = selected_stock;
    guidata(hObject, handles);

    
% --- Executes during object creation, after setting all properties.
function DurationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OBVChartButton.
function OBVChartButton_Callback(hObject, eventdata, handles)
    % hObject    handle to OBVChartButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if ~isempty(handles.SelectedStock)
        figure('Name','On Balance Volume');
        subplot(3,1,1);
        candle(handles.SelectedStock);
        subplot(3,1,2);   
        plot(onbalvol(handles.SelectedStock));
        % Plot volume in bar graph
        ax = subplot(3,1,3);
        data_extract = fts2mat(handles.SelectedStock.VOLUME,1);
        bar(data_extract(:,1),data_extract(:,2));
        ax.XTick = data_extract(:,1);
        datetick(ax,'x','d','keepticks');
    end


% --- Executes on button press in OverviewButton.
function OverviewButton_Callback(hObject, eventdata, handles)
% hObject    handle to OverviewButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CandleChartButton.
function CandleChartButton_Callback(hObject, eventdata, handles)
% hObject    handle to CandleChartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if ~isempty(handles.SelectedStock)
        figure('Name','Candle Chart');
        candle(handles.SelectedStock);
    end


% --- Executes on button press in CloseAllButton.
function CloseAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to CloseAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.MainFigure, 'HandleVisibility', 'off');
close all;
set(handles.MainFigure, 'HandleVisibility', 'on');


% --- Executes on button press in UpdateDBButton.
function UpdateDBButton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateDBButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[status, msg] = update_stock_db(handles.DatabaseConn);
set(handles.LoadDataStatus,'String',msg);