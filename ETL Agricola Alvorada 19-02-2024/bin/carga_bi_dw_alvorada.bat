@echo off
setlocal

REM :: Demétrio Santos - 08/02/2021

REM Valores aceitaveis sao: producao ou homologacao
set ENVIRONMENT_TIER=producao

REM Prefixo para aplicacao, como "crm_analit" ou "portal_produtor"
set APPLICATION=biagro

REM Nome do arquivo a ser executado dentro da pasta jobs
set JOB_FILE=job_carga_geral.kjb

set APP=C:\Vistra
set JAVA_HOME=%APP%\apps\java
set KETTLE_PATH=%APP%\apps\data-integration
set LOG_PATH=%APP%\logs\
set JRE_HOME=%JAVA_HOME%\jre
set PENTAHO_JAVA_HOME=%JAVA_HOME%

set KETTLE_HOME=%APP%\confs\%APPLICATION%_kettle_properties_%ENVIRONMENT_TIER%

set ETL_PATH=%APP%\ETL\%APPLICATION%_etl_%ENVIRONMENT_TIER%
set ETL_JOB_FILE=%ETL_PATH%\jobs\%JOB_FILE%

set LOG_PREFIX=carga_dw_alvorada
set LOG_FILE=%LOG_PATH%\%LOG_PREFIX%_%date:~-4,4%%date:~-7,2%%date:~-10,2%.log

set PENTAHO_DI_JAVA_OPTIONS=-Xms512m -Xmx2048m -XX:MaxPermSize=512m

echo "Executando kitchen..."
call "%KETTLE_PATH%\kitchen.bat" /file:"%ETL_JOB_FILE%" /norep  /logfile "%LOG_FILE%"