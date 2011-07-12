/**
 * ReactickleApp.cpp
 * ReacticklesMagic
 *
 * Created by Marek Bereza on 26/04/2011.
 *
 */

#include "ReactickleApp.h"
#include "util.h"
#include "constants.h"

ReactickleApp *ReactickleApp::instance;

void ReactickleApp::setupApp(ReactickleApp *instance, string appName) {
	APP_NAME = appName;
	this->instance = instance;
	
	currentApp = NULL;
	gain = 1;
	crossFadeStartTime = -100;
	volumeThreshold = 0.3;
	
	setupGraphics();
	setupOrientation();
#ifdef TARGET_OF_IPHONE
	// register touch events
	ofAddListener(ofEvents.touchDown, this, &ReactickleApp::touchDown);
	ofAddListener(ofEvents.touchMoved, this, &ReactickleApp::touchMoved);
	ofAddListener(ofEvents.touchUp, this, &ReactickleApp::touchUp);
	
	// initialize the accelerometer
	ofxAccelerometer.setup();
	
	//iPhoneAlerts will be sent to this.
	ofxiPhoneAlerts.addListener(this);
#else
	setDataPathRootToAppContents();
#endif
	
	ofSoundStreamSetup(0, 1, this, 44100, 1024, 1);
}









void ReactickleApp::switchReactickle(Reactickle *reactickle) {
	if(currentApp!=NULL) {
		currentApp->stop();
	}
	// take care of previous reactickle - i.e. delete it if it's an actual reactickle
	if(isReactickle(currentApp)) {
		delete currentApp;
		currentApp = NULL;
	}
	
	
	// start the new one
	currentApp = reactickle;
	if(isReactickle(currentApp)) {
		currentApp->setup();
		backButton.setHoldMode(true);
		startCrossFade(true);
		
	} else {
		backButton.setHoldMode(false);
	}
	
	currentApp->start();
	
}

void ReactickleApp::startCrossFade(bool fadeIn) {
	fadingIn = fadeIn;
	crossFadeStartTime = ofGetElapsedTimef();
}


#ifndef TARGET_OF_IPHONE
void ReactickleApp::mouseDragged(int x, int y, int button) {
	ofTouchEventArgs touch;
	touch.x = x;
	touch.y = y;
	touch.id = button;
	this->touchMoved(touch);
}
void ReactickleApp::mousePressed(int x, int y, int button) {
	ofTouchEventArgs touch;
	touch.x = x;
	touch.y = y;
	touch.id = button;
	this->touchDown(touch);
}
void ReactickleApp::mouseReleased(int x, int y, int button) {
	ofTouchEventArgs touch;
	touch.x = x;
	touch.y = y;
	touch.id = button;
	this->touchUp(touch);
}




#endif


//--------------------------------------------------------------
void ReactickleApp::touchDown(ofTouchEventArgs &touch){
	if(currentApp!=mainMenu) {
		if(backButton.touchDown(touch.x, touch.y, touch.id)) {
			return;
		}
	}
	currentApp->touchDown(touch.x, touch.y, touch.id);
}

//--------------------------------------------------------------
void ReactickleApp::touchMoved(ofTouchEventArgs &touch){
	if(currentApp!=mainMenu) {
		if(backButton.touchMoved(touch.x, touch.y, touch.id)) {
			return;
		}
	}
	currentApp->touchMoved(touch.x, touch.y, touch.id);
}

//--------------------------------------------------------------
void ReactickleApp::touchUp(ofTouchEventArgs &touch){
	if(currentApp!=mainMenu) {
		if(backButton.touchUp(touch.x, touch.y, touch.id)) {
			return;
		}
	}
	currentApp->touchUp(touch.x, touch.y, touch.id);
}

//--------------------------------------------------------------
void ReactickleApp::lostFocus(){
	
}

//--------------------------------------------------------------
void ReactickleApp::gotFocus(){
	
}

//--------------------------------------------------------------
void ReactickleApp::gotMemoryWarning(){
	
}

//--------------------------------------------------------------
void ReactickleApp::deviceOrientationChanged(int newOrientation){
	
}
void ReactickleApp::setupGraphics() {
	ofEnableNormalizedTexCoords();
	ofBackground(0, 0, 0);
	ofSetFrameRate(30.f);
	ofEnableAlphaBlending();
	ofSetVerticalSync(true);
}


void ReactickleApp::updateOrientation() {
#ifdef TARGET_OF_IPHONE
	int orientation = [[UIDevice currentDevice] orientation];
	int orient = iPhoneGetOrientation();
	//printf("Phone orientation: %d, window orientation %d\n", orientation, orient);
	
	if(orientation!=currOrientation || orient==OFXIPHONE_ORIENTATION_PORTRAIT || orient==OFXIPHONE_ORIENTATION_UPSIDEDOWN) {
		if(orientation==UIDeviceOrientationLandscapeLeft) {
			iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_LEFT);
		} else if(orientation==UIDeviceOrientationLandscapeRight) {
			iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
		}
	}
	
	currOrientation = orientation;
#endif
}


void ReactickleApp::audioReceived( float * input, int bufferSize, int nChannels ) {
	// samples are "interleaved"
	float max = 0;
	
	for (int i = 0; i < bufferSize; i++){
		float val = gain*ABS(input[i]);
		if(val>max) max = val;
	}
	
	if(max>volume) volume = max;
	else volume *= 0.96;
	
	if(currentApp!=NULL) {
		//volume *= gain;
		currentApp->audioReceived(input, bufferSize, nChannels);
	}
}


void ReactickleApp::exit(){
#ifdef TARGET_OF_IPHONE
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
#endif
}

void ReactickleApp::setupOrientation() {
#ifdef TARGET_OF_IPHONE
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	int orientation = [[UIDevice currentDevice] orientation];
	
	
	if(orientation==UIDeviceOrientationLandscapeLeft) {
		iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
	} else if(orientation==UIDeviceOrientationLandscapeRight) {
		iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_LEFT);
	} else { // default
		iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_LEFT);
	}
	
	currOrientation = UIDeviceOrientationPortrait;	
#endif
}