%{
/*
 * C declarations
 */
#include <cstdio>
#include <iostream>
#include <list>
#include <stdio.h>
#include <string.h>
#include "Strings.h"

using namespace std;

extern "C" {
  extern int yylex(void);
  void yyerror(const char *str);
  int yyparse(void);
  int yywrap(void);
  extern FILE *yyin;
}

extern int lineNum;

char* strMerge(char* str1, char* str2);
void reverseString(char* str);

// Sentence's container
SentenceList sList;

Sentence* newSentence(char* name);
Sentence* setSentence(char* name, char* content);
Sentence* appendSentence(char* name, char* content);
Sentence* reverse(char* name);
Sentence* reverseWords(char* name);
Sentence* getSentence(char* name);
char* getContent(char* name);

void println(char* name);
void println(Sentence* s);
void printlnLength(char* name);
void printlnWordCount(char* name);
void printlnWords(char* name);

void listln();

void sentenceListRelease();
void exit();

%}
/*
 * Bison declarations
 */
%union {
  char* strVal;
}

%token <strVal> DIGIT 
%token <strVal> LETTER 
%token <strVal> PUNCTUATION 
%token <strVal> SPACE 
%token <strVal> TAB 
%token <strVal> MARK_COMMA 
%token <strVal> MARK_FULL_STOP 
%token <strVal> MARK_COLON 
%token <strVal> MARK_SEMICOLON 
%token <strVal> MARK_QUESTION 
%token <strVal> MARK_EXCLAMATORY

%token NEW_LINE 
%token DOUBLE_QUOTATION 
%token ADD

%token SET 
%token APPEND 
%token REVERSE 
%token REVERSE_WORDS
%token PRINT 
%token PRINT_LENGTH 
%token PRINT_WORD_COUNT 
%token PRINT_WORDS 
%token LIST 
%token EXIT

%type <strVal> expression 
%type <strVal> value 
%type <strVal> appendValues 
%type <strVal> appendValue 
%type <strVal> identifier 
%type <strVal> alphanums 
%type <strVal> alphanum 
%type <strVal> literals 
%type <strVal> literal 
%type <strVal> punctuation 
%type <strVal> blank

%%
/*
 * Grammar rules
 */

program:
  statements
  ;

statements:
  statements statement
  | statement
  ;

statement:
  declare MARK_SEMICOLON
  | blank
  | NEW_LINE
  ;
  
declare:
  EXIT {exit();}
  | SET SPACE identifier SPACE expression {setSentence($3, $5);}
  | APPEND SPACE identifier SPACE expression {appendSentence($3, $5);}
  | REVERSE SPACE identifier {reverse($3);}
  | REVERSE_WORDS SPACE identifier {reverseWords($3);}
  | PRINT SPACE identifier {println($3);}
  | PRINT_LENGTH SPACE identifier {printlnLength($3);}
  | PRINT_WORD_COUNT SPACE identifier {printlnWordCount($3);}
  | PRINT_WORDS SPACE identifier {printlnWords($3);}
  | LIST {listln();}
  ;

expression:
  value appendValues {strcpy($$, strMerge($1, $2));}
  | value {$$ = $1;}
  ; 

appendValues:
  appendValues appendValue {strcpy($$, strMerge($1, $2));}
  | appendValue {$$ = $1;}
  ;

appendValue:
  ADD value {$$ = $2;}
  ;
  
value:
  DOUBLE_QUOTATION literals DOUBLE_QUOTATION {$$ = $2;}
  | identifier {$$ = getContent($1);}
  ;

literals:
  literals literal {$$ = strcat($1, $2);}
  | literal {$$ = $1;}
  ;

literal:
  alphanum {$$ = $1;}
  | punctuation {$$ = $1;}
  | blank {$$ = $1;}
  ;

punctuation:
  MARK_COMMA {$$ = $1;}
  | MARK_FULL_STOP {$$ = $1;}
  | MARK_COLON {$$ = $1;}
  | MARK_SEMICOLON {$$ = $1;}
  | MARK_QUESTION {$$ = $1;}
  | MARK_EXCLAMATORY {$$ = $1;}
  ;

identifier:
  LETTER alphanums {$$ = strcat($1, $2);}
  | LETTER {$$ = $1;}
  ;

alphanums:
  alphanums alphanum {$$ = strcat($1, $2);}
  | alphanum {$$ = $1;}
  ;

alphanum:
  LETTER {$$ = $1;}
  | DIGIT {$$ = $1;}
  ;

blank:
  SPACE {$$ = $1;}
  | TAB {$$ = $1;}
  ;
  
%%
/*
 * Additional C++ code
 */

int yywrap(void) {
	return 1;
}

void yyerror(const char *str) {
	cout << "Parse error on line: " << lineNum << "! Message: " << str << endl;
	exit(1);
}

/*
 * Entry function.
 */
main() {
	// Test by a commend-file
	FILE *testFile = fopen("test.txt", "r");
	if (!testFile) {
		cout << "Cannot open test.txt!" << endl;
		return 0;
	}

	// Set flex to read from it instead of defaulting to STDIN:
	yyin = testFile;

	// Parse through the input until there is no more
	do {
		yyparse();
	}while (!feof(yyin));

	return 0;
}

/*
 * Return a new string by merging two string.
 */
char* strMerge(char* str1, char* str2) {
	char* ret = strdup(str1);
	strcat(ret, str2);
	return ret;
}

/*
 * Return a new sentence by a given name.
 */
Sentence* newSentence(char* name) {
	Sentence* ret = new Sentence(name);
	// Add the new sentence into container
	sList.push_back(ret);
	return ret;
}

/*
 * Get the sentence by a given name, and set its content.
 */
