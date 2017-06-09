#!/bin/tcsh
# Remove non primary data files
rm -rf #* *~ `ls -1 | egrep -v '(\.v|\.csh|\.ucf|\.py|\.s|spartan|xc95)'`

foreach test ( fib mul32 udiv32 sqrt hello testpsr string)
    # Assemble the test
    python3 opc5lsasm.py ${test}.s ${test}.hex | tee ${test}.lst
    # Run the emulator
    python3 opc5lsemu.py ${test}.hex ${test}.dump | tee ${test}.trace
    # Test bench expects the hex file to be called 'test.hex'
    cp ${test}.hex test.hex
    # Run icarus verilog to compile the testbench
    iverilog -D_simulation=1 opc5lstb.v opc5lscpu.v
    # Execute the test bench
    ./a.out | tee ${test}.sim
    # Save the results
    mv dump.vcd ${test}.vcd
    mv test.vdump ${test}.vdump
end

echo ""
echo "Comparing memory dumps between emulation and simulation"
echo "-------------------------------------------------------"
foreach test ( fib mul32 udiv32 sqrt hello testpsr string)
    printf "%12s :" $test
    python3 ../utils/mdumpcheck.py ${test}.dump  ${test}.vdump
end
