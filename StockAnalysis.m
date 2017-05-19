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

% Last Modified by GUIDE v2.5 18-May-2017 22:03:07

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
load config.mat
handles.DatabaseConn = '';
handles.Database.TableNames = table_names;
handles.SelectedStock.TimeSeriesObj = [];
handles.SelectedStock.Name = '';
% Connect to database
path_to_database = path_to_db;
handles.DatabaseConn = database(path_to_database,'','','org.sqlite.JDBC',strcat('jdbc:sqlite:',path_to_database));
db_conn = handles.DatabaseConn;
if isempty(db_conn.Message)
    s = setdbprefs;
    s.DataReturnFormat = 'table';
    setdbprefs(s);
    set(handles.LoadDataStatus,'String','Connected to Database');
    % Populate Stock Selection Dropdown list
    sql_query = 'SELECT DISTINCT SYMBOL FROM STOCK';
    data = fetch(db_conn, sql_query);
    set(handles.StockSelectionMenu,'String',data.SYMBOL);
else
    set(handles.LoadDataStatus,'String','Error connect to Database');
end

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
% Get information from GUI
stocklist = handles.StockSelectionMenu.String;
idx = handles.StockSelectionMenu.Value;
stock_name = stocklist{idx};
duration = handles.DurationEdit.String;
duration = str2double(duration);
start_date = num2str(floor(now) - duration);

[msg, selected_stock] = query_stock(handles.DatabaseConn,handles.Database.TableNames.STOCK,stock_name,start_date);
selected_stock = fints(selected_stock.DATE, [selected_stock.OPEN selected_stock.HIGH selected_stock.LOW selected_stock.CLOSE selected_stock.VOLUME],...
                {'OPEN', 'HIGH', 'LOW', 'CLOSE', 'VOLUME'});
handles.SelectedStock.TimeSeriesObj = selected_stock;
handles.SelectedStock.Name = stock_name;
handles.StockLoadStatus.String = msg;
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
stocklist = handles.StockSelectionMenu.String;
idx = handles.StockSelectionMenu.Value;
stock_name = stocklist{idx};
duration = handles.DurationEdit.String;
duration = str2double(duration);
start_date = num2str(floor(now) - duration);

[msg, selected_stock] = query_stock(handles.DatabaseConn,handles.Database.TableNames.STOCK,stock_name,start_date);
selected_stock = fints(selected_stock.DATE, [selected_stock.OPEN selected_stock.HIGH selected_stock.LOW selected_stock.CLOSE selected_stock.VOLUME],...
                {'OPEN', 'HIGH', 'LOW', 'CLOSE', 'VOLUME'});
handles.SelectedStock.TimeSeriesObj = selected_stock;
handles.SelectedStock.Name = stock_name;
handles.StockLoadStatus.String = msg;
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
if ~isempty(handles.SelectedStock.TimeSeriesObj)
    figure('Name',['On Balance Volume - ' handles.SelectedStock.Name]);
    ax = subplot(3,1,1);
    plot_candle_chart(ax,handles.SelectedStock.TimeSeriesObj);
    ax = subplot(3,1,2);   
    obv = onbalvol(handles.SelectedStock.TimeSeriesObj);
    % Compute SMA5 and SMA20 for OBV
    hold on;
    plot(obv) 
    legend_desc = {'Raw data'};
    if (length(obv) >= 5)
        sma5 = tsmovavg(obv,'s',5);
        plot(sma5);
        legend_desc = [legend_desc,{'SMA5'}];
    end
    if (length(obv) >= 20)
        sma20 = tsmovavg(obv,'s',20);
        plot(sma20);
        legend_desc = [legend_desc,{'SMA20'}];
    end
    legend(legend_desc,'Location','northwest');
    hold off;
    title(ax,'On balance volume');
    
    % Plot volume in bar graph
    ax = subplot(3,1,3);
    data_extract = fts2mat(handles.SelectedStock.TimeSeriesObj.VOLUME,1);
    bar(data_extract(:,1),data_extract(:,2));
    ax.XTick = linspace(data_extract(1,1), data_extract(end,1) + 1,8);
    datetick(ax,'x','dd-mmm-yy','keepticks');
    title(ax,'Volume');
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
if ~isempty(handles.SelectedStock.TimeSeriesObj)
%     figure('Name',['Candle Chart - ' handles.SelectedStock.Name]);
%     candle(handles.SelectedStock.TimeSeriesObj);
    chartfts(handles.SelectedStock.TimeSeriesObj);
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


% --- Executes when MainFigure is resized.
function MainFigure_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function FilterPriceEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FilterPriceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilterPriceEdit as text
%        str2double(get(hObject,'String')) returns contents of FilterPriceEdit as a double


% --- Executes during object creation, after setting all properties.
function FilterPriceEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterPriceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FilterVolumeChangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FilterVolumeChangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilterVolumeChangeEdit as text
%        str2double(get(hObject,'String')) returns contents of FilterVolumeChangeEdit as a double


