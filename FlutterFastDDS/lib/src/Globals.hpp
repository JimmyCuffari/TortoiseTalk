#ifndef GLOBALS_H
#define GLOBALS_H

#include <vector>

//typedef void (*CallbackFunction)(const char*, const char*, const int*);
typedef void (*CallbackFunction)(const char*, const char*, const long*);
typedef void (*StatusCallbackFunction)(const bool*, const int*);

//extern std::vector<std::string> endThreadSignal;
//extern std::vector<std::string> curr_chat_tab;

extern std::vector<std::string> endThreadSignal;  // Lets threads know to end
//extern std::vector<std::string> curr_chat_tab;    // Tells which tabbed user is currently being talked to (option 3)
extern std::string curr_chat_tab;
extern std::vector<std::vector<std::string>> chat_histories;
extern std::vector<std::string> send_message; // Message to send through Publisher
extern std::string receive_message;

extern long picture = 0;

extern CallbackFunction receiveCallback;
extern StatusCallbackFunction statusReceiveCallback;

extern "C" void receiveDart(const char*);
//extern "C" void callbackNative(const char*, const char*, const int*);
extern "C" void callbackNative(const char*, const char*, const long*);
extern "C" void statusCallbackNative(const bool*, const int*);


// for colors
#ifdef _WIN32
enum Color {
// Windows Color Values
DEFAULT_WHITE = 7,
//BLACK = 0,
BLUE = 1,
GREEN = 2,
CYAN = 3,
RED = 4,
MAGENTA = 5,
YELLOW = 14,
WHITE = 15,
};
#else
enum Color {
// Linux ANSI Codes
DEFAULT_WHITE = 0,
//BLACK = 30,
RED = 31,
GREEN = 32,
YELLOW = 33,
BLUE = 34,
MAGENTA = 35,
CYAN = 36,
WHITE = 37,
};
#endif

extern void setTextColor(Color color);
extern void resetTextColor();

#endif