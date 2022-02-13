#include "scheduler.h"
#include "tasks.h"

#define OUT OUTPUT
#define IN   INPUT
// void main(){}

void setup(){
    pinMode(pulsePin1, OUT);
    pinMode(pulsePin2, OUT);
    pinMode(idlePin,   OUT);
    Serial.begin(115200);
    initScheduler(initTask(0, idle));
    addSchedulerTask(initTask(1000, pulsePin1));
    addSchedulerTask(initTask(1500, pulsePin2));
}

void loop(){
    runScheduler();
}