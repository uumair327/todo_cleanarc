@echo off
REM Script to run all integration tests on Windows
REM Usage: scripts\run_integration_tests.bat [platform]

setlocal

set PLATFORM=%1

echo ==========================================
echo Running Flutter Todo App Integration Tests
echo ==========================================

REM Get dependencies
echo Installing dependencies...
call flutter pub get

REM Run integration tests
if "%PLATFORM%"=="" (
  echo Running integration tests on default platform...
  call flutter test integration_test
) else (
  echo Running integration tests on %PLATFORM%...
  call flutter test integration_test --platform %PLATFORM%
)

echo ==========================================
echo Integration tests completed!
echo ==========================================

endlocal
