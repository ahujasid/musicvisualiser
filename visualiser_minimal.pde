
import ddf.minim.*;
import ddf.minim.analysis.*;
//DECLARE MINIM OBJECTS
Minim minim;
FFT fft;
AudioPlayer song;
//SEPARATING FREQUENCY BANDS
float lowFreq = 0.03; //Low frequencies are 3% of the whole spectrum
float midFreq = 0.125; //Mids are 12.5% of the whole spectrum
float highFreq = 0.30; //Highs are the rest but I have only taken 30% as the rest is subtle to the human ear
//THESE STORE THE SUM OF AMPLITUDES FOR EACH FREQUENCY SPECTRUM
float lowSum = 0;
float midSum = 0;
float highSum = 0;
//DECLARE SPHERES AND STARS OBJECTS
int noOfSpheres;
Sphere[] spheres;
int noOfStars = 500;
Star[] stars;
void setup(){
  
  fullScreen(P3D); //Runs in fullscreen
  minim = new Minim(this); //Initialise the Minim object
  
  //LOAD AUDIO FILE HERE
  song = minim.loadFile("Ratatat - Wildcat.mp3"); 
  fft = new FFT(song.bufferSize(), song.sampleRate()); //Check Minim website for syntax
  
  //INITIALISE SPHERES ARRAY
  noOfSpheres = (int)(fft.specSize()*0.04); //Returns the size of the spectrum created by this transform. In other words, the number of frequency bands produced by this transform.
  spheres = new Sphere[noOfSpheres];
  
  //INITIALISE STARS ARRAY
  stars = new Star[noOfStars];
  
  //SPHERES - INITIALISE INDIVIDUAL ELEMENTS OF ARRAY
  for(int i = 0; i < noOfSpheres; i++) {
   spheres[i] = new Sphere(); 
  }
  
  //STARS - INITIALISE INDIVIDUAL ELEMENTS OF ARRAY
  for(int i=0;i<noOfStars;i++){
    stars[i]= new Star();
  }
    
  background(0);
  song.play(0); //START SONG
}
void draw(){
  
  //DRAW CALLED FOR EACH FRAME OF THE SONG
  //See syntax on the Minim website
  fft.forward(song.mix);
  
  //SET SCORES TO ZERO AT BEGINNING OF EACH FRAME
  lowSum=0;
  midSum=0;
  highSum=0;
  
  //CALCULATE NEW SCORES
  for(int i = 0; i < fft.specSize()*lowFreq; i++) 
  {
    lowSum += fft.getBand(i); //ADDING UP AMPLITUDES OF LOW FREQUENCY BANDS (getBand returns the amplitude)
  }
  
   for(int i = (int)(fft.specSize()*lowFreq); i < fft.specSize()*midFreq; i++)
  {
    midSum += fft.getBand(i); //ADDING UP AMPLITUDES OF MID FREQUENCY BANDS
  }
  
   for(int i = (int)(fft.specSize()*midFreq); i < fft.specSize()*highFreq; i++)
  {
    highSum += fft.getBand(i); //ADDING UP AMPLITUDES OF HIGH FREQUENCY BANDS
  }
  
  //SETTING THE SPEED WITH WHICH THE OBJECTS CAN MOVE IN Z. DEPENDS ON TREBLE THE MOST
  //TRY MESSING WITH THE VALUES TO SEE HOW IT CAN AFFECT SPEED
  float globalSpeed = 0.66*lowSum + 0.9*midSum + 1*highSum; 
  
  //BACKGROUND COLOR
  background(lowSum/20, midSum/20, highSum/20);
  
  //DISPLAY SPHERES
  for(int i=0; i<noOfSpheres; i++){
    float bandValue = fft.getBand(i);
    spheres[i].display(lowSum,midSum,highSum,bandValue,globalSpeed);
  }
  
  //DISPLAY STARS
  for(int i=0; i<noOfStars; i++){
    float bandValue = fft.getBand(i);
    stars[i].display(bandValue, globalSpeed);
  }
}
//SPHERE CLASS
class Sphere{
  
  float startingZ = -10000;
  float maxZ = 1000;
  float x, y, z;
  
  //RANDOMISE COORDINATES FOR SPHERES
  Sphere(){
    x = random(0,width);
    y = random(0,height);
    z = random(startingZ, maxZ);
  }
  
  void display(float lowSum, float midSum, float highSum, float intensity, float globalSpeed){
    
    //BASS IS RED, MIDS ARE GREEN, AND HIGHS ARE BLUE. INTENSITY CONTROLS THE OPACITY
    color displayColor = color(lowSum*0.8, midSum*0.8, highSum*0.8, intensity*8);
    stroke(displayColor);
    noFill();
    
    //CREATE SPHERE
    pushMatrix();       
    translate(x,y,z); 
    sphere(30+(intensity*1/3)); //The sphere has a default radius of 30 and changes based on intensity
    popMatrix();
    
    //Z-MOVEMENT
    //SPEED DEPENDS A BIT ON INTENSITY BUT VARIES MORE WITH GLOBAL SPEED
    //YOU CAN TRY PLAYING AROUND WITH THESE AND SEE HOW THE SPEED VARIES
    z+= ((intensity/5) + pow((globalSpeed/150),2)); 
 
    //IF SPHERE GOES OUT OF SCREEN RESET Z
    if (z >= maxZ) {
      x = random(0, width);
      y = random(0, height);
      z = startingZ;
    }
  }
}
 
//STAR CLASS  
class Star{
  float x,y,z;
  float pz; //Previous Z
  float startingZ = -10000;
  float maxZ = 1000;
  
  //Assigning random coordinates
  Star(){
    x=random(0,width);
    y=random(0,height);
    z=random(startingZ,maxZ);
    pz=z; 
  }
    
 void display(float intensity, float globalSpeed){
   fill(255); //Always white in color
   noStroke();
   
   //Setting size of ellipse depending on where it is in Z-space. 
   //The farther it is, the smaller it looks
   float r = map(z,startingZ,maxZ,1,4); 
   
   //CREATE STARS
   pushMatrix();   
   translate(x,y,z); 
   ellipse(x,y,r,r);
   popMatrix();
 
  //CONTROL SPEED OF STARS
  if(intensity<3){ 
   //MINIMUM SPEED OF STARS SO THEY NEVER STOP
   z+= 3; 
   }
  else{
    //SAME SPEED INCREMENT AS OTHER SPHERES OTHERWISE
    z+= ((intensity/5) + pow((globalSpeed/150),2));     
   }
 
 //RESET STARS IF THEY LEAVE SCREEN
  if(z>=maxZ){
   x=random(0,width);
   y=random(0,height);
   z=startingZ;
   }  
 
 //STREAKS FOR STARS WHEN MOVING FAST
 stroke(255); 
 if(pz<z)
  line(x,y,pz,x,y,z);   
 pz = z; 
  }
}
