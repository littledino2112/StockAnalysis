#!/bin/bash
sqlite3 StockDB.db .dump > data.sql
sqlite3 StockDB.db .schema > schema.sql

