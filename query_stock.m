function [ valid, selected_stock ] = query_stock( handles )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    stocklist = get(handles.StockSelectionMenu,'String');
    idx = get(handles.StockSelectionMenu,'Value');
    selectedStock = stocklist{idx};
    duration = get(handles.DurationEdit,'String');
    duration = str2double(duration);
    db_conn = handles.DatabaseConn;
    start_date = num2str(floor(now) - duration);
    sql_query = ['SELECT * FROM STOCK WHERE SYMBOL LIKE ''' selectedStock ''' AND DATE > ' start_date];
    symbol_data = fetch(db_conn, sql_query);
    if isempty(symbol_data)
        valid = false;
        % Pop up error message here
        set(handles.StockLoadStatus,'String','No data available');
        selected_stock = [];
    else
        valid = true;
        selected_stock = fints(symbol_data.DATE, [symbol_data.OPEN symbol_data.HIGH symbol_data.LOW symbol_data.CLOSE symbol_data.VOLUME],...
                        {'OPEN', 'HIGH', 'LOW', 'CLOSE', 'VOLUME'});
        set(handles.StockLoadStatus,'String','Data loaded');
    end

end

