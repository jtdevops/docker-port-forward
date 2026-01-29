@echo off
setlocal ENABLEDELAYEDEXPANSION

set IMAGE=jtdev0ps/docker-port-forward

set USE_NET_HOST=0
set CONTAINER=
set CONTAINER_PORT=
set HOST_PORT=4000

REM --- Optional first arg: --net-host or -n ---
if "%1"=="--net-host" (
  set USE_NET_HOST=1
  shift
) else if "%1"=="-n" (
  set USE_NET_HOST=1
  shift
)

REM --- Require at least container and containerport ---
if "%1"=="" (
  echo Usage: docker-port-forward [--net-host ^| -n] ^<container^> ^<containerport^> [hostport]
  echo   --net-host, -n  Use host network ^(no port mapping^)
  echo   hostport defaults to 4000
  exit /b 1
)
set CONTAINER=%1
shift

if "%1"=="" (
  echo Usage: docker-port-forward [--net-host ^| -n] ^<container^> ^<containerport^> [hostport]
  exit /b 1
)
set CONTAINER_PORT=%1
shift

if not "%1"=="" (
  set HOST_PORT=%1
)

REM --- Pull image if missing ---
docker image inspect %IMAGE% >nul 2>&1
if errorlevel 1 (
  docker pull %IMAGE%
)

REM --- Build docker run ---
set DOCKER_RUN=docker run --rm -t -v /var/run/docker.sock:/var/run/docker.sock
if %USE_NET_HOST%==1 (
  set DOCKER_RUN=%DOCKER_RUN% --net host
) else (
  set DOCKER_RUN=%DOCKER_RUN% -p %HOST_PORT%:%HOST_PORT%
)
set DOCKER_RUN=%DOCKER_RUN% %IMAGE% %CONTAINER% %CONTAINER_PORT% %HOST_PORT%

echo ^> %DOCKER_RUN%
%DOCKER_RUN%

endlocal
