import processing.sound.*; // import processing sound library

SoundFile file; //audio file class constructor
ArduinoInput input; //arduino input class constructor
Amplitude rms; //amplitude class constructor

// Create a shader object
PShader shaderToy; //shadertoy shader object
PShader rgbShiftShader; //rgb shift effect object

// Create off sceen textures to render our shaders into
PGraphics shaderToyFBO; //shadertoy frame buffer object
PGraphics rgbShiftFBO; //rgb shift effect object

float sum; //variable for storing our amplitude values

float smoothFactor = .07; //smoothing factor for amplitude values

//-------------------------------------
void setup() {
  //size(640, 480, P3D); //screen size
  fullScreen(P2D); //fullscreen
  noStroke(); //no stroke
  background(0); //background black
  file = new SoundFile(this, "Vibe.mp3"); //read the mp3 file in data folder and store in file variable
  file.play(); //play the audio file
  input = new ArduinoInput(this); // call the constructor of ArduinoInput
  
  rms = new Amplitude(this); //call constructor for amplitude class
  rms.input(file); //put the sound file into the amplitude analyzer
  
  shaderToy = loadShader("myShader.glsl"); // Load our .glsl shader from the /data folder
  shaderToy.set("iResolution", float(width), float(height), 0); // Pass in our xy resolution to iResolution uniform variable in our shader
  shaderToyFBO = createGraphics(width, height, P3D); //size the fbo to the current screen size 
  shaderToyFBO.shader(shaderToy); //feed shadertoy shader into shadertoy fbo
  
  rgbShiftShader = loadShader("chromaticAbberation.glsl"); // Load our .glsl shader from the /data folder
  rgbShiftShader.set("iResolution", float(width), float(height), 0); // Pass in our xy resolution to iResolution uniform variable in our shader
  rgbShiftFBO = createGraphics(width, height, P3D); ////size the fbo to the current screen size 
  rgbShiftFBO.shader(rgbShiftShader); //feed rgb effect into rgb fbo

}

//this function updates all our shader parameters
void updateShaderParams() {
  sum += (rms.analyze() - sum) * smoothFactor; // store the amplitude values inside sum variable and smooth them out
  
  float[] sensorValues = input.getSensor(); //read values from the arduino into an array
  shaderToy.set("fractale", map(sensorValues[1],0.0,1024.0,0,10.0)); //set shadertoy parameter to arduino input
  shaderToy.set("bloom", map(sum,0.0,1.0,-1.0,1.0)); //set shadertoy parameter to music amplitude
  shaderToy.set("split", map(sensorValues[2],0.0,1024.0,0.0,1.0)); //set shadertoy parameter to arduino input
  shaderToy.set("darkness", map(sensorValues[0],0.0,1024.0,0,5.0)); //set shadertoy parameter to arduino input
  shaderToy.set("splat", map(sum,0.0,1.0,0.0,.5)); //set shadertoy parameter to music amplitude
  rgbShiftShader.set("offset", map(sensorValues[4],0.0,1024,0,2)); //set shadertoy parameter to arduino input
  shaderToy.set("sploot", map(sensorValues[3],0.0,1024.0,1.0,8.)); //set shadertoy parameter to arduino input
  shaderToy.set("zoom", map(sum,0.0,1.0,0.0,0.1)); //set shadertoy parameter to arduino input

}

void draw() {
  updateShaderParams(); // update shader parameters
  
  shaderToyFBO.beginDraw(); 
  shaderToy.set("iGlobalTime", millis() / 1000.0); // pass in a millisecond clock to enable animation 
  shader(shaderToy); 
  shaderToyFBO.rect(0, 0, width, height); // We draw a rect here for our shader to draw onto
  shaderToyFBO.endDraw();    
  
  
  rgbShiftFBO.beginDraw();
  rgbShiftShader.set("iGlobalTime", millis() / 1000.0); // pass in a millisecond clock to enable animation
  rgbShiftShader.set("tex", shaderToyFBO); //feed shadertoy into rgb effect
  shader(rgbShiftShader); 
  rgbShiftFBO.rect(0, 0, width, height); // We draw a rect here for our shader to draw onto
  rgbShiftFBO.endDraw();

  image(rgbShiftFBO, 0, 0, width, height); //display the last fbo in the chain
}
  
