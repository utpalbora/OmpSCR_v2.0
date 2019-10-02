#!/bin/bash

#export KMP_AFFINITY="verbose"
#export OMP_DISPLAY_ENV="VERBOSE"
export OMP_DISPLAY_ENV=false
LOG_DIR=log
REPORT=${LOG_DIR}/OmpSCR.log

#TIMEOUTCMD=${TIMEOUTCMD:-"timeout"}
RUNCMD=${RUNCMD:-"/home/utpal/runsolver/src/runsolver"}

ARCHER=${ARCHER:-"clang-archer"}
SWORD=${SWORD:-"clang-sword"}
VALGRIND=${VALGRIND:-"valgrind"}
INSPECTOR=${INSPECTOR:-"inspxe-cl"}
LLOV_COMPILER="/home/utpal/LLVMOmpVerify/build"

export ARCHER_ROOT="/home/utpal/RaceDetectionTools"
export PATH="$ARCHER_ROOT/installs/bin:$PATH"
export LD_LIBRARY_PATH="$ARCHER_ROOT/installs/lib:$LD_LIBRARY_PATH"

SWORD_ANALYSIS=${SWORD_ANALYSIS:-"sword-offline-analysis"}
SWORD_RACE_ANALYSIS=${SWORD_RACE_ANALYSIS:-"sword-race-analysis"}
SWORD_REPORT=${SWORD_REPORT:-"sword-print-report"}
export SWORD_ROOT="/home/utpal/RaceDetectionTools"
export SWORD_OPTIONS="traces_path=$LOG_DIR/sword_data"
export PATH="$SWORD_ROOT/installs/bin:$PATH"
export LD_LIBRARY_PATH="$SWORD_ROOT/installs/lib:$LD_LIBRARY_PATH"

export ROMP_ROOT="/home/utpal/RaceDetectionTools/ROMP/romp"
export CPATH="$ROMP_ROOT/pkgs-src/llvm-openmp/openmp/llvm-openmp-install/include:$CPATH"
export LD_LIBRARY_PATH="$ROMP_ROOT/pkgs-src/llvm-openmp/openmp/llvm-openmp-install/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$ROMP_ROOT/pkgs-src/gperftools/gperftools-install/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$ROMP_ROOT/pkgs-src/dyninst/dyninst-install/lib:$LD_LIBRARY_PATH"
export DYNINST_ROOT="$ROMP_ROOT/pkgs-src/dyninst/dyninst-install"
ROMP_LIB="$ROMP_ROOT/pkgs-src/romp-lib/romp-install/lib"
OMP_LIB="$ROMP_ROOT/pkgs-src/llvm-openmp/openmp/llvm-openmp-install/lib"
GPERFTOOLS_LIB="$ROMP_ROOT/pkgs-src/gperftools/gperftools-install/lib"
export ROMP_PATH="$ROMP_LIB/libomptrace.so"
export DYNINST_CLIENT="$ROMP_ROOT/pkgs-src/dyninst-client/omp_race_client"
export DYNINSTAPI_RT_LIB="$DYNINST_ROOT/lib/libdyninstAPI_RT.so"


validate_tool_path () {
  case "$1" in
    gnu) if [[ `which gcc` ]]; then return 0; else return 1; fi;;
    clang) if [[ `which clang` ]]; then return 0; else return 1; fi;;
    intel) if [[ `which icc` ]]; then return 0; else return 1; fi;;
    helgrind) if [[ `which $VALGRIND` ]]; then return 0; else return 1; fi;;
    drd) if [[ `which $VALGRIND` ]]; then return 0; else return 1; fi;;
    archer) if [[ `which $ARCHER` ]]; then return 0; else return 1; fi;;
    sword) if [[ `which $SWORD` ]] && [[ `which $SWORD_ANALYSIS` ]] && [[ `which $SWORD_REPORT` ]] && [[ `which $SWORD_RACE_ANALYSIS` ]]; then return 0; else return 1; fi;;
    llov) if [[ -f $LLOV_COMPILER/lib/OpenMPVerify.so ]]; then return 0; else return 1; fi;;
    tsan-llvm) if [[ `which clang` ]]; then return 0; else return 1; fi;;
    tsan-gcc) if [[ `which clang` ]]; then return 0; else return 1; fi;;
    inspxe-cl) if [[ `which $INSPECTOR` ]]; then return 0; else return 1; fi;;
    romp) if [[ -f $ROMP_PATH ]] && [[ -f $DYNINST_CLIENT ]] && [[ -f $DYNINSTAPI_RT_LIB ]]; then return 0; else return 1; fi;;
    *) return 1 ;;
  esac
}

TOOLS=()
ITERATIONS=()
TIMEOUTMIN=()
while getopts "n:x:s:" opt; do
  case $opt in
    x)  if validate_tool_path "${OPTARG}"; then
          TOOLS+=(${OPTARG});
        else echo "Invalid tool name ${OPTARG}" && exit 1;
        fi ;;
    n)  if [[ ${OPTARG} -gt 0 ]]; then
          ITERATIONS=${OPTARG};
        else echo "Number of iterations must be greater than 0";
        fi ;;
    s)  if [[ ${OPTARG} -gt 0 ]]; then
          TIMEOUTMIN=(${OPTARG})
        else echo "timeout must be greater than 0" && exit 1;
        fi ;;
  esac
done