% --- Executes during object creation, after setting all properties.
function FilterVolumeChangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterVolumeChangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FilterPriceChangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FilterPriceChangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilterPriceChangeEdit as text
%        str2double(get(hObject,'String')) returns contents of FilterPriceChangeEdit as a double


% --- Executes during object creation, after setting all properties.
function FilterPriceChangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterPriceChangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FilterPriceCheck.
function FilterPriceCheck_Callback(hObject, eventdata, handles)
% hObject    handle to FilterPriceCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FilterPriceCheck


% --- Executes on button press in FilterVolumeChangeCheck.
function FilterVolumeChangeCheck_Callback(hObject, eventdata, handles)
% hObject    handle to FilterVolumeChangeCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FilterVolumeChangeCheck


% --- Executes on button press in FilterPriceChangeCheck.
function FilterPriceChangeCheck_Callback(hObject, eventdata, handles)
% hObject    handle to FilterPriceChangeCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FilterPriceChangeCheck


% --- Executes on button press in FilterButton.
function FilterButton_Callback(hObject, eventdata, handles)
% hObject    handle to FilterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Flows:
%   - Check which condition is checked
%   - 
date_start = handles.FilterDateRangeEdit.String;
date_start = get_last_date(handles.DatabaseConn, handles.Database.TableNames.HOSE_STOCK_DIFF) - str2double(date_start);
stock_diff_table = handles.Database.TableNames.HOSE_STOCK_DIFF;
stock_table = handles.Database.TableNames.STOCK;
condition_added = 0;
sql_query = ['SELECT ' stock_diff_table '.SYMBOL, SUM(CLOSE_DIFF_PERCENTAGE) AS SUM_PRICE_CHANGE, AVG(VOLUME) AS AVG_VOLUME, MAX(CLOSE) AS MAX_CLOSE, '...
             'MAX(VOLUME_DIFF_PERCENTAGE) AS MAX_VOLUME_DIFF '...
             'FROM ' stock_diff_table ' INNER JOIN ' stock_table ' '...
             'ON ' stock_table '.SYMBOL_DATE = ' stock_diff_table '.SYMBOL_DATE '...
             'WHERE ' stock_diff_table '.DATE > ' num2str(date_start) ' '...
             'GROUP BY ' stock_diff_table '.SYMBOL '];
if handles.FilterPriceCheck.Value
    price_close = handles.FilterPriceEdit.String;
    sql_query = [sql_query 'HAVING MAX_CLOSE >= ' price_close ' '];
    condition_added = condition_added + 1;
end
if handles.FilterVolumeChangeCheck.Value
    vol_change_in_percentage = handles.FilterVolumeChangeEdit.String;
    if (condition_added)
      sql_query = [sql_query 'AND '];
    else
      sql_query = [sql_query 'HAVING '];
    end
    sql_query = [sql_query 'MAX_VOLUME_DIFF > ' vol_change_in_percentage ' '];
end
if handles.FilterPriceChangeCheck.Value
    price_change_in_percentage = handles.FilterPriceChangeEdit.String;
    if (condition_added)
      sql_query = [sql_query 'AND '];
    else
      sql_query = [sql_query 'HAVING '];
    end
    sql_query = [sql_query 'SUM_PRICE_CHANGE >=' price_change_in_percentage ' '];
end
sql_query = [sql_query 'ORDER BY SUM_PRICE_CHANGE DESC'];
symbol_list = fetch(handles.DatabaseConn, sql_query);
if ~(isempty(symbol_list))
    symbol_list = table2cell(symbol_list);
    col_names = {'Symbol','Sum Price Change (%)','Average Volume','Max Close','Max Vol Change (%)'};
    handles.FilterStockTable.ColumnName = col_names;
    handles.FilterStockTable.Data = symbol_list; 
end  


function FilterDateRangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FilterDateRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FilterDateRangeEdit as text
%        str2double(get(hObject,'String')) returns contents of FilterDateRangeEdit as a double


% --- Executes during object creation, after setting all properties.
function FilterDateRangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterDateRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MarketTrendButton.
function MarketTrendButton_Callback(hObject, eventdata, handles)
% hObject    handle to MarketTrendButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
duration = handles.DurationEdit.String;
duration = str2double(duration);
[dates, results] = compute_market_trend(handles.DatabaseConn,duration);
% Compute simple moving average on 5-day basis
sma5 = tsmovavg(results,'s',5,1); % 1 indicates the input vector is column-oriented matrix where each row is an observation
sma20 = tsmovavg(results,'s',20,1);
figure('Name',['Market trend - ' handles.SelectedStock.Name]);
subplot(2,1,1);
if ~isempty(handles.SelectedStock.TimeSeriesObj)
    candle(handles.SelectedStock.TimeSeriesObj);
