@echo off


SETLOCAL
echo Cleaning Up Workspace
if exist work (
    rmdir /S /Q work 2> nul
)

if exist logs (
    rmdir /S /Q logs 2> nul
)

del /f /q *.ini
del /f /q transcript*
del /f /q *.wlf
del /f /q *.obj

mkdir logs


Rem Set the name of the testcase
rem set TEST_NAME=syn_base_test syn_tb_top
rem set TEST_NAME=syn_data_path_16b_mono_test
rem set TEST_NAME=syn_data_path_32b_mono_test
rem set TEST_NAME=syn_data_path_16b_dual_test
rem set TEST_NAME=syn_data_path_32b_dual_test
rem set TEST_NAME=syn_sine_16b_dual_10kHz
set TEST_NAME=syn_mem_acc_test
rem set TEST_NAME=syn_wav_parse_test


echo Creating msim Workspace
vlib work
vmap work work

echo Compiling files
vlog -f files.msim.list +define+SIMULATION -sv  -timescale "1ns / 10ps"

echo Starting Simulation
vsim -c -novopt -sv_lib syn_dpi_lib +OVM_TESTNAME=%TEST_NAME% syn_tb_top +define+SIMULATION -l transcript.txt -do "run -all"
goto :done


:exit_setup
    echo.
    echo Improper environment or Microsoft Visual Studio 9.0 not installed.
	echo Make sure you have Microsoft Visual Studio 9.0 Professional/Express edition installed with the necessary SDK's.
    echo.
    goto :done

:done
	set /p name= over & out
	ENDLOCAL
