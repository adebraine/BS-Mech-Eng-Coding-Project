#include <Stepper.h>
#include <Encoder.h>
#include "I2Cdev.h"
#include <ResponsiveAnalogRead.h>

/* ------------------------------ */
// accelerometer

#define analogPin A11
ResponsiveAnalogRead analog(analogPin, true);
int acc = 0;
int bits = 12;

/* ------------------------------ */
// encoder

long maxencoderstep = 10000;
int count = 0;
long oldPosition  = 99999;
long oldPositionreset = oldPosition;
long newPosition = 0;
unsigned long start;
unsigned long start2;
int recordtime = 2000;
int maxencpos = 0;
int accrecpos1 = 650; // acc start record enc pos
int accrecpos2 = 650; // acc end record enc pos
Encoder myEnc(3, 4);

/* ------------------------------ */
// state variables

bool analogtype = true;
bool stopsign = true;
bool calibbool = true;
char Key = 'A';
bool failsafe = true;

/* ------------------------------ */
// motor

int startmotorposition = 29760; // 29760 = 133.92 degrees in motor steps
int startencstep = 3720; // 3720 = 133.92 degrees in encoder steps
int loadingmotorposition = 6666; // 6666 = 30 degrees in motor steps
int loadpos = 0;
int calibpos1 = 2222; // 2222 = 10 degrees in motor steps
int calibpos2 = 444; // 444 = 2 degrees in motor steps
int calibpos3 = 4; // 4 = 0.018 degrees in motor steps
int calibbutton = 1;
const int stepsPerRevolution = 200;  // change this to fit the number of steps per revolution
Stepper myStepper(stepsPerRevolution, 8, 9, 10, 11);

/* ------------------------------ */

void setup() {
  myStepper.setSpeed(300);
  pinMode(7, OUTPUT);
  pinMode(6, OUTPUT);
  Serial.begin(250000);
  while (!Serial);
}

void loop() {
  char customKey;
  if (Serial.available()) {
    customKey = Serial.read();
    if (customKey == 'B' && failsafe == true) {
      failsafe = false;
      loadingmotorposition = abs(loadingmotorposition);
      digitalWrite(6, LOW);
      digitalWrite(7, HIGH);
      while (myEnc.read() < startencstep) {
        myStepper.step(calibpos3);
        startmotorposition = myEnc.read() * 80000 / 10000;
      }
      count = 0;
      stopsign = true;
      oldPosition  = oldPositionreset;
      loadpos = 0;
      digitalWrite(7, LOW);
      digitalWrite(6, HIGH);
    }
    else if (customKey == 'C' && failsafe == false) {
      failsafe = true;
      myStepper.step(-startmotorposition);
      digitalWrite(6, LOW);
      digitalWrite(7, HIGH);
      myStepper.step(-calibpos2);
      myStepper.setSpeed(50);
      calibbool = true;
      count = 0;
      oldPosition  = oldPositionreset;
    }
    else if (customKey == 'R') {
      failsafe = true;
      myStepper.step(-startmotorposition);
      digitalWrite(6, LOW);
      digitalWrite(7, HIGH);
      myStepper.step(-calibpos2);
      myStepper.setSpeed(50);
      calibbool = true;
      count = 0;
      oldPosition  = oldPositionreset;
    }
    else if (customKey == 'D' && failsafe == true) {
      digitalWrite(6, LOW);
      digitalWrite(7, HIGH);
      if (loadingmotorposition < 0) {
        myStepper.step(loadingmotorposition);
        loadpos = 0;
        loadingmotorposition = -loadingmotorposition;
      }
      else if (loadingmotorposition > 0) {
        myStepper.step(loadingmotorposition);
        loadpos = loadingmotorposition;
        loadingmotorposition = -loadingmotorposition;
      }
    }
    else if (customKey == 'E') {
      failsafe = true;
      if (calibbutton > 0) {
        digitalWrite(6, LOW);
        digitalWrite(7, HIGH);
        myStepper.step(calibpos1);
        digitalWrite(6, HIGH);
        digitalWrite(7, LOW);
        delay(300);
        digitalWrite(6, LOW);
        calibbutton = - calibbutton;
      }
      else if (calibbutton < 0) {
        customKey = 'F';
        calibbool = true;
        calibbutton = - calibbutton;
      }
    }
    if (customKey == 'F') {
      digitalWrite(6, LOW);
      digitalWrite(7, HIGH);
      myStepper.step(-(calibpos1 + calibpos2));
      myStepper.setSpeed(50);
    }
    Key = customKey;
  }

  if (Key == 'A') {
    myEnc.write(0);
  }
  else if (Key == 'B') {
    newPosition = myEnc.read();
    if (count == 0) {
      start = millis();
      start2 = millis();
    }
    if (newPosition < oldPosition) {
      unsigned long now = millis();
      unsigned long elapsed = now - start;
      oldPosition = newPosition;
      Serial.print(elapsed);
      Serial.print("\t");
      Serial.println(newPosition);
      count = count + 1;
    }
    else if (millis() - start > recordtime && count != 0) {
      stopsign = false;
      Serial.println("reset");
      Serial.println("");
      count = 0;
    }
    if (newPosition < maxencpos * (-1) + accrecpos1 && newPosition > maxencpos * (-1) - accrecpos2 && stopsign == true) {
      if (analogtype == false) {
        analog.setAnalogResolution(4095);
        analog.update();
        acc = analog.getValue();
      }
      else {
        analogReadResolution(bits);
        acc = analogRead(analogPin);
      }
      unsigned long now2 = millis();
      unsigned long elapsed2 = now2 - start2;
      Serial.print("?");
      Serial.print("\t");
      Serial.print(elapsed2);
      Serial.print("\t");
      Serial.println(acc);
    }
    else if (newPosition < maxencpos * (-1) - accrecpos2) {
      stopsign = false;
    }
  }
  else if (Key == 'E') {
    myEnc.write(0);
  }
  else if (Key == 'F' && calibbool == true) {
    if (myEnc.read() > 0) {
      myStepper.step(-calibpos3);
    }
    else if (myEnc.read() < 0) {
      myStepper.step(calibpos3);
    }
    else {
      myStepper.setSpeed(300);
      calibbool = false;
    }
  }
  else if (Key == 'C' && calibbool == true) {
    if (myEnc.read() > 0) {
      myStepper.step(-calibpos3);
    }
    else if (myEnc.read() < 0) {
      myStepper.step(calibpos3);
    }
    else {
      myStepper.setSpeed(300);
      calibbool = false;
    }
  }
  else if (Key == 'R' && calibbool == true) {
    if (myEnc.read() > 0) {
      myStepper.step(-calibpos3);
    }
    else if (myEnc.read() < 0) {
      myStepper.step(calibpos3);
    }
    else {
      myStepper.setSpeed(300);
      calibbool = false;
    }
  }
//  Serial.println(myEnc.read());
}


