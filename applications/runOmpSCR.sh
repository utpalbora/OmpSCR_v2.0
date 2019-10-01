#/bin/bash
MEMCHECK=${MEMCHECK:-"/usr/bin/time"}
TIMEOUTCMD=${TIMEOUTCMD:-"timeout"}
TIMEOUTMIN=10
OUTPUT_DIR="results"
LOG_DIR="$OUTPUT_DIR/log"
EXEC_DIR="$OUTPUT_DIR/exec"
LOGFILE="$LOG_DIR/dataracecheck.log"
VALGRIND=${VALGRIND:-"valgrind"}
VALGRIND_COMPILE_C_FLAGS="-g -std=c99 -fopenmp"
VALGRIND_COMPILE_CPP_FLAGS="-g -fopenmp"
CLANG=${CLANG:-"clang"}
TSAN_COMPILE_FLAGS="-fopenmp -fopenmp-version=45 -fsanitize=thread -g"
INSPECTOR=${INSPECTOR:-"inspxe-cl"}
ICC_COMPILE_FLAGS="-O0 -fopenmp -std=c99 -qopenmp-offload=host"
ICPC_COMPILE_FLAGS="-O0 -fopenmp -qopenmp-offload=host"
ARCHER=${ARCHER:-"clang-archer"}
ARCHER_COMPILE_FLAGS="-larcher -fopenmp-version=45"
SWORD=${SWORD:-"clang-sword"}
SWORD_ANALYSIS=${SWORD_ANALYSIS:-"sword-offline-analysis"}
SWORD_RACE_ANALYSIS=${SWORD_RACE_ANALYSIS:-"sword-race-analysis"}
SWORD_REPORT=${SWORD_REPORT:-"sword-print-report"}
SWORD_COMPILE_FLAGS="-fopenmp-version=45"
export SWORD_OPTIONS="traces_path=$LOG_DIR/sword_data"

mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR
mkdir -p $EXEC_DIR

#Set tool
tool=valgrind
MEMLOG="$LOG_DIR/$tool.memlog"

#foreach benchmark B;
#do
#for d in `find "$(pwd)" -type d -name "c_*"`;
#for d in `find "$(pwd)" -type d \( -name "c_L*" -o -name "c_M*" -o -name "c_P*" -o -name "c_Q*" -o -name "c_F*" \)`;
for d in `find "$(pwd)" -type d \( -name "c_L*" -o -name "c_M*" -o -name "c_P*" -o -name "c_Q*" \)`;
#for d in c_Pi;
do
  #echo $d;
  for test in `find $d -type f -name "*.c"`;
  do
    f=`basename $test .c`;
    echo $test;
    echo $f;

    logname="$f.$tool.log"
    exname="$EXEC_DIR/$f.$tool.out"
    additional_compile_flags=""
    INCLUDE_PATH="/home/utpal/Benchmarking/OmpSCR_v2.0/include"
    COMMON="/home/utpal/Benchmarking/OmpSCR_v2.0/common/ompscrCommon.c /home/utpal/Benchmarking/OmpSCR_v2.0/common/wtime.c"

    #Helgrind
    args="-test"
    #echo "Helgrind"
    #echo $VALGRIND_COMPILE_CPP_FLAGS $additional_compile_flags -I"$d" -I"$INCLUDE_PATH" $COMMON $test -o $exname -lm ;
    #gcc $VALGRIND_COMPILE_CPP_FLAGS $additional_compile_flags -I"$d" -I"$INCLUDE_PATH" $COMMON $test -o $exname -lm ;
    #races=$($MEMCHECK -f "%M" --quiet -o "$MEMLOG" $VALGRIND  --tool=helgrind "./$exname" $args 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'Possible data race') ;
    #echo "Races : " $races;

    #continue;

    #DRD
    #echo "DRD"
    #gcc $VALGRIND_COMPILE_CPP_FLAGS $additional_compile_flags -I"$d" -I"$INCLUDE_PATH" $COMMON $test -o $exname -lm ;
    #races=$($MEMCHECK -f "%M" --quiet -o "$MEMLOG" $VALGRIND  --tool=drd --check-stack-var=yes "./$exname" $args 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'Conflicting .* by thread') ;
    #echo "Races : " $races;

    #continue;


    #TSAN
    #echo "TSAN"
    #$CLANG $TSAN_COMPILE_FLAGS $additional_compile_flags -I"$d" -I"$INCLUDE_PATH" $COMMON $test -o $exname -lm ;
    #races=$($MEMCHECK -f "%M" --quiet -o "$MEMLOG" "./$exname" $args 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'WARNING: ThreadSanitizer: data race') ;
    #echo "Races : " $races;

    #Archer
    #echo "Archer"
    #clang-archer $ARCHER_COMPILE_FLAGS $additional_compile_flags -I"$d" -I"$INCLUDE_PATH" $COMMON $test -o $exname -lm ;
    #clang-archer++ $ARCHER_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;
    #races=$($MEMCHECK -f "%M" --quiet -o "$MEMLOG" "./$exname" $args 2>&1 | tee -a "$LOG_DIR/$logname" | grep -ce 'WARNING: ThreadSanitizer: data race') ;
    #echo "Races : " $races;

    #continue;

    #Inspector
    #echo "Inspector"
    #icc $ICC_COMPILE_FLAGS $additional_compile_flags -I"$d" -I"$INCLUDE_PATH" $COMMON $test -o $exname -lm ;
    #icpc $ICPC_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;
    #runtime_flags=''
    #runtime_flags+=" -collect ti3 -knob scope=extreme -knob stack-depth=16 -knob use-maximum-resources=true"
    #runtime_flags+=" -collect ti2"
    #$TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" --quiet -o "$MEMLOG" $INSPECTOR $runtime_flags -- "./$exname" $args &> $LOG_DIR/tmp.log;
    #check_return_code $?;
    #races=$(grep 'Data race' $LOG_DIR/tmp.log | sed -E 's/[[:space:]]*([[:digit:]]+).*/\1/');
    #cat $LOG_DIR/tmp.log >> "$LOG_DIR/$logname" || >$LOG_DIR/tmp.log ;
    #echo "Races : " $races;

    #continue;

    #SWORD
    echo "SWORD"
    clang-sword $SWORD_COMPILE_FLAGS $additional_compile_flags -I"$d" -I"$INCLUDE_PATH" $COMMON $test -o $exname -lm ;
    #clang-sword++ $SWORD_COMPILE_FLAGS $additional_compile_flags $test -o $exname -lm ;
    if [[ -e "$LOG_DIR/sword_data" ]]; then rm -rf "$LOG_DIR/sword_data"; fi;
    if [[ -e "$LOG_DIR/sword_report" ]]; then rm -rf "$LOG_DIR/sword_report"; fi;
      $TIMEOUTCMD $TIMEOUTMIN"m" $MEMCHECK -f "%M" --quiet -o "$MEMLOG" "./$exname" $args > /dev/null 2>&1;
      #check_return_code $?;
      $SWORD_ANALYSIS --analysis-tool $SWORD_RACE_ANALYSIS --executable $exname --traces-path "$LOG_DIR/sword_data" --report-path "$LOG_DIR/sword_report" > /dev/null 2>&1;
      $SWORD_REPORT --executable $exname --report-path "$LOG_DIR/sword_report" &> $LOG_DIR/tmp.log;
      races=$(grep -ce 'WARNING: SWORD: data race' $LOG_DIR/tmp.log);
      cat $LOG_DIR/tmp.log >> "$LOG_DIR/$logname" || >$LOG_DIR/tmp.log ;

      done
done
#done
