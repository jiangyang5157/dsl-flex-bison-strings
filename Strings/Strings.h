/*
 * Strings.h
 *
 *  Created on: 2013Äê9ÔÂ28ÈÕ
 *      Author: JiangYang
 */

#include <list>
#include <iostream>

#ifndef STRINGS_H_
#define STRINGS_H_

class Sentence;

typedef std::list<Sentence*> SentenceList;

class Sentence {

public:
	char* name;
	char* content;

	Sentence(char* name) :
			name(name) {
		//std::cout << "Constructor" << std::endl;
	}

	~Sentence() {
		//std::cout << "Destructor" << std::endl;
		if (name != NULL) {
			delete (name);
			name = NULL;
		}

		if (content != NULL) {
			delete (content);
			content = NULL;
		}
	}
};

#endif /* STRINGS_H_ */
