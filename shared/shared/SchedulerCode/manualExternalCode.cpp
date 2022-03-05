
// I don't want to make cope.c into an arduino library at the moment.
#define OUT  OUTPUT
#define IN   INPUT
#define true  1
#define false 0
// #define print Serial.println
#define print(string) printf(string "\n")
#define nullptr NULL
#define null nullptr
#define byte unsigned char
#define bool byte

#define HIGH 1
#define LOW  0

#define digitalWrite(pin, value) printf("Setting " #pin " to %d\n", value)

// #include <cope.h>
#define  debug(var) printf("%d: " #var " = %d\n", __LINE__, var);

#include <stdio.h>
#include <inttypes.h>
#include <time.h>
#include <errno.h>
int64_t millis(){
    struct timespec now;
    timespec_get(&now, TIME_UTC);
    return ((int64_t) now.tv_sec) * 1000 + ((int64_t) now.tv_nsec) / 1000000;
}

/* msleep(): Sleep for the requested number of milliseconds. */
int msleep(long msec){
    struct timespec ts;
    int res;

    if (msec < 0){
        errno = EINVAL;
        return -1;
    }

    ts.tv_sec = msec / 1000;
    ts.tv_nsec = (msec % 1000) * 1000000;

    do {
        res = nanosleep(&ts, &ts);
    } while (res && errno == EINTR);

    return res;
}

#define pinMode(ignored, params)


// Actual Code
#define MAX_TASKS 8
#define pin1 YELLOW_LED
#define pin2 GREEN_LED
#define idlePin RED_LED

typedef void (*Function)();
int pin1_status = LOW;
int pin2_status= HIGH;
int idlePin_status = LOW;
int lastRan;
int numTasks = 0;

// Initialise the scheduler.  This should be called once in the setup routine.
void Scheduler_Init();
// Function to add a task to the scheduling matrix
void Scheduler_StartTask(int period, Function task);
// when in a realationship always aks for ways to improve
// Function that will be run when no other functions are running.
void idleTask();

// Go through the task list and run any tasks that need to be run.
void Scheduler_Dispatch();

typedef struct{
    int period;
    int remaining_time;
    int running;
    Function callback;
}Task;

Task tasks[MAX_TASKS];

void Scheduler_Init(){
    lastRan = millis();
}

void Scheduler_StartTask(int period, Function task){
    if (numTasks < MAX_TASKS){
        tasks[numTasks].period = period;
        tasks[numTasks].remaining_time = 0;
        tasks[numTasks].running = 1;
        tasks[numTasks].callback = task;
        numTasks++;
    }
}

void Scheduler_Dispatch(){
    int now = millis();
    int runtime = now - lastRan;
    lastRan = now;
    Function taskFunc = nullptr;

    int taskIndex;
    for(int i=0; i<numTasks; i++){
        if (tasks[i].running){
            tasks[i].remaining_time -= runtime;
            if (tasks[i].remaining_time <= 0){
                taskFunc = tasks[i].callback;
                taskIndex = i;
            }
        }
    }
    if (taskFunc){
        taskFunc();
        tasks[taskIndex].remaining_time = tasks[taskIndex].period;
    }
    else
        idleTask();


    //         int needed = (tasks[i]. + tasks[i].period) - now;
    //         if (needed > mostNeededAmt){
    //             mostNeededAmt = needed;
    //             // taskIndex = i;
    //             taskFunc = tasks[i].callback;
    //         }
    //     }
    // }
    // if (mostNeededAmt < 0){
    //     if (idleTask.running)
    //         idleTask.callback();
    //     else
    //         return; // I would sleep, and there's probably a sleep function, but I don't want to debug that right now
    // }
    // else
    //     // tasks[i].callback();
    //    taskFunc();
    return;
}

// task function for PulsePin task
void pulse_pin1_task(){
    // print("Pin 1 task running");
    if(pin1_status == LOW){
        digitalWrite(pin1, HIGH);
        pin1_status = HIGH;
    }
    else{
        digitalWrite(pin1, LOW);
        pin1_status = LOW;
    }
}

// task function for PulsePin task
void pulse_pin2_task(){
    if(pin2_status == LOW){
        digitalWrite(pin2, HIGH);
        pin2_status = HIGH;
    }
    else{
        digitalWrite(pin2, LOW);
        pin2_status = LOW;
    }
}

// idle task
void idleTask(){
    // this function can perform some low-priority task while the
    // scheduler has nothing to do
    // It should return before the idle period (measured in ms) has
    // expired.  For example, it
    // could sleep or respond to I/O.
    // example idle function that just pulses a pin.
    if (idlePin_status == LOW){
        digitalWrite(idlePin, HIGH);
        idlePin_status = HIGH;
    }
    else{
        digitalWrite(idlePin, LOW);
        idlePin_status = LOW;
    }
}

void setup(){
    pinMode(pin1, OUTPUT);
    pinMode(pin2, OUTPUT);
    pinMode(idlePin, OUTPUT);

    // Serial.begin(115200);
    Scheduler_Init();
    // Serial.println("Scheduler started");
    // Start task arguments are:
    // start offset in ms, period in ms, function callback
    Scheduler_StartTask(1000, pulse_pin1_task);
    Scheduler_StartTask(1500, pulse_pin2_task);
}

void loop(){
    Scheduler_Dispatch();
}

int main(){
    setup();
    while (true){
        loop();
        msleep(250);
    }
    return 0;
}