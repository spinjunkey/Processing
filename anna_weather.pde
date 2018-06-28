import processing.serial.*;
import cc.arduino.*;

Arduino arduino;
PFont f;
int[] LEDPin = {9,11,13};
String[] zipCodes = {"85004", "97124", "99762"}; //Phoenix, Hillsboro, Alaska

WeatherGrabber wg = new WeatherGrabber(zipCodes[1]);
String currentWeather = wg.returnWeather();
int currentTemp = wg.returnTemp();

void setup()
{
  //println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[4], 57600);
  arduino.pinMode(LEDPin[2], Arduino.OUTPUT);
  arduino.pinMode(LEDPin[1], Arduino.OUTPUT);
  arduino.pinMode(LEDPin[0], Arduino.OUTPUT);
  size(200,100);
  f = createFont( "Lato" ,15,true);
}

void draw()
{ 
  background(255);
  textFont(f);
  fill(0);
  
  // Display all the stuff we want to display
  text(currentWeather,10,20);
  text(currentTemp,10,40);
  
  // Draw a little thermometer based on the temperature
  stroke(0);
  fill(175);
  rect(10,50,currentTemp*2,20);
  
  //now, depending on the temperature light the right led
  if(currentTemp > 80){
    arduino.digitalWrite(LEDPin[0], Arduino.HIGH);
    arduino.digitalWrite(LEDPin[1], Arduino.LOW);
    arduino.digitalWrite(LEDPin[2], Arduino.LOW);
  }else if(currentTemp > 60 && currentTemp <= 80){
    arduino.digitalWrite(LEDPin[0], Arduino.LOW);
    arduino.digitalWrite(LEDPin[1], Arduino.HIGH);
    arduino.digitalWrite(LEDPin[2], Arduino.LOW);  
  }else if(currentTemp <= 60){
    arduino.digitalWrite(LEDPin[0], Arduino.LOW);
    arduino.digitalWrite(LEDPin[1], Arduino.LOW);
    arduino.digitalWrite(LEDPin[2], Arduino.HIGH);  
  }
  
}

//***************************************************************
class WeatherGrabber {
  
  int temperature = 0;
  String weather = "";
  
  WeatherGrabber(String tempZip) {
   
    String url = "http://xml.weather.yahoo.com/forecastrss?p=" + tempZip;
    String[] lines = loadStrings(url);
    
    // Turn array into one long String
    String xml = join(lines, "" ); 
    
    // Searching for weather condition
    String lookfor = "<yweather:condition  text=\"";
    String end = "\"";
    weather = parseText(xml,lookfor,end);
    
    // Searching for temperature
    lookfor = "temp=\"";
    temperature = int(parseText (xml,lookfor,end));
  }
  
  int returnTemp() {
    return temperature;
  }
  
  String returnWeather() {
    return weather;
  }
  
  String parseText(String s, String before, String after) {
    String found = "";
    int start = s.indexOf(before);    // Find the index of the beginning tag
    if (start == - 1) return"";       // If we don't find anything, send back a blank String
    start += before.length();         // Move to the end of the beginning tag
    int end = s.indexOf(after,start); // Find the index of the end tag
    if (end == -1) return"";          // If we don't find the end tag, send back a blank String
    return s.substring(start,end);    // Return the text in between
  }
  
}
//***************************************************************
