import com.hamoid.*;
import java.util.*;

String[] monthNames = {"JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"};
int START_DATE = dateToDays("1993-01-01");

int YEARS;//DAY_LEN in example code
int COLLEGE_COUNT; //PEOPLE_COUNT in example code. Should be 21...? CHECK THIS?
String[] textFile; //load the text file in
String[] textFileJustNames; //load the text file in
String[] textFileTwo;
//array of colleges
College[] colleges; //example code: Person[] people;

int TOP_VISIBLE = 15; //this is a top TEN video, so ten will be visible.

float[] maxes; //maximum value for every day across all people. will be helpful for scaling factors

float X_MIN = 100;
float X_MAX = 1900;
float Y_MIN = 300;
float Y_MAX = 1000;
float X_W = X_MAX-X_MIN;
float Y_H = Y_MAX-Y_MIN;

float currentScale = -1;

int frames = 0;
float currentYear = 0; //currentDay in example code
float FRAMES_PER_YEAR = 100; //dataset is 36 years, video should be 2 minutes long, so 0.3 YEARS A SECOND. Video is 60FPS, so 200 frames per year.
float BAR_HEIGHT;
float BAR_PROPORTION = 0.9; //arbiratarily set to 0.9. It makess a 0.1 gap between bars.
PFont font;

int[] unitPresets = {1,2,5,10,20,50,100,200,500,1000,2000,5000,10000,20000,50000,100000,200000,500000,1000000,2000000,5000000};
 //list of possible tick marks where horizontal stuff would be added in
int[] unitChoices; //give it a year and it'll tell you what unit you should use for that year
PImage img[];

String[] bignames = new String[63];

VideoExport videoExport;

int cols = 18; //there are 18 unique years
int rows = 63; //there are 63 unique big college (ID)s

//there are 8 variables to keep in 8 2d arrays. These should start out with all zeroes as values, which is what we want for the "no data" situation
int variables = 8;
int[][] undergrads = new int[cols][rows]; //year, then college IDs
float[][] white = new float[cols][rows]; //year, then college IDs
float[][] black = new float[cols][rows]; //year, then college IDs
float[][] hisp = new float[cols][rows]; //year, then college IDs
float[][] asian = new float[cols][rows]; //year, then college IDs
float[][] nhpi = new float[cols][rows]; //year, then college IDs
float[][] unknown = new float[cols][rows]; //year, then college IDs
float[][] ai = new float[cols][rows]; //year, then college IDs
float[][] mr = new float[cols][rows]; //year, then college IDs

//SLIDER
//sliderPos directly correlates to which frame is displayed. Also need to use LINEAR insteda of WA  
  int circleX = 60; //sliderPos
  int circleY = 60;
  int circleSize = 30;
  boolean sliderMoving = false;


