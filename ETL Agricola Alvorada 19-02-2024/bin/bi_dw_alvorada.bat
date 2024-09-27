@echo off
setlocal

REM **************************************************
REM ** Set console window properties                **
REM **************************************************
REM TITLE My Spoon console

REM **************************************************
REM Script de chamada para o Pentaho Data Integration

REM Valores aceitaveis sao: producao ou homologacao
set ENVIRONMENT_TIER=producao

REM Prefixo para aplicacao, como "crm_analit" ou "portal_produtor"
set APPLICATION=biagro

set APP=C:\Vistra
set JAVA_HOME=%APP%\apps\java
set KETTLE_PATH=%APP%\apps\data-integration
set LOG_PATH=%APP%\logs\%APPLICATION%_%ENVIRONMENT_TIER%
set JRE_HOME=%JAVA_HOME%\jre
set PENTAHO_JAVA_HOME=%JAVA_HOME%

set KETTLE_HOME=%APP%\confs\%APPLICATION%_kettle_properties_%ENVIRONMENT_TIER%

set ETL_PATH=%APP%\ETL\%APPLICATION%_etl_%ENVIRONMENT_TIER%

set PENTAHO_DI_JAVA_OPTIONS=-Xms1024m -Xmx4096m -XX:MaxPermSize=1024m

call "%KETTLE_PATH%\Spoon.bat"
