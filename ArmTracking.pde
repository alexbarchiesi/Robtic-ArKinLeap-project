//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
import SimpleOpenNI.*;
private SimpleOpenNI mKinect;
/**
* Average value for the buffers
*/
private final static int NUM_AVRG = 10;
/**
* Buffer contain the NUM_AVRG values of ShoulderElbow x coordinate
*/
private ArrayList<Float> mSEXBuffer = new ArrayList<Float>();
/**
* Buffer contain the NUM_AVRG values of ShoulderElbow y coordinate
*/
private ArrayList<Float> mSEYBuffer = new ArrayList<Float>();
/**
* Buffer contain the NUM_AVRG values of ShoulderElbow z coordinate
*/
private ArrayList<Float> mSEZBuffer = new ArrayList<Float>();
/**
* Buffer contain the NUM_AVRG values of ElbowHand x coordinate
*/
private ArrayList<Float> mEHXBuffer = new ArrayList<Float>();
/**
* Buffer contain the NUM_AVRG values of ElbowHand y coordinate
*/
private ArrayList<Float> mEHYBuffer = new ArrayList<Float>();
/**
* Buffer contain the NUM_AVRG values of ElbowHand z coordinate
*/
private ArrayList<Float> mEHZBuffer = new ArrayList<Float>();
/**
* List of SE buffers
*/
private ArrayList<ArrayList<Float>> mSEBuffers = new ArrayList<ArrayList<Float>>();
/**
* List of EH buffers
*/
private ArrayList<ArrayList<Float>> mEHBuffers = new ArrayList<ArrayList<Float>>();
/**
* Store data of the arm
*/
private ArrayList<PVector> mData;
private ArrayList<PVector> mVectors;
private ArrayList<Integer> mAngles;

private final static int MAX_ANGLE = 180;
private final static int MIN_ANGLE = 10;

private PVector mYUnitVector = new PVector(0,1,0);
private PVector mZUnitVector = new PVector(0,0,1);
private PVector mShoulderJointCoord = new PVector(mShoulderJointX,mShoulderJointY,mShoulderJointZ);
private String[] mAnglesLabel = { "Elbow angle : ","shoulderXY angle : ","shoulderXZ angle : "};

private PFont f; 

void armSetUp()
{
  mKinect = new SimpleOpenNI(this);
  
  mKinect.enableDepth();
  mKinect.enableUser();
  mKinect.setMirror(false);
  
  mSEBuffers.add(mSEXBuffer); mSEBuffers.add(mSEYBuffer) ; mSEBuffers.add(mSEZBuffer);
  mEHBuffers.add(mEHXBuffer); mEHBuffers.add(mEHYBuffer) ; mEHBuffers.add(mEHZBuffer);
  f = createFont("OCR A Extended",16,true);
}

void userDetection(){
  mKinect.update();
  
  int[] userList = mKinect.getUsers();
  
  if(userList.length > 0){
    if(mKinect.isTrackingSkeleton(userList[0])){
      getArmData(userList[0]);
    }
  }
}

void getArmData(int userID)
{
  //Vector that will store data for the shoulder,elbow and hand
  PVector shoulder = new PVector();
  PVector elbow = new PVector();
  PVector hand = new PVector();
  
  this.mData = new ArrayList<PVector>();
  this.mVectors = new ArrayList<PVector>();
  this.mAngles = new ArrayList<Integer>();

  // Gathering informations from kinect
  mKinect.getJointPositionSkeleton(userID,SimpleOpenNI.SKEL_LEFT_SHOULDER, shoulder);
  mKinect.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_ELBOW,elbow);
  mKinect.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_HAND,hand);
  
  //Calculate position for drawing 
  PVector SELine = new PVector(mShoulderJointX - (shoulder.x - elbow.x),
                               mShoulderJointY + (shoulder.y - elbow.y),
                               mShoulderJointZ - (shoulder.z - elbow.z));
  this.mData.add(averageVal(SELine,mSEBuffers));
  this.mVectors.add(PVector.sub(this.mData.get(0),this.mShoulderJointCoord));
  
  PVector EHLine = new PVector(SELine.x - (elbow.x - hand.x),
                               SELine.y + (elbow.y - hand.y),
                               SELine.z-+ (elbow.z - hand.z));
                               
  this.mData.add(averageVal(EHLine,mEHBuffers));
  this.mVectors.add(PVector.sub(this.mData.get(1),this.mData.get(0)));
  this.mVectors.add(new PVector(this.mVectors.get(0).x,
                                0,
                                this.mVectors.get(0).z));
  this.mVectors.add(new PVector(this.mVectors.get(0).x,
                                this.mVectors.get(0).y,
                                0));
  
  PVector tmp = new PVector();
  
  PVector.mult(this.mVectors.get(0),-1,tmp);
  
  this.mAngles.add(getAngle(tmp,this.mVectors.get(1)));
  this.mAngles.add(getAngle(mZUnitVector,this.mVectors.get(2)));
  this.mAngles.add(getAngle(mYUnitVector,this.mVectors.get(3)));
  sendAngle();
  setUpHand(this.mData.get(1));
  
  
}