void setup(){
  //change this from babafont eventually...
  font = loadFont("Avenir-Heavy-96.vlw");
  
  //PARSING INITIAL STUFF AND THE FIRST LINE OF DATA - THE NAMES
  
  textFile = loadStrings("fulldata4.tsv"); //automatically goes to the "data" file and sees it
    
  String[] names = textFile[0].split("\t"); // "\t" means a tab  //horizontal row along code. in general, called PARTS in the example code
  //YEARS = textFile.length-2; //this is textFile.length-1 in the example, but we have the locations to worry about too
  //COLLEGE_COUNT = names.length-1; 

  COLLEGE_COUNT = 63;  
  
  //STUFF FOR THE ENROLLMENT DATA
  textFileJustNames = loadStrings("justNames.tsv"); //automatically goes to the "data" file and sees it

  int[] bigyears = {1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013};
  YEARS = bigyears.length;
  
  colleges = new College[63]; //63 unique colleges, defined below here
  String[] bignames = textFileJustNames[0].split("\t"); 
  for(int y = 0; y < 63; y++){
    //println("textfilejustnames "+textFileJustNames[0]);
    //println(bignames[y]);
    //println(colleges[0]);
    colleges[y] = new College(bignames[y]); 
  }
  //colleges = new College[COLLEGE_COUNT];
  //for(int i = 0; i < COLLEGE_COUNT; i++){
  //  colleges[i] = new College(names[i+1]);
  //}
  
  
  textFileTwo = loadStrings("book3Improved5.tsv"); 
  
  //set up maxes before going through every row in the table
  maxes = new float[YEARS];
  unitChoices = new int[YEARS];
  
  for(int y = 0; y < YEARS; y++){//is d in example code
    maxes[y] = 0; // QUESTIONABLE --> maxes don't matter since we always want 1st through 10th and nothing more. 10 doesn't actually mean anything, it's supposed to be for like eg. if you were looking for colleges with top 10 tuitions, this would be the array of max tuitions.
  }
  
  
  //for every single row of the table, (there are 451 of them, 450 without header)
  for(int i = 0; i < 450; i++){
    String[] dataParts = textFileTwo[i+1].split("\t"); //horizontal sections along a single row.
    //for the integer (undergrads)
    
    //get the integers and floats into this big thing!!
    int convertedYear = Integer.parseInt(dataParts[0])-1996;
    int collegeID = Integer.parseInt(dataParts[1]);
    undergrads[convertedYear][collegeID] = Integer.parseInt(dataParts[2]);
    white[convertedYear][collegeID] = Float.parseFloat(dataParts[3]); //red  <-- most distinct colors to put white text on
    black[convertedYear][collegeID] = Float.parseFloat(dataParts[4]); //green
    hisp[convertedYear][collegeID] = Float.parseFloat(dataParts[5]); //blue
    asian[convertedYear][collegeID] = Float.parseFloat(dataParts[7]); //orange
    nhpi[convertedYear][collegeID] = Float.parseFloat(dataParts[6]); //teal
    unknown[convertedYear][collegeID] = Float.parseFloat(dataParts[8]); // EXCEPTION: grey
    ai[convertedYear][collegeID] = Float.parseFloat(dataParts[9]); //purple
    mr[convertedYear][collegeID] = Float.parseFloat(dataParts[10]); //teal
    
    //from the parsing data; d is year, c is college
    float val = undergrads[convertedYear][collegeID];
    colleges[collegeID].values[convertedYear] = val;

    if(val > maxes[convertedYear]){
      maxes[convertedYear] = val;
    }
  }
  
  //from the parsing data; d is years, c is number of colleges
  
    // ABOVE STUFF FOR THE ENROLLMENT DATA

  getRankings();
  getUnits();

  BAR_HEIGHT = (rankToY(1)-rankToY(0))*BAR_PROPORTION;
  size(1920,1080); //size of window. 
  
  //videoExport = new VideoExport(this,"outputtedVideo.mp4");
  //videoExport.startMovie();
}

void draw(){
  currentYear = frames/FRAMES_PER_YEAR; //if the middle needs to be rendered, you can skip ahead here by adding a number
  currentScale = getXScale(currentYear);
  drawBackground();
  drawHorizTickmarks();
  drawPlacements();
  drawBars();
  
  //videoExport.saveFrame();
  //if(getYearFromFrameCount(frames) >= YEARS){
  //videoExport.endMovie();
  //exit(); 
  //}
  //at the very end the frame number incremented, and nothing ever comes after this.
  drawSlider();
  
  println("frames "+frames);
  //frames++;
}

void drawSlider(){
  println("mouseX "+mouseX);
  //if the circle is sellected and the mouse is within the circle,
  
  if(sliderMoving == false){
    
    
    if(mousePressed && mouseOver(circleX,circleY,circleSize)){
    sliderMoving = true;
    }
  }
  if(sliderMoving == true){
    if(mouseX<1775){
      circleX = mouseX; //make this smoother probably
    }
    frames = circleX;
    if(!mousePressed){
      sliderMoving = false;
    }
  }
  
  fill(200);
  circle(circleX,circleY,circleSize);
   
  //updateSliderPos based on mouse position
}

