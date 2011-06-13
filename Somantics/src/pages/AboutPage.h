/**
 * AboutPage.h
 * ReacticklesMagic
 *
 * Created by Marek Bereza on 27/04/2011.
 *
 */

#include "Reactickle.h"
#include "ImageCache.h"
#include "constants.h"

class AboutPage: public Reactickle {
public:
	void setup() {
		aboutImage = ImageCache::getImage(IMAGE_ROOT + "about.png");
		if(IPAD) {
			bgImage = ImageCache::getImage("img/bgIPad.png");
		} else if(HI_RES) {
			bgImage = ImageCache::getImage("img/bgIPhone4.png");
		} else {
			bgImage = ImageCache::getImage("img/bgIPhone.png");
		}
		logo = ImageCache::getImage(IMAGE_ROOT + "logo.png");
	}
	
	void start() {

	}
	
	void draw() {
		ofSetHexColor(0xFFFFFF);
		bgImage->draw(0, 0, ofGetWidth(), ofGetHeight());
		logo->draw(WIDTH/2, HEIGHT - 20);
		aboutImage->draw(10, 10);
		Container::draw();
		
	}
	ofImage *aboutImage;
	ofImage *logo;
	ofImage *bgImage;
};