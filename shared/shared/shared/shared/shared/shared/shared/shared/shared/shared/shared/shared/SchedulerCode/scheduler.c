#include "scheduler.h"

volatile static int lastRan = 0;
volatile static int numTasks = 0;
Task tasks[MAX_TASKS];

Task initTask(int period, Function callback, int priority){
    Task task;
    task.period = period;
    task.callback = callback;
    task.priority = priority;
    task.running = false;
    task.lastRan = 0;
    return task;
}

void initScheduler(){
    print("started scheduler")
    lastRan = millis();
}

void addSchedulerTask(Task task){
    if (numTasks < MAX_TASKS){
        // Initialize the task to start
        task.lastRan = 0;
        taks.running = true;
        tasks[numTasks] = task;
        ++numTasks;
    }
}

void runScheduler(){
    int now = millis();
    int runtime = now - lastRan;
    lastRan = now;
    Function task = nullptr;
}
