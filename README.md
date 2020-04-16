# OmpSCR v2.0 Benchmark suite

A benchmark suite for high performance computing using OpenMP v3.0 APIs.  
The benchmark consisting of C/C++ and FORTRAN kernels demonstrating  
usefulness and pitfalls of parallel programming paradigm with both correct  
and incorrect parallelization strategies.  
The kernels ranges from parallelization of simple loops with dependences  
to more complex parallelimplemantations of algorithms, such as  
Mandelbrot set generator, Molecular Dynamics simulation,Pi (π) calculation,  
LU decomposition, Jacobi solver, fast Fourier transforms (FFT), and Quicksort.  
The original benchmark suite can be found [here](https://sourceforge.net/projects/ompscr/files/OmpSCR/OmpSCR%20Full%20Distribution%20v2.0/)  
Author : A. J. Dorta, C. Rodriguez, and F. de Sande.  

The benchmark is updated to be compiled by a modern compiler.  
The benchmark can be used to compare different data race detection tools, such as  
LLOV, TSan-LLVM, TSan-gcc, Helgrind, Valdrind DRD, SWORD, and Archer.  
It can be easily updated to accomodate more checkers.  


## Dependency

We user runsolver to gracefully timeout and collect statistics.  
Runsolver can be found [here](https://github.com/utpalbora/runsolver.git).  


## Running Data Race Checkers

> 1.  User needs to set up race detection tools first.
> 2.  Create a config file in the directory config/templates/.
> 3.  If config already exists, update CC and CXX paths.
> 4.  To test, invoke testing script scripts/test-tools.sh with arguments.
> >   To run TSan-LLVM with 32 OpenMP threads, run as:-
> > `` ./scripts/test-tools.sh -x tsan-llvm -t 32  ``

```
./scripts/test-tools.sh -x toolname
-x : tool name (llov, archer sword, tsan-llvm, drd, helgrind)
-n : iteration count
-t : thread count
-s : timeout in seconds
```

To run llov 5 times, execute  
`./scripts/test-tools.sh -x llov -n 5`

To run multiple tools, execute  
`./scripts/test-tools.sh -x llov -x drd -x helgrind -n 1 -t 8 -s 10`

Results are stored at `OmpSCR_v2.0/log` directory.

## Contact
If you have any query, please contact "Utpal Bora" &lt;cs14mtech11017&gt;@iith.ac.in.  
Please you have modified the benchmark as per your need, kindly send a pull request.  

Regards,  
Utpal