boolean mouseOver(int x, int y, int diameter){
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

//check 2001, aand the gap between 2015-16
float getYearFromFrameCount(int fc){
  return fc/FRAMES_PER_YEAR; //the starting year (this is probably a bad idea)
}

void drawPlacements(){
  for(int c = 0; c < COLLEGE_COUNT; c++){
    College co = colleges[c];
    //println(co.values);
    int rankNow = floor(linIndex(co.values,currentYear)); //or is this supposed to be co.ranks?
    //println(co.name + " "+linIndex(co.values,currentYear)); //round down values
  }
}

void drawHorizTickmarks(){
  float preferredUnit = WAIndex(unitChoices, currentYear, 4); //was 4
  float unitRem = preferredUnit%1.0;
  if(unitRem < 0.001){
    unitRem = 0;
  }else if(unitRem >= 0.999){
    unitRem = 0;
    preferredUnit = ceil(preferredUnit);
  }
  int thisUnit = unitPresets[(int)preferredUnit];
  int nextUnit = unitPresets[(int)preferredUnit+1];
  
  drawTickMarksOfUnit(thisUnit,255-unitRem*255);
  if(unitRem >= 0.001){
    drawTickMarksOfUnit(nextUnit,unitRem*255);
  }
}

void drawTickMarksOfUnit(int u, float alpha){
  for(int v = 0; v < currentScale*1.4; v+=u){
    float x = valueToX(v);
    fill(100,100,100,alpha);
    float W = 4;
    rect(x-W/2,Y_MIN-20,W,Y_H+20);
    textAlign(CENTER);
    textFont(font,40);
    text(keyify(v),x,Y_MIN-30);
  }
}

void drawBackground(){
  //drawing the title, stuff in corner, that doesn't involve numbers
  background(0);
  
  fill(255);
  textFont(font,144);
  textAlign(RIGHT);
  //going to just manually code this...
  
  text((int)(currentYear+1996),width-40,150); //would be 1982 but it feels kinda a year behind? the year changes just as that ayears results show up

  textAlign(LEFT);
  textFont(font,50);
  text("US College/Post-Secondary Institution Enrollment",X_MIN,100);
  
  textFont(font,30);
  float spot = width*1/8;
  fill(#e6194B);
  square(spot,Y_MIN*3/6,30);
  fill(255);
  text("White",spot+30+5,Y_MIN*3/6+30-5);
  fill(#3cb44b);
  square(spot,Y_MIN*4/6,30);
  fill(255);
  text("Black",spot+30+5,Y_MIN*4/6+30-5);
  spot = width*1.6/8;
  fill(#4363d8);
  square(spot,Y_MIN*3/6,30);
  fill(255);
  text("Hispanic",spot+30+5,Y_MIN*3/6+30-5);
  fill(#f58231);
  square(spot,Y_MIN*4/6,30);
  fill(255);
  text("Asian",spot+30+5,Y_MIN*4/6+30-5);
  //when they start to get included, fade in.
  spot = width*2.3/8;
  fill(#911eb4);
  square(spot,Y_MIN*3/6,30);
  fill(255);
  text("American Indian",spot+30+5,Y_MIN*3/6+30-5);
  fill(#f032e6);
  square(spot,Y_MIN*4/6,30);
  fill(255);
  text("Mixed Race",spot+30+5,Y_MIN*4/6+30-5);
  spot = width*3.45/8;
  fill(#469990);
  square(spot,Y_MIN*3/6,30);
  fill(255);
  text("Pacific Islander",spot+30+5,Y_MIN*3/6+30-5);
  fill(150);
  square(spot,Y_MIN*4/6,30);
  fill(255);
  text("Unknown/Non-Resident Alien",spot+30+5,Y_MIN*4/6+30-5);
  
}

void drawBars(){
  noStroke();
  for(int p = 0; p < COLLEGE_COUNT; p++){
    College pe = colleges[p];
    float val = WAIndex(pe.values,currentYear,1.2);
    float x = valueToX(val);
    float rank = WAIndex(pe.ranks, currentYear, 1.2);
    float y = rankToY(rank);
    fill(150);
    rect(X_MIN,y,x-X_MIN,BAR_HEIGHT);
    
    //DRAW DIVERSITY
    
    //white
    
    float[] whiteHere = new float[YEARS];
    for(int ye = 0; ye < YEARS; ye++){
      whiteHere[ye] = white[ye][p];
    }
    float whiteWA = WAIndex(whiteHere, currentYear,1.2);
    fill(#e6194B); //red
    rect(X_MIN,y,(x-X_MIN)*whiteWA,BAR_HEIGHT);
    
    //move into next race
    pushMatrix();
    translate((x-X_MIN)*whiteWA,0);
    
    //black
    float[] blackHere = new float[YEARS];
    for(int ye = 0; ye < YEARS; ye++){
      blackHere[ye] = black[ye][p];
    }
    float blackWA = WAIndex(blackHere, currentYear,1.2);
    fill(#3cb44b); //green
    rect(X_MIN,y,(x-X_MIN)*blackWA,BAR_HEIGHT);
    
    //move into next race
    translate((x-X_MIN)*blackWA,0);
    
    //hisp
    float[] hispHere = new float[YEARS];
    for(int ye = 0; ye < YEARS; ye++){
      hispHere[ye] = hisp[ye][p];
    }
    float hispWA = WAIndex(hispHere, currentYear,1.2);
    fill(#4363d8); //blue
    rect(X_MIN,y,(x-X_MIN)*hispWA,BAR_HEIGHT);

    //move into next race
    translate((x-X_MIN)*hispWA,0);
    
    //asian
    float[] asianHere = new float[YEARS];
    for(int ye = 0; ye < YEARS; ye++){
      asianHere[ye] = asian[ye][p];
    }
    float asianWA = WAIndex(asianHere, currentYear,1.2);
    fill(#f58231); //orange
    rect(X_MIN,y,(x-X_MIN)*asianWA,BAR_HEIGHT);
    
    //move into next race
    translate((x-X_MIN)*asianWA,0);
    
    
    //pacific islanader
    float[] nhpiHere = new float[YEARS];
    for(int ye = 0; ye < YEARS; ye++){
      nhpiHere[ye] = nhpi[ye][p];
    }
    float nhpiWA = WAIndex(nhpiHere, currentYear,1.2);
    fill(#469990); //teal
    rect(X_MIN,y,(x-X_MIN)*nhpiWA,BAR_HEIGHT);
    
    //move into next race
    translate((x-X_MIN)*nhpiWA,0);
    
    
    //american indian
    float[] aiHere = new float[YEARS];
    for(int ye = 0; ye < YEARS; ye++){
      aiHere[ye] = ai[ye][p];
    }
    float aiWA = WAIndex(aiHere, currentYear,1.2);
    fill(#911eb4); //purple
    rect(X_MIN,y,(x-X_MIN)*aiWA,BAR_HEIGHT);
    
    //move into next race
    translate((x-X_MIN)*aiWA,0);
    
    //mixed race
    float[] mrHere = new float[YEARS];
    for(int ye = 0; ye < YEARS; ye++){
      mrHere[ye] = mr[ye][p];
    }
    float mrWA = WAIndex(mrHere, currentYear,1.2);
    fill(#f032e6); //magenta
    rect(X_MIN,y,(x-X_MIN)*mrWA,BAR_HEIGHT);

    /*
    //unnessecary, but tried this out
    
    //move into next race
    translate((x-X_MIN)*mrWA,0);
    
    //other, unknown, non-resident aliens
    float[] unknownHere = new float[YEARS];
    for(int ye = 0; ye < YEARS; ye++){
      unknownHere[ye] = unknown[ye][p];
    }
    float unknownWA = linIndex(unknownHere, currentYear);
    fill(#f032e6); //magenta
    rect(X_MIN,y,(x-X_MIN)*unknownWA,BAR_HEIGHT);
    
    */
    
    popMatrix();
    
    
    
    
    //Name of College
    fill(255);
    textFont(font,20);
    textAlign(LEFT);
    float appX = max(x+10,X_MIN+textWidth(pe.name)+5);
    text(pe.name,appX,y+BAR_HEIGHT-10);
  }
}

void getRankings(){
  for(int d = 0; d < YEARS; d++){
    boolean[] taken = new boolean[COLLEGE_COUNT];
    for(int p = 0; p < COLLEGE_COUNT; p++){
      taken[p] = false;
    }
    for(int spot = 0; spot < TOP_VISIBLE; spot++){
      float record = -1;
      int holder = -1;
      for(int p = 0; p < COLLEGE_COUNT; p++){
        if(!taken[p]){
          float val = colleges[p].values[d];
          if(val > record){
            record = val;
            holder = p;
          }
        }
      }
      colleges[holder].ranks[d] = spot; //breaks when more than top 10 is visible
      taken[holder] = true;
    }
  }
}

//INTERPOLATION METHODS

float stepIndex(float[] a, float index){
  return a[(int)index];
}
float linIndex(float[] a, float index){
  int indexInt = (int)index;
  float indexRem = index%1.0;
  float beforeVal = a[indexInt];
  float afterVal = a[min(YEARS-1,indexInt+1)];
  return lerp(beforeVal,afterVal,indexRem);
}
//weighted moving average
float WAIndex(float[] a, float index, float WINDOW_WIDTH){
  int startIndex = max(0,ceil(index-WINDOW_WIDTH));
  int endIndex = min(YEARS-1,floor(index+WINDOW_WIDTH));
  float counter = 0;
  float summer = 0;
  for(int d = startIndex; d <= endIndex; d++){
    float val = a[d];
    float weight = 0.5+0.5*cos((d-index)/WINDOW_WIDTH*PI);    
    counter += weight;
    summer += val*weight;
  }
  float finalResult = summer/counter;
  return finalResult;
}
float WAIndex(int[] a, float index, float WINDOW_WIDTH){
  float[] aFloat = new float[a.length];
  for(int i = 0; i < a.length; i++){
    aFloat[i] = a[i];
  }
  return WAIndex(aFloat,index,WINDOW_WIDTH);
}




float getXScale(float d){
  return WAIndex(maxes,d,1.2)*1.2;
}
float valueToX(float val){
  return X_MIN+X_W*val/currentScale;
}
float rankToY(float rank){
  float y = Y_MIN+rank*(Y_H/TOP_VISIBLE);
  return y;
}
String daysToDate(float daysF, boolean longForm){
  int days = (int)daysF+START_DATE+1;
  Date d1 = new Date();
  d1.setTime(days*86400000l);
  int year = d1.getYear()+1900;
  int month = d1.getMonth()+1;
  int date = d1.getDate();
  if(longForm){
    return year+" "+monthNames[month-1]+" "+date;
  }else{
    return year+"-"+nf(month,2,0)+"-"+nf(date,2,0);
  }
}
int dateToDays(String s){
  int year = Integer.parseInt(s.substring(0,4))-1900;
  int month = Integer.parseInt(s.substring(5,7))-1;
  int date = Integer.parseInt(s.substring(8,10));
  Date d1 = new Date(year, month, date, 6, 6, 6);
  int days = (int)(d1.getTime()/86400000L);
  return days;
}

void getUnits(){
  for(int d = 0; d < YEARS; d++){
    float Xscale = getXScale(d);
    for(int u = 0; u < unitPresets.length; u++){
      if(unitPresets[u] >= Xscale/3.0){ // That unit was too large for that scaling!
        unitChoices[d] = u-1; // Fidn the largest unit that WASN'T too large (i.e., the last one.)
        break;
      }
    }
  }
}

String keyify(int n){
  if(n < 1000){
    return n+"";
  }else if(n < 1000000){
    if(n%1000 == 0){
      return (n/1000)+"K";
    }else{
      return nf(n/1000f,0,1)+"K";
    }
  }
  if(n%1000000 == 0){
    return (n/1000000)+"M";
  }else{
    return nf(n/1000000f,0,1)+"M";
  }
}
