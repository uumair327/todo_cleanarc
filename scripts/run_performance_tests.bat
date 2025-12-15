@echo off
REM Script to run performance benchmarking tests with profiling on Windows
REM Usage: scripts\run_performance_tests.bat

setlocal

echo ==========================================
echo Running Performance Benchmarking Tests
echo ==========================================

REM Get dependencies
echo Installing dependencies...
call flutter pub get

REM Run performance tests with driver for profiling
echo Running performance tests with profiling...
call flutter drive ^
  --driver=integration_test_driver/integration_test.dart ^
  --target=integration_test/performance_test.dart ^
  --profile

echo ==========================================
echo Performance tests completed!
echo Check output for benchmark results
echo ==========================================

endlocal
