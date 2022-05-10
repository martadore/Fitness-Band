#include <SparkFun_Bio_Sensor_Hub_Library.h>
#include <Wire.h>

// Reset pin, MFIO pin
int resPin = 4;
int mfioPin = 5;
int buzzer = 12;
int counter = 0;
bool beepFlag = true;

// Takes address, reset pin, and MFIO pin.
SparkFun_Bio_Sensor_Hub bioHub(resPin, mfioPin); 

bioData body; 

void setup(){

  Serial.begin(115200);

  Wire.begin();
  int result = bioHub.begin();
  int error = bioHub.configBpm(MODE_ONE); // Configuring just the BPM settings. 
  delay(4000); 
}

void loop(){  
    body = bioHub.readBpm();

    if(body.heartRate > 110) {
      if(beepFlag) {
        tone(buzzer, 850, 1000);
        delay(500);
        noTone(buzzer);
        delay(200);
        
        tone(buzzer, 850, 1000);
        delay(500);
        noTone(buzzer);
        delay(200);
        beepFlag = false;
      }
    }
    if(body.heartRate < 111 && body.heartRate > 30) {
      beepFlag = true;
    }

    //Serial.print("Heartrate: ");
    Serial.print(body.heartRate);
    Serial.print(",");
    //Serial.print("Confidence: ");
    Serial.print(body.confidence); 
    Serial.print(",");
    //Serial.print("Oxygen: ");
    Serial.print(body.oxygen); 
    Serial.print(",\n");
    delay(500); 
}
