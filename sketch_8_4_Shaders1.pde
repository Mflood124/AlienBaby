import processing.sound.*;
import processing.video.*;


SoundFile file;
ArduinoInput input;
Amplitude rms;

// Create a shader object
PShader shaderToy;
PShader rgbShiftShader;


// Create off sceen textures to render our shaders into
PGraphics shaderToyFBO;
PGraphics rgbShiftFBO;

float sum;

float smoothFactor = 1.5;

//-------------------------------------
void setup() {
  //size(640, 480, P3D);
  fullScreen(P2D);
  noStroke();
  background(0);
  file = new SoundFile(this, "Vibe.mp3");
  file.play();
  input = new ArduinoInput(this); // call the constructor of ArduinoInput
  
  rms = new Amplitude(this);
  rms.input(file);
  
  shaderToy = loadShader("myShader.glsl"); // Load our .glsl shader from the /data folder
  shaderToy.set("iResolution", float(width), float(height), 0); // Pass in our xy resolution to iResolution uniform variable in our shader
  shaderToyFBO = createGraphics(width, height, P3D);
  shaderToyFBO.shader(shaderToy);
  
  rgbShiftShader = loadShader("chromaticAbberation.glsl");
  rgbShiftShader.set("iResolution", float(width), float(height), 0);
  rgbShiftFBO = createGraphics(width, height, P3D);
  rgbShiftFBO.shader(rgbShiftShader); 

}


void updateShaderParams() {
  float[] sensorValues = input.getSensor();

  sum += (rms.analyze() - sum) * smoothFactor;
  shaderToy.set("fractale", map(sensorValues[1],0.0,1024.0,0,20.0));
  shaderToy.set("bloom", map(sum,0.0,1.0,-10.0,10.0));
  shaderToy.set("split", map(sensorValues[2],0.0,1024.0,-1.00,1.0));
  shaderToy.set("darkness", map(sensorValues[0],0.0,1024.0,0.0,10.0));
  shaderToy.set("zoom", map(sum,0.0,1.0,0,0.2));
  rgbShiftShader.set("offset", map(sensorValues[3],0.0,1024,0,0.5));
  
}
//-------------------------------------
void draw() {

  updateShaderParams();
  
  

  shaderToyFBO.beginDraw();
  shaderToy.set("iGlobalTime", millis() / 1000.0); // pass in a millisecond clock to enable animation 
  shader(shaderToy); 
  shaderToyFBO.rect(0, 0, width, height); // We draw a rect here for our shader to draw onto
  shaderToyFBO.endDraw();    
  
  
  rgbShiftFBO.beginDraw();
  rgbShiftShader.set("iGlobalTime", millis() / 1000.0); 
  rgbShiftShader.set("tex", shaderToyFBO);
  shader(rgbShiftShader); 
  rgbShiftFBO.rect(0, 0, width, height); 
  rgbShiftFBO.endDraw();

  image(rgbShiftFBO, 0, 0, width, height);
}
  