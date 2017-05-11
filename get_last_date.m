function last_date = get_last_date( db_conn, table_name )
%  This function returns last date available in input table  
sql_query = ['SELECT MAX(DATE) AS MAX_DATE FROM ' table_name];
last_date = fetch(db_conn, sql_query);
last_date = last_date.MAX_DATE;
end

