function [ dates, results ] = compute_market_trend( db_conn, duration )
%   UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    load config.mat
    debug = 1;
    sql_query = ['SELECT MAX(DATE) FROM ' table_names.HOSE_STOCK_DIFF ];
    data = fetch(db_conn, sql_query);
    last_date = data.MAX_DATE_;
    dates = last_date-duration+1:last_date;
    results = zeros(1,length(dates));
    temp_result = 0;
    idx = 1;
    for elm = dates
        sql_query = ['SELECT COUNT(SYMBOL) AS ADVANCES FROM ' table_names.HOSE_STOCK_DIFF ' '...
                     'WHERE CLOSE_DIFF > 0 AND ' ...
                     'DATE = ' num2str(elm) ' AND '...
                     'SYMBOL NOT IN (''VNXALL'',''FUCVREIT'',''VNINDEX'',''HNX-INDEX'')'];
        data = fetch(db_conn, sql_query);
        advances = data.ADVANCES;
        sql_query = ['SELECT COUNT(SYMBOL) AS DECLINES FROM ' table_names.HOSE_STOCK_DIFF ' '...
                     'WHERE CLOSE_DIFF < 0 AND ' ...
                     'DATE = ' num2str(elm) ' AND '...
                     'SYMBOL NOT IN (''VNXALL'',''FUCVREIT'',''VNINDEX'',''HNX-INDEX'')'];
        data = fetch(db_conn, sql_query);        
        declines = data.DECLINES;
        temp_result = (advances - declines) + temp_result;
        results(idx) = temp_result;
        idx = idx + 1;
    end
end
