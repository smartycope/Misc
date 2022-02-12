typedef void (*task_cb)();
#define MAXTASKS 8
int pulse1_pin = YELLOW_LED;
int pulse2_pin = GREEN_LED;
int idle_pin = RED_LED;
int pin1_status = LOW;
int pin2_status= HIGH;
int idle_pin_status = LOW;
int last_runtime;
int num_tasks = 0;

/**
 * Initialise the scheduler.  This should be called once in the setup routine.
 */
void Scheduler_Init();

/* Function to add a task to the scheduling matrix */
void Scheduler_StartTask(int period, task_cb task);

/* Function that will be run when no other functions are running. */
void idle_process();

/**
 * Go through the task list and run any tasks that need to be run.
 */
void Scheduler_Dispatch();

typedef struct
{
	int period;
	int remaining_time;
	int is_running;
	task_cb callback;
} task_t;

task_t tasks[MAXTASKS];

void Scheduler_Init()
{
	last_runtime = millis();
}

void Scheduler_StartTask(int period, task_cb task)
{
	if (num_tasks < MAXTASKS)
	{
	    tasks[num_tasks].period = period;
	    tasks[num_tasks].remaining_time = 0;
		tasks[num_tasks].is_running = 1;
		tasks[num_tasks].callback = task;
		num_tasks++;
	}
}

void Scheduler_Dispatch()
{
int last_runtime;
int num_tasks = 0;


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


//  Your code goes here

  return;
}


// task function for PulsePin task
void pulse_pin1_task()
{
    Serial.println("Pin1 task");
      if(pin1_status == LOW)
      {
	  digitalWrite(pulse1_pin, HIGH);
          pin1_status = HIGH;
      }
      else
      {
	  digitalWrite(pulse1_pin, LOW);
          pin1_status = LOW;
      }
}

// task function for PulsePin task
void pulse_pin2_task()
{
    Serial.println("Pin2 task");
     if(pin2_status == LOW)
      {
	  digitalWrite(pulse2_pin, HIGH);
          pin2_status = HIGH;
      }
      else
      {
	  digitalWrite(pulse2_pin, LOW);
          pin2_status = LOW;
      }
}

// idle task
void idle_process()
{
	// this function can perform some low-priority task while the scheduler has nothing to do
	// It should return before the idle period (measured in ms) has expired.  For example, it
	// could sleep or respond to I/O.
	// example idle function that just pulses a pin.
    Serial.println("idle process");
    if (idle_pin_status == LOW)
    {
        digitalWrite(idle_pin, HIGH);
        idle_pin_status = HIGH;
    }
    else
    {
        digitalWrite(idle_pin, LOW);
        idle_pin_status = LOW;
    }
}

void setup()
{
    pinMode(pulse1_pin, OUTPUT);
    pinMode(pulse2_pin, OUTPUT);
    pinMode(idle_pin, OUTPUT);
    Serial.begin(115200);

    Scheduler_Init();
    Serial.println("Scheduler started");
	// Start task arguments are:
	//		start offset in ms, period in ms, function callback

    Scheduler_StartTask(1000, pulse_pin1_task);
    Scheduler_StartTask(1500, pulse_pin2_task);
}

void loop()
{
    Scheduler_Dispatch();
}
