//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
private Frame mFrame;
private Controller mLeapMotion = new Controller();
private FingerList mFingers;
private HandList mHands;
private PVector mHand;
private ArrayList<PVector> mFingersData ;


void setUpHand(PVector hand)
{
  mHand = new PVector(hand.x,hand.y,hand.z);
 leapConnection();
}

void leapConnection() 
{
 if ( mLeapMotion.isConnected()) {
   getData();
 }
}

void getData()
{
  //Create FingersData
  this.mFingersData = new ArrayList<PVector>();
  // Get the frame from the controller 
  mFrame = mLeapMotion.frame();
  
  //Get list of fingers and hands 
  mFingers = mFrame.fingers();
  mHands = mFrame.hands();
  
  //Get the Hand
  Hand hand = mHands.get(0);
  
  //Store Position into a vector
  Vector handPosition = hand.palmPosition();
  
  for( Finger finger : mFingers) {
    
    Vector position = finger.tipPosition();
    
    PVector handFinger = new PVector(handPosition.getX() - position.getX(),
                                     handPosition.getY() - position.getY(),
                                     position.getZ() - handPosition.getZ());
    
    PVector fingerVect = new PVector( this.mHand.x + handFinger.x,
                                      this.mHand.y + handFinger.y,
                                      this.mHand.z + handFinger.z);                               
    this.mFingersData.add(fingerVect);
  }
}

void drawFingers(PGraphics pgr)
{
  if ( this.mFingersData != null){
    pgr.strokeWeight(4);
    for( int i =0; i<this.mFingersData.size(); ++i){
      pgr.pushMatrix();
      pgr.line(mHand.x, mHand.y, mHand.z,
               this.mFingersData.get(i).x, this.mFingersData.get(i).y, this.mFingersData.get(i).z);
               
               //Draw sphere for finger's top
               pgr.translate(this.mFingersData.get(i).x,
                             this.mFingersData.get(i).y,
                             this.mFingersData.get(i).z);
               pgr.sphere(7);
               pgr.fill(0);
               pgr.popMatrix();
    }
    pgr.strokeWeight(1);
  }
}
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
