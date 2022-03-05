// The code provided was stupid, so I rewrote it all. (I also rewrote it before I
//  finished reading the instructions and realized it had it all there, so whatever)

#include "Energia.h"

// I don't want to make cope.c into an arduino library at the moment.
#define OUT  OUTPUT
#define IN   INPUT
#define true  1
#define false 0
//#define print Serial.println
#define nullptr NULL
#define null nullptr
#define byte unsigned char
//#define bool byte

#define MAX_TASKS 8
#define pin1 YELLOW_LED
#define pin2 GREEN_LED
#define idlePin RED_LED

void print(String s){
//  Serial.println(s);
//  for(auto i: s)
  for(int i=0; s[i]; ++i)
    Serial.write(s[i]);
   Serial.write('\n');
}

// Types
// task_cb is a stupid name.
typedef void (*Function)();

typedef struct{
    // How often we want to run
    int period;
    // Time since we last ran
    int lastRan;
    // Where to go back to when we're done
    Function callback;
    bool running;
    // Not implemented
    int priority;
}Task;

// Globals
static Task idleTask;
Task initTask(int period, Function callback);
Task tasks[MAX_TASKS];
volatile static int lastRan = 0;
volatile static int numTasks = 0;
static bool pin1Status = LOW;
static bool pin2Status = HIGH;
static bool idlePinStatus = LOW;

// Prototypes
void pulsePin1();
void pulsePin2();
void idle();
void initScheduler(Task _idleTask);
void addSchedulerTask(Task task);
void runScheduler();

// Functions
Task initTask(int period, Function callback){//, int priority){
    Task task;
    task.period = period;
    task.callback = callback;
    // task.priority = priority;
    task.running = false;
    task.lastRan = 0;
    return task;
}

void initScheduler(Task _idleTask){
    print("started scheduler");
    lastRan = millis();
    idleTask = _idleTask;
}

void addSchedulerTask(Task task){
    if (numTasks < MAX_TASKS){
        // Initialize the task to start
        task.lastRan = 0;
        task.running = true;
        tasks[numTasks] = task;
        ++numTasks;
    }
}

void runScheduler(){
    print("scheduler running");
    int now = millis();
    int runtime = now - lastRan;
    lastRan = now;
    Function taskFunc = nullptr;
    // Iterate through all the tasks and get the one that needs to be run the most
    int mostNeededAmt = 0;
    for(int i=0; i<numTasks; ++i){
        if (tasks[i].running){
            int needed = tasks[i].lastRan - tasks[i].period;
            if (needed > mostNeededAmt){
                mostNeededAmt = needed;
                taskFunc = tasks[i].callback;
            }
        }
    }
    if (mostNeededAmt < 0){
        if (idleTask.running)
            idleTask.callback();
        else
            return; // I would sleep, and there's probably a sleep function, but I don't want to debug that right now
    }
    else
        taskFunc();
}

void pulsePin1(){
    print("Pin 1 task running");
    pin1Status = !pin1Status;
    digitalWrite(pin1, pin1Status);
}

void pulsePin2(){
    print("Pin 2 task running");
    pin2Status = !pin2Status;
    digitalWrite(pin2, pin2Status);
}

void idle(){
    print("Idling");
    idlePinStatus = !idlePinStatus;
    digitalWrite(idlePin, idlePinStatus);
}

void setup(){
    pinMode(pin1, OUT);
    pinMode(pin2, OUT);
    pinMode(idlePin, OUT);
    Serial.begin(115200);
//    Serial.begin(9600);
//    Serial.println("testing serial");
    Serial.print("1 test");
    Serial.println("2 test");
//    Serial.printf("3 test");
    print("4 test");
    print("5 test");
//    print("test serial");
    initScheduler(initTask(0, idle));
    addSchedulerTask(initTask(1000, pulsePin1));
    addSchedulerTask(initTask(1500, pulsePin2));
}

void loop(){
    runScheduler();
}
