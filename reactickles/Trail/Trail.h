/**
 * Trail.h
 * magic
 *
 * Created by Marek Bereza on 11/04/2011.
 *
 */
#include "Reactickle.h"
#include "TrailParticle.h"
#define SPAWN_RATE 1
#define MAX_NUM_PARTICLES 200
#include "ReactickleApp.h"

class Trail: public Reactickle {
public:
    void start();
	void update();
	void draw();

#ifndef TARGET_OF_IPHONE
	bool needsKinect() { return true; }
#endif
	virtual bool touchDown(float x, float y, int touchId);
	virtual bool touchMoved(float x, float y, int touchId);
	virtual bool touchUp(float x, float y, int touchId);
    
    virtual void modeChanged() {        
#ifndef TARGET_OF_IPHONE
        ofxOscMessage m;
        m.setAddress("/modechange");
        m.addIntArg( mode );
        ReactickleApp::instance->sender.sendMessage( m );
#endif
    }
    
    int getNumModes() {
		return 3;
	}
private:
	void spawn(ofVec2f pos, ofColor color);
	void collision(TrailParticle &bubble1, TrailParticle &bubble2);
	vector<TrailParticle> particles;
	int currShapeId;
    float timeOfLastInteraction;
};