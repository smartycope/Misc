#include "cope.h"

#define pulsePin1 YELLOW_LED
#define pulsePin2 GREEN_LED
#define idlePin RED_LED

#define print Serial.println

static bool pin1Status = LOW;
static bool pin2Status = HIGH;
static bool idlePinStatus = LOW;

void pulsePin1();
void pulsePin2();
void idle();