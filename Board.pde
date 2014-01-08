import com.leapmotion.leap.Controller;
import com.leapmotion.leap.Finger;
import com.leapmotion.leap.FingerList;
import com.leapmotion.leap.Frame;
import com.leapmotion.leap.HandList;
import com.leapmotion.leap.Vector;
import com.leapmotion.leap.Hand;

import processing.serial.*;

import peasy.PeasyCam;

/**
* Cam to move into the 3d space
*/
private PeasyCam mCam;
/**
* Maximum value for x,y and z
*/
private int mMaxCoord = 800;
/**
* Initial x position for the shoulder joint;
*/
private int mShoulderJointX = 3*mMaxCoord/4;
/**
* Initial y position for the shoulder joint;
*/
private int mShoulderJointY = mMaxCoord/2;
/** 
* initial z position for the shoulder joint
*/
private int mShoulderJointZ = 3*mMaxCoord/4;
/**
* Width of scene
*/
private int mWidth = 1600;
/**
* Height of the scene
*/
private int mHeight = 900;
/**
* Serverals Scene of peasyCam view
*/
private PMatrix mOriginalScene;
private PMatrix mSideScene;
private PMatrix mBackScene;
private PMatrix mTopScene;
private PMatrix mDefaultScene;
/**
* Severals views of the tracking process
*/
private PGraphics mSideView;
private PGraphics mBackView;
private PGraphics mDefaultView;
private PGraphics mTopView;
private PGraphics mAnglesView;

/**
* Axis
*/
private PVector origin = new PVector (100,100,130);
private PVector xAxis = new PVector (200,100,130);
private PVector yAxis = new PVector (100,200,130);
private PVector zAxis = new PVector (100,100,230);
Serial port;



void setup()
{
  //Size of the window
  size(mWidth, mHeight, P3D);
  
  //Get the original matrix scene from the PeasyCam
  mOriginalScene = getMatrix();
  
  //Views
  mSideView = createGraphics(mWidth,mHeight,P3D);
  mTopView = createGraphics(mWidth,mHeight,P3D);
  mDefaultView = createGraphics(mWidth,mHeight,P3D);
  mBackView = createGraphics(mWidth,mHeight,P3D);
  mAnglesView = createGraphics(mWidth,mHeight,P2D);
  
  
  //PeasyCam creation 
  mCam = new PeasyCam(this,mMaxCoord / 2.0, mMaxCoord / 2.0, mMaxCoord / 2.0, 1300);
  
  //Get the matrix from the peasy cam
  mSideScene = getMatrix();
  
  mCam.rotateX(PI / 2.0);
  mTopScene = getMatrix();
  
  mCam.rotateX(-1 * PI / 2.0);
  mCam.rotateY(-1 * PI / 5.0);
  mDefaultScene = getMatrix();


  mCam.rotateY(7 * PI / 10.0);
  mBackScene = getMatrix();
  
  port = new Serial(this,Serial.list()[0],9600);
  
  armSetUp();
  
  
}

void draw()
{
  userDetection();
  
  mSideView.beginDraw();
  {
    mSideView.setMatrix(mSideScene);
    mSideView.background(255);
    drawBox(mSideView);
    drawArm(mSideView);
    drawFingers(mSideView);
  }
  mSideView.endDraw();
  
  mTopView.beginDraw();
  {
    mTopView.setMatrix(mTopScene);
    mTopView.background(255);
    drawBox(mTopView);
    drawArm(mTopView);
    drawFingers(mTopView);
  }
  mTopView.endDraw();
  
  mDefaultView.beginDraw();
  {
    mDefaultView.setMatrix(mDefaultScene);
    mDefaultView.background(255);
    drawBox(mDefaultView);
    drawArm(mDefaultView);
    drawFingers(mDefaultView);
  }
  mDefaultView.endDraw();
  
  mBackView.beginDraw();
  {
    mBackView.setMatrix(mBackScene);
    mBackView.background(255);
    drawBox(mBackView);
    drawArm(mBackView);
    drawFingers(mBackView);
  }
  mBackView.endDraw();
  
  mAnglesView.beginDraw();
  {
   mAnglesView.background(255);
   writeAngles(mAnglesView);
  }
  mAnglesView.endDraw();
  
  setMatrix(mOriginalScene);
  
  image(mSideView,
        0,
        0, 
        (float) mWidth  / (float) 2.0, 
        (float) mHeight / (float) 2.0);
  image(mTopView, 
        (float) mWidth  / (float) 2.0,
        0, 
        (float) mWidth  / (float) 2.0, 
        (float) mHeight / (float) 2.0);
  image(mDefaultView,
        0,
        (float) mHeight / (float) 2.0,
        (float) mWidth  / (float) 2.0,
        (float) mHeight / (float) 2.0);
  image(mBackView,
        (float) mWidth  / (float) 2.0,
        (float) mHeight / (float) 2.0,
        (float) mWidth  / (float) 2.0, 
        (float) mHeight / (float) 2.0);
  image(mAnglesView,
        (float)3*mWidth  / (float) 8.0,
        (float)3* mHeight / (float) 8.0,
        (float) mWidth  / (float) 4.0, 
        (float) mHeight / (float) 4.0);
}

void drawBox(PGraphics pgr) 
{
  //Box
  pgr.strokeWeight(1);
  pgr.stroke(0);
  pgr.line(0, 0, 0, mMaxCoord, 0, 0);
  pgr.line(0, 0, 0, 0, mMaxCoord, 0);
  pgr.line(0, 0, 0, 0, 0, mMaxCoord);
  pgr.line(mMaxCoord, 0, 0, mMaxCoord, mMaxCoord, 0);
  pgr.line(mMaxCoord, 0, 0, mMaxCoord, 0, mMaxCoord);
  pgr.line(0, mMaxCoord, 0, mMaxCoord, mMaxCoord, 0);
  pgr.line(0, mMaxCoord, 0, 0, mMaxCoord, mMaxCoord);
  pgr.line(0, 0, mMaxCoord, 0, mMaxCoord, mMaxCoord);
  pgr.line(0, 0, mMaxCoord, mMaxCoord, 0, mMaxCoord);
  pgr.line(0, mMaxCoord, mMaxCoord, mMaxCoord, mMaxCoord, mMaxCoord);
  pgr.line(mMaxCoord, mMaxCoord, 0, mMaxCoord, mMaxCoord, mMaxCoord);
  pgr.line(mMaxCoord, 0, mMaxCoord, mMaxCoord, mMaxCoord, mMaxCoord);
  
  //Axis
  pgr.strokeWeight(4);
  pgr.stroke(255,0,0);
  pgr.line(origin.x,origin.y,origin.z,xAxis.x,xAxis.y,xAxis.z);
  pgr.stroke(0,255,0);
  pgr.line(origin.x,origin.y,origin.z,yAxis.x,yAxis.y,yAxis.z);
  pgr.stroke(0,0,255);
  pgr.line(origin.x,origin.y,origin.z,zAxis.x,zAxis.y,zAxis.z);
  pgr.stroke(0);
  //Back to the good strokeWeight
  pgr.strokeWeight(1);

}
