#include "tasks.h"

void pulsePin1(){
    print("Pin 1 task running");
    pin1Status = !pin1Status;
    digitalWrite(pulsePin1, pin1Status);
}

void pulsePin2(){
    print("Pin 2 task running");
    pin2Status = !pin2Status;
    digitalWrite(pulsePin2, pin2Status);
}

void idle(){
    print("Idling");
    idlePinStatus = !idlePinStatus;
    digitalWrite(idlePin, idlePinStatus);
}
