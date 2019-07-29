#!/bin/bash
CPPFLAGS="$CPPFLAGS -fPIC" npm install --build-from-source sqlite3 ;
npm install numbro zero-fill mathjs convnetjs
