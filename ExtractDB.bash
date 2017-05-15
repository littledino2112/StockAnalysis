#!/bin/bash
sqlite3 StockDB.db .schema > schema.sql
sqlite3 -header -csv StockDB.db "select * from HOSE_STOCK_DIFF;" > hose_stock_diff_table.csv
sqlite3 -header -csv StockDB.db "select * from STOCK;" > hose_stock_table.csv
sqlite3 -header -csv StockDB.db "select * from HOSE_SELL_BUY_NATIONAL;" > hose_stock_sell_buy_national_table.csv
sqlite3 -header -csv StockDB.db "select * from HOSE_SELL_BUY_FOREIGNER;" > hose_stock_sell_buy_foreigner_table.csv