Sentence* setSentence(char* name, char* content) {
	Sentence* ret = getSentence(name);

	// Create a new sentence if the sentence did not exist in the container
	if (ret == NULL) {
		ret = newSentence(name);
	}

	ret->content = strdup(content);

	return ret;
}

/*
 * Get the sentence by a given name, and append its content
 */
Sentence* appendSentence(char* name, char* content) {
	Sentence* ret = getSentence(name);

	if (ret != NULL) {
		if (ret->content == NULL) {
			ret->content = strdup(content);
		} else {
			strcat(ret->content, content);
		}
	} else {
		cout << "# Cannot find " << name << endl;
	}

	return ret;
}

/*
 * Get the sentence by a given name, and reverse its content.
 */
Sentence* reverse(char* name) {
	Sentence* ret = getSentence(name);

	if (ret != NULL) {
		reverseString(ret->content);
	} else {
		cout << "# Cannot find " << name << endl;
	}

	return ret;
}

/*
 * Reverse words.
 */
Sentence* reverseWords(char* name) {
	Sentence* ret = getSentence(name);

	if (ret != NULL) {
		char* cTemp = strdup(ret->content);
		// chars for splitting two word
		char* split = strdup(" ,.:;?!");

		list<char*> wordList;
		char* word = strtok(cTemp, split);
		while (word != NULL) {
			wordList.push_front(word);
			word = strtok(NULL, split);
		}

		if (wordList.size() > 0) {
			list<char*>::iterator it = wordList.begin();
			char* firstWord = *it;
			char* newContent = strdup(firstWord);
			for (++it; it != wordList.end(); ++it) {
				char* w = *it;
				strcat(newContent, " ");
				strcat(newContent, w);
			}

			ret->content = newContent;
		}
	} else {
		cout << "# Cannot find " << name << endl;
	}

	return ret;
}

/*
 * Reverse a str.
 */
void reverseString(char* str) {
	char* strTemp = strdup(str);

	for (strTemp = strchr(str, 0) - 1; str < strTemp; ++str, --strTemp) {
		std::swap(*str, *strTemp);
	}
}

/*
 * Get a sentence by a given name.
 */
Sentence* getSentence(char* name) {
	Sentence* ret = NULL;

	SentenceList::iterator it;
	for (it = sList.begin(); it != sList.end(); ++it) {
		Sentence* s = *it;

		if (strcmp(s->name, name) == 0) {
			// Same name
			ret = s;
		}
	}

	return ret;
}

/*
 * Get a sentence's content by a given name.
 */
char* getContent(char* name) {
	char* ret = NULL;

	SentenceList::iterator it;
	for (it = sList.begin(); it != sList.end(); ++it) {
		Sentence* s = *it;

		if (strcmp(s->name, name) == 0) {
			// Same name
			ret = strdup(s->content);
		}
	}

	if (ret == NULL) {
		// Cannot file the sentence
		cout << "Cannot find " << name << endl;
		ret = strdup("");
	}

	return ret;
}

/*
 * Print a sentence by a given name.
 */
void println(char* name) {
	Sentence* s = getSentence(name);
	if (s != NULL) {
		cout << s->name << ": " << "\"" << s->content << "\"" << endl;
	} else {
		cout << "# Cannot find " << name << endl;
	}
}

/*
 * Print the sentence.
 */
void println(Sentence* s) {
	if (s != NULL) {
		cout << s->name << ": " << "\"" << s->content << "\"" << endl;
	} else {
		cout << "# Cannot find it" << endl;
	}
}

/*
 * Print a sentence's length by a given name.
 */
void printlnLength(char* name) {
	Sentence* s = getSentence(name);
	if (s != NULL) {
		int length = 0;
		if (s->content != NULL) {
			length = strlen(s->content);
		}
		cout << "Length of " << s->name << " is: " << length << endl;
	} else {
		cout << "# Cannot find " << name << endl;
	}
}

/*
 * Print a sentence's word count by a given name.
 */
void printlnWordCount(char* name) {
	Sentence* s = getSentence(name);

	if (s != NULL) {
		char* cTemp = strdup(s->content);
		// chars for splitting two word
		char* split = strdup(" ,.:;?!");

		int count = 0;
		char* word = strtok(cTemp, split);
		while (word != NULL) {
			count++;
			word = strtok(NULL, split);
		}

		cout << "Wordcount of " << name << "is: " << count << endl;
	} else {
		cout << "# Cannot find " << name << endl;
	}
}

/*
 * Print a sentence's words by a given name.
 */
void printlnWords(char* name) {
	Sentence* s = getSentence(name);

	cout << "Words of " << name << " are: " << endl;
	if (s != NULL) {
		char* cTemp = strdup(s->content);
		// chars for splitting two word
		char* split = strdup(" ,.:;?!");

		char* word = strtok(cTemp, split);
		while (word != NULL) {
			cout << word << endl;
			word = strtok(NULL, split);
		}
	} else {
		cout << "# Cannot find " << name << endl;
	}
}

/*
 * Print the sentence's container.
 */
void listln() {
	int size = sList.size();
	cout << "Identifier list (" << size << "):" << endl;

	if (size > 0) {
		SentenceList::iterator it;
		for (it = sList.begin(); it != sList.end(); ++it) {
			Sentence* s = *it;
			println(s);
		}
	}
}

/*
 * Release the sentence's container.
 */
void sentenceListRelease() {
	SentenceList::iterator it = sList.begin();
	for (it = sList.begin(); it != sList.end(); ++it) {
		Sentence* s = *it;
		if (s != NULL) {
			delete (s);
			s = NULL;
		}
	}

	sList.clear();
}

/*
 * Exit function.
 */
void exit() {
	sentenceListRelease();
	cout << "# Program exit" << endl;
	exit(0);
}