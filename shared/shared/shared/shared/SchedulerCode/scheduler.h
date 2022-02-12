// #include "cope.h"

// Not sure about this
#define NUM_REGISTERS 64
#define MAX_TASKS 8
#define byte unsigned char

typedef struct{
    long int programCounter;
    void* stackPointer;
    byte registerStates[NUM_REGISTERS];
}Context;


typedef void (*Function)();
// typedef struct{
// }Function;


typedef struct{
    // How often we want to run
    int period;
    // Time since we last ran
    int lastRan;
    // Where to go back to when we're done
    Function callback;
    bool running;
    int priority;
}Task;

Task initTask(int period, Function callback, int priority);

void initScheduler();
void addSchedulerTask(Task);
void runScheduler();
