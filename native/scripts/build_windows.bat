@echo off
REM Build script for Windows

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set NATIVE_DIR=%SCRIPT_DIR%..
set BUILD_DIR=%NATIVE_DIR%\build\windows
set OUTPUT_DIR=%NATIVE_DIR%\..\windows\libs

set USE_CUDA=OFF
set USE_VULKAN=OFF

:parse_args
if "%1"=="" goto done_args
if "%1"=="--cuda" (
    set USE_CUDA=ON
    shift
    goto parse_args
)
if "%1"=="--vulkan" (
    set USE_VULKAN=ON
    shift
    goto parse_args
)
shift
goto parse_args
:done_args

echo Building DartLLM for Windows...
echo CUDA: %USE_CUDA%
echo Vulkan: %USE_VULKAN%

REM Check for llama.cpp
if not exist "%NATIVE_DIR%\llama.cpp" (
    echo Error: llama.cpp not found. Please run:
    echo   cd %NATIVE_DIR% ^&^& git submodule update --init --recursive
    exit /b 1
)

REM Create build directory
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd "%BUILD_DIR%"

REM Configure with CMake
cmake "%NATIVE_DIR%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DDARTLLM_BUILD_SHARED=ON ^
    -DDARTLLM_CUDA=%USE_CUDA% ^
    -DDARTLLM_VULKAN=%USE_VULKAN%

if errorlevel 1 (
    echo CMake configuration failed
    exit /b 1
)

REM Build
cmake --build . --config Release --parallel

if errorlevel 1 (
    echo Build failed
    exit /b 1
)

REM Create output directory
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Copy DLL
if exist "%BUILD_DIR%\Release\llamacpp.dll" (
    copy "%BUILD_DIR%\Release\llamacpp.dll" "%OUTPUT_DIR%\"
    echo DLL copied to: %OUTPUT_DIR%\
) else if exist "%BUILD_DIR%\llamacpp.dll" (
    copy "%BUILD_DIR%\llamacpp.dll" "%OUTPUT_DIR%\"
    echo DLL copied to: %OUTPUT_DIR%\
) else (
    echo Error: DLL not found
    exit /b 1
)

echo Windows build complete!
