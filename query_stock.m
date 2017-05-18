function [ msg, selected_stock] = query_stock(db_conn, table_name, stock_name, start_date )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    sql_query = ['SELECT * FROM ' table_name ' WHERE SYMBOL = ''' stock_name ''' AND DATE > ' start_date];
    selected_stock = fetch(db_conn, sql_query);
    if isempty(selected_stock)
        % Pop up error message here
        selected_stock = [];
        msg = 'No Data available';
    else
        msg = 'Data loaded';
    end

end