end
ax = subplot(2,1,2);
plot(ax,dates,results,dates,sma5,dates,sma20);
title('Cumulative Advance-Decline line');
ax.XTick = linspace(dates(1),dates(end)+1,4);
datetick(ax,'x','dd-mmm-yy','keepticks');
legend('Raw data','SMA5','SMA20');
xtickangle(ax,90);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected cell(s) is changed in FilterStockTable.
function FilterStockTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to FilterStockTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
selected_item = hObject.Data(eventdata.Indices(1),eventdata.Indices(2));
idx = find(strcmp(handles.StockSelectionMenu.String,selected_item));
if ~(isempty(idx))
   handles.StockSelectionMenu.Value = idx;
   StockSelectionMenu_Callback(handles.StockSelectionMenu, eventdata, handles); 
end


% --- Executes on button press in SupplyDemandAnalysisButton.
function SupplyDemandAnalysisButton_Callback(hObject, eventdata, handles)
% hObject    handle to SupplyDemandAnalysisButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% This callback queries sell and buy numbers from national and foreign
% investors and plots them together with candle chart
stock_symbol = handles.SelectedStock.Name;
duration = handles.DurationEdit.String;
date_start = get_last_date(handles.DatabaseConn, handles.Database.TableNames.HOSE_SELL_BUY_NATIONAL) - str2double(duration);
sb_national = handles.Database.TableNames.HOSE_SELL_BUY_NATIONAL;
sb_foreigner = handles.Database.TableNames.HOSE_SELL_BUY_FOREIGNER;
sql_query = ['SELECT ' sb_national '.DATE AS DATE, (' sb_national '.BUY - ' sb_national '.SELL) AS DIFF, ('...
             sb_foreigner '.BUY - ' sb_foreigner '.SELL) AS FOREIGN_DIFF FROM ' sb_national ' INNER JOIN '...
             sb_foreigner ' ON ' sb_national '.SYMBOL_DATE = ' sb_foreigner '.SYMBOL_DATE '...
            'WHERE ' sb_national '.DATE > ' num2str(date_start) ' AND ' sb_national '.SYMBOL = ''' stock_symbol ''''] ;
data = fetch(handles.DatabaseConn, sql_query);
ts_data = fints(data.DATE, [data.DIFF data.FOREIGN_DIFF], {'SDNational','SDForeign'});
ts_data_national = cumsum(ts_data.SDNational);
ts_data_foreign = cumsum(ts_data.SDForeign);
figure('Name',['Supply Demand - ' handles.SelectedStock.Name]);
ax = subplot(3,1,1);
plot_candle_chart(ax,handles.SelectedStock.TimeSeriesObj);
subplot(3,1,2);
title('Cumulative (Demand - Supply)');
yyaxis left;
plot(ts_data_national);
ylabel('Cumulative stocks');
yyaxis right;
plot(ts_data_foreign);
legend('National investors','Foreign investors','Location','northwest');
% Plot volume in bar graph
ax = subplot(3,1,3);
data_extract = fts2mat(handles.SelectedStock.TimeSeriesObj.VOLUME,1);
bar(data_extract(:,1),data_extract(:,2));
ax.XTick = linspace(data_extract(1,1), data_extract(end,1) + 1,8);
datetick(ax,'x','dd-mmm-yy','keepticks');


% --- Executes on button press in PopulateTableButton.
function PopulateTableButton_Callback(hObject, eventdata, handles)
% hObject    handle to PopulateTableButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stocklist = handles.StockSelectionMenu.String;
idx = handles.StockSelectionMenu.Value;
stock_name = stocklist{idx};
duration = handles.DurationEdit.String;
duration = str2double(duration);
start_date = num2str(floor(now) - duration);
stock_tb = handles.Database.TableNames.STOCK;
stock_diff_tb = handles.Database.TableNames.HOSE_STOCK_DIFF;
sql_query = ['SELECT ' stock_tb '.SYMBOL, ' stock_tb '.DATE, ' stock_tb '.OPEN, ' stock_tb '.CLOSE, ' stock_diff_tb '.CLOSE_DIFF_PERCENTAGE, '...
             stock_tb '.VOLUME FROM ' stock_tb ' INNER JOIN ' stock_diff_tb ' ON ' stock_tb '.SYMBOL_DATE = ' stock_diff_tb '.SYMBOL_DATE '...
             'WHERE ' stock_tb '.DATE > ' start_date ' AND ' stock_tb '.SYMBOL = ''' stock_name ''' '...
             'ORDER BY ' stock_tb '.DATE DESC'];
selected_stock = fetch(handles.DatabaseConn, sql_query);
if (~isempty(selected_stock))
    selected_stock.DATE = datestr(selected_stock.DATE);
    selected_stock = table2cell(selected_stock);
    col_names = {'Symbol','Date','Open','Close','Change (%)','Volume'};
    handles.StockDetailTable.ColumnName = col_names;
    handles.StockDetailTable.Data = selected_stock; 
end