void sendAngle() 
{
 for ( int i = 0; i < this.mAngles.size() ; ++i){
   if ( this.mAngles.get(i) > MAX_ANGLE){
     this.mAngles.remove(i);
     this.mAngles.add(i,180);
   }
   if ( this.mAngles.get(i) < MIN_ANGLE){
     this.mAngles.remove(i);
     this.mAngles.add(i,0);
   }
   
   sendToArduino();
 }
}


PVector averageVal(PVector vector, ArrayList<ArrayList<Float>> buffers)
{
  if(buffers.get(0).size() == NUM_AVRG){
    for ( ArrayList<Float> buffer : buffers){
      buffer.remove(0);
    }
    buffers.get(0).add(vector.x); 
    buffers.get(1).add(vector.y);
    buffers.get(2).add(vector.z);
  } else {
    buffers.get(0).add(vector.x); 
    buffers.get(1).add(vector.y);
    buffers.get(2).add(vector.z);
  }
  ArrayList<Float> values = new ArrayList<Float>();
  for ( ArrayList<Float> buffer : buffers){
    float sumResult = 0;
    for( float val : buffer ){
      sumResult += val;
    }
    values.add(sumResult);
  }
  PVector result = new PVector(values.get(0) / buffers.get(0).size(),
                               values.get(1) / buffers.get(1).size(),
                               values.get(2) / buffers.get(2).size());
  return result;
}

void drawArm(PGraphics pgr)
{
  pgr.strokeWeight(4);
  if( this.mData != null){
    if(this.mData.size() == 2){
      //Draw Arm
      pgr.line(mShoulderJointX,mShoulderJointY,mShoulderJointZ,
               this.mData.get(0).x, this.mData.get(0).y, this.mData.get(0).z);
      pgr.line( this.mData.get(0).x, this.mData.get(0).y, this.mData.get(0).z,
                this.mData.get(1).x, this.mData.get(1).y, this.mData.get(1).z);
      //Draw joints
      pgr.pushMatrix();
      pgr.translate(mShoulderJointX,mShoulderJointY,mShoulderJointZ);
      pgr.box(20);
      pgr.fill(0);
      pgr.popMatrix();
      pgr.pushMatrix();
      pgr.translate(this.mData.get(0).x, this.mData.get(0).y, this.mData.get(0).z);
      pgr.sphere(7);
      pgr.popMatrix();
      pgr.pushMatrix();
      pgr.translate(this.mData.get(1).x, this.mData.get(1).y, this.mData.get(1).z);
      pgr.sphere(7);
      pgr.noFill();
      pgr.popMatrix();
                
    }
    pgr.strokeWeight(1);
  }
}


int getAngle(PVector a, PVector b)
{
  float angle = PVector.angleBetween(a,b);
  int degreeAngle = (int) Math.toDegrees((double) angle);
  return degreeAngle;
}

void writeAngles( PGraphics pgr)
{
  if( this.mAngles != null){
    for( int i = 0; i<this.mAngles.size() ; ++i){
      pgr.textFont(f,70); 
      pgr.fill(0);
      pgr.text(mAnglesLabel[i] + this.mAngles.get(i),400,(i+4)*100);
    }
  }
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