if [[ ! ${#TOOLS[@]} -gt 0 ]]; then
  #TOOLS=( 'archer' 'clang' 'drd' 'gnu' 'helgrind' 'intel' 'inspxe-cl' 'llov' 'romp' 'sword' 'tsan-llvm' 'tsan-gcc')
  TOOLS=( 'archer' 'drd' 'helgrind' 'llov' 'sword' 'tsan-llvm' 'tsan-gcc')
fi
if [[ ! $ITERATIONS -gt 0 ]]; then
  ITERATIONS=10
fi
TIMEOUTSEC=$((TIMEOUTMIN*60))
RUNFLAGS=" -C ${TIMEOUTSEC}00 -W ${TIMEOUTSEC} --phys-cores 0-71 "
TESTPARAM="-test"
# Increase stack size
ULIMITS=$(ulimit -s)
ulimit -s unlimited

#for tool in "archer" "clang" "drd" "gnu" "helgrind" "intel" "inspxe-cl" "llov" "romp" "sword" "tsan-llvm" "tsan-gcc"; do
#for tool in "archer" "drd" "helgrind" "llov" "sword" "tsan-llvm" "tsan-gcc"; do
for tool in "${TOOLS[@]}"; do
  LOGFILE=$LOG_DIR/${tool}.csv

  if [ ! -f config/templates/${tool}.cf.mk ]; then
    echo "Config file not found for $tool. Please create config as config/templates/$tool.cf.mk";
    exit 1;
  fi
  cp config/templates/${tool}.cf.mk config/templates/user.cf.mk;
  make clean;

  echo "tool,testcase,races,runtime,memory(rss),exitcode" > "$LOGFILE"

  timerStart=$(date +%s%6N)
  make par;
  for exname in $(find bin -type f -name "*${tool}"); do
    testname=${exname##*/}
    runlog="$LOG_DIR/${testname}"
    testname=${testname%%.*}
    logname="${runlog}.log"
    OUTFLAGS=" -w ${runlog}.watch.log -v ${runlog}.var.log -o $logname "

    echo "Running $tool on $testname with arguments $TESTPARAM";
    case $tool in
      clang)
        ;&
      gnu)
        ;&
      intel)
        $RUNCMD $RUNFLAGS $OUTFLAGS "./$exname" $TESTPARAM;
        races="";;
      archer)
        $RUNCMD $RUNFLAGS $OUTFLAGS "./$exname" $TESTPARAM;
        races=$(grep -ce 'WARNING: ThreadSanitizer: data race' $logname);;
      drd)
        $RUNCMD $RUNFLAGS $OUTFLAGS $VALGRIND --tool=drd --check-stack-var=yes "./$exname" $TESTPARAM;
        races=$(grep -ce 'Conflicting .* by thread' $logname);;
      inspxe-cl)
        runtime_flags=" -collect ti3 -knob scope=extreme -knob stack-depth=16 -knob use-maximum-resources=true";
        #runtime_flags=" -collect ti2";
        $RUNCMD $RUNFLAGS $OUTFLAGS $INSPECTOR $runtime_flags -- "./$exname" $TESTPARAM;
        races=$(grep 'Data race' $logname | sed -E 's/[[:space:]]*([[:digit:]]+).*/\1/');;
      helgrind)
        $RUNCMD $RUNFLAGS $OUTFLAGS $VALGRIND --tool=helgrind "./$exname" $TESTPARAM;
        races=$(grep -ce 'Possible data race' $logname);;
      llov)
        races=$(grep -ce 'Data Race detected' $logname);;
      romp)
        $RUNCMD $RUNFLAGS $OUTFLAGS "./$exname" $TESTPARAM;
        races=$(grep -ce 'race found!' $logname);;
      sword)
        if [[ -e "$LOG_DIR/sword_data" ]]; then
          rm -rf "$LOG_DIR/sword_data";
        fi;
        if [[ -e "$LOG_DIR/sword_report" ]]; then
          rm -rf "$LOG_DIR/sword_report";
        fi;
        $RUNCMD $RUNFLAGS $OUTFLAGS "./$exname" $TESTPARAM
        instrtime=$(grep "Real time" ${runlog}.watch.log | awk -F: '{ print $2 }')
        $RUNCMD $RUNFLAGS $OUTFLAGS $SWORD_ANALYSIS --analysis-tool $SWORD_RACE_ANALYSIS --executable $exname --traces-path "$LOG_DIR/sword_data" --report-path "$LOG_DIR/sword_report"
        analysistime=$(grep "Real time" ${runlog}.watch.log | awk -F: '{ print $2 }')
        $RUNCMD $RUNFLAGS $OUTFLAGS $SWORD_REPORT --executable $exname --report-path "$LOG_DIR/sword_report"
        races=$(grep -ce 'WARNING: SWORD: data race' $logname);;
      tsan-gcc)
        ;&
      tsan-llvm)
        $RUNCMD $RUNFLAGS $OUTFLAGS "./$exname" $TESTPARAM;
        races=$(grep -ce 'WARNING: ThreadSanitizer: data race' $logname);;
    esac
    mem=$(grep "maximum resident set size" ${runlog}.watch.log | sed -E 's/.*[[:space:]]([[:digit:]]+)/\1/')
    runtime=$(grep "Real time" ${runlog}.watch.log | awk -F: '{ print $2 }')
    runtime=$(echo "scale=3; ($runtime+${instrtime:-0}+${analysistime:-0})"|bc)
    if [ ! -f ${runlog}.var.log ]; then
      returncode=0;
    elif [ $(grep -ce "^TIMEOUT=true" ${runlog}.var.log) -eq 0 ]; then
      returncode=$(grep "Child status" ${runlog}.watch.log | awk -F: '{ print $2 }');
    else
      returncode=124;
    fi
    echo "$tool,$testname,${races:-0},$runtime,$mem,$returncode" >> "$LOGFILE"

  done
  timerEnd=$(date +%s%6N);
  totalTime=$(echo "scale=3; ($timerEnd-$timerStart)/1000000"|bc);
  echo "time take by $tool is $totalTime seconds" | tee -a $REPORT

  make clean;
done

ulimit -s "$ULIMITS"
