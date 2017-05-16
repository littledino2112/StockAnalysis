function [ dates, results ] = compute_market_trend( db_conn, duration )
%   UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    load config.mat
    sql_query = ['SELECT MAX(DATE) FROM ' table_names.HOSE_STOCK_DIFF ];
    data = fetch(db_conn, sql_query);
    last_date = data.MAX_DATE_;
    start_date = last_date-duration+1;

    sql_query = ['SELECT DATE, COUNT(SYMBOL) AS ADVANCES FROM ' table_names.HOSE_STOCK_DIFF ' '...
                 'WHERE CLOSE_DIFF > 0 AND ' ...
                 'DATE >= ' num2str(start_date) ' AND '...
                 'SYMBOL NOT IN (''VNXALL'',''FUCVREIT'',''VNINDEX'',''HNX-INDEX'') '...
                 'GROUP BY DATE'];
    data = fetch(db_conn, sql_query);
    advances = data.ADVANCES;
    sql_query = ['SELECT DATE, COUNT(SYMBOL) AS DECLINES FROM ' table_names.HOSE_STOCK_DIFF ' '...
                 'WHERE CLOSE_DIFF < 0 AND ' ...
                 'DATE >= ' num2str(start_date) ' AND '...
                 'SYMBOL NOT IN (''VNXALL'',''FUCVREIT'',''VNINDEX'',''HNX-INDEX'') '...
                 'GROUP BY DATE'];
    data = fetch(db_conn, sql_query);        
    declines = data.DECLINES;
    results = advances - declines;
    results = cumsum(results);
    dates = data.DATE;
end 
