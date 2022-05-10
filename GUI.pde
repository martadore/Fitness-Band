import grafica.*;

import processing.serial.*;
import java.util.*;

GPlot plot;

int step = 0;
int stepsPerCycle = 100;
int lastStepTime = 0;
int age = 20;
boolean clockwise = true;
float scale = 5;
int prevBeat = 0;
float instHRT = 0.00;
int maxHR = 220-age;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port

//call split on a string thatll make an array 
Vector<Integer> HRst = new Vector<Integer>();
Vector<Integer> confidenceArr = new Vector<Integer>();
Vector<Integer> oxygenArr = new Vector<Integer>();

GPointsArray points = new GPointsArray(2000);
color[] pointColors = new color[2000];
void setup()
{
  size(800, 800);
  background(255, 255, 255);//background white
 
  fill(0); //text black
  textFont(createFont("calibri", 35));
  text("Heartrate: ", 70, 190);
  
  textSize(30);
  text("Time between each beat: ", 420, 80);
  text("Blood oxygen level: ", 465, 110);
  
  textSize(25);
  text("First name: ", 20, 40);
  text("Last name: ", 20, 64);
  text("Age: ", 20, 88);
  textSize(20);
  text("Group", 150, 40);
  text("five", 150, 64);
  text(age, 150, 88);
  text(maxHR, 230, 130);
  text("bpm/min", 270, 130);
  text("Confidence: ", 118, 215);
  
  fill(130,0, 64);
  textSize(25);
  text("Maximum HR: ", 70, 130);
    
  PImage heart = loadImage("heart.png");
  image(heart, 15, 155, 50, 50);  //xpos, ypos, width, height
  PImage maximum = loadImage("maximum.png");
  image(maximum, 22, 105, 35, 35);  //xpos, ypos, width, heigh
  PImage cardiozone = loadImage("cardiozone.png");
  image(cardiozone, 52, 220, 55, 55);  //xpos, ypos, width, heig
  PImage colorbar = loadImage("colorbar.png");
  image(colorbar, 27, 270, 100, 495);  //xpos, ypos, width, height

  lastStepTime = millis();

  // Create the plot
  plot = new GPlot(this);
  plot.setPos(120, 230);
  plot.setDim(480, 480);
  // or all in one go
  // plot = new GPlot(this, 25, 25, 300, 300);

  // Set the plot limits (this will fix them)
  plot.setXLim(0, 150);
  plot.setYLim(50, 200);
  plot.getTitle().setText("Heart rate chart");
  plot.getYAxis().getAxisLabel().setText("HeartRate");

  // Activate the panning effect
  plot.activatePanning();
  
  String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 115200);
}


int count = 0;
int xvar = -5;
int sum = 0;
float baseline = 0.00;
int valHR = 0;

void draw()
{
    //background(150);
    if (myPort.available() > 0) {
      val = myPort.readStringUntil('\n');
      print(val);
       if (millis() - lastStepTime > 1000) {
          if (val != null) {
            String[] arrOfStr = val.split(",");
            int temp = Integer.parseInt(arrOfStr[0]);
            int confidence = Integer.parseInt(arrOfStr[1]);
            int bloodOx = Integer.parseInt(arrOfStr[2]);
            int rand = temp;
            if (rand > 45) {
              
              if (rand > .9*maxHR) {
                pointColors[count] = color(255, 0, 0);
              } else if (rand >= .8*maxHR && rand < .9*maxHR) {
                pointColors[count] = color(255, 255, 0);
              } else if (rand >= .7*maxHR && rand < .8*maxHR) {
                pointColors[count] = color(0, 255, 0);
              } else if (rand >= .6*maxHR && rand < .7*maxHR) {
                pointColors[count] = color(0, 255, 255);
              } else {
                pointColors[count] = color(0, 0, 128);
              }
              
              if(rand > baseline + 30 && baseline > 45){   //STRESSED
                 fill(255,255,255);
                 stroke(255);
                 rect(600, 140, 110, 50);
                 PImage stressmode = loadImage("stressmode.png");
                 image(stressmode, 700, 155, 50, 50);  
                 fill(255);
                 stroke(255);
                 rect(580, 170, 110, 50);
                 fill(0);
                 text("STRESSED!", 580, 185);
              }
              if(rand < baseline){ //RELAXED
                 fill(255,255,255);
                 stroke(255);
                 rect(650, 170, 80, 80);
                 PImage relaxmode = loadImage("relaxmode.png");
                 image(relaxmode, 700, 155, 50, 50);
                 fill(255);
                 stroke(255);
                 rect(580, 170, 110, 50);
                 fill(0);
                 text("RELAXED!", 580, 185);
              }
              
               instHRT = float(60)/float(rand);
             //print(instHRT);
              fill(255,255,255);
              stroke(255);
              rect(730, 50, 80, 40);
              fill(0);
              textSize(22);
              text(str(instHRT), 730, 79);
              //rect(300
              //text(" ", 300, 190);
              fill(255,255, 255);
              stroke(255);
              rect(215, 150, 50, 50);
              fill(0);
              text(rand, 226, 190);
              
              fill(255,255,255);
              stroke(255);
              rect(226, 200, 40, 40);
              fill(0);
              textSize(22);
              text(confidence, 226, 215);
              
              fill(255,255,255);
              stroke(255);
              rect(730, 83, 80, 40);
              fill(0);
              textSize(22);
              text(str(bloodOx), 730, 110);
              
              sum += rand; 
              valHR++;
              
              if(millis() > 30000 && millis() < 35000){
                baseline = sum/valHR;
                print(baseline);
              }
             
              prevBeat = rand;
              points.add(xvar+10, rand);
              //plot.addPoint(xvar+10, rand*10);
              xvar = xvar+5;
              count++;
            } else {
              rand = prevBeat;
              //plot.addPoint(xvar+10, rand);
            }
      }
      if (xvar > 100) {
          points.removeRange(0, count);

          xvar = -5;
        //}
        count = 0;
      }
      lastStepTime = millis();
      //plot.defaultDraw();
      
      
      }
    }
    
    plot.setPoints(points);
    plot.setPointColors(pointColors);
    plot.beginDraw();
    plot.drawBackground();
    plot.drawBox();
    //plot.drawXAxis();
    plot.drawYAxis();

    plot.drawTitle();
    plot.drawLines();
    plot.getMainLayer().drawPoints();

    plot.endDraw();
    //println("testt");
}

GPoint calculatePoint(float i, float n) {
  return new GPoint(i, n);
}
