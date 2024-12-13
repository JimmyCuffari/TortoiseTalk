// FastDDSUser.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "UserChatPublisher.hpp"
#include "UserChatSubscriber.hpp"
#include "Globals.hpp"

#include <iostream>
#include <vector>
#include <thread>
#include <atomic>
#include <cstdint>  
#include <functional>

// For colors
#ifdef _WIN32
#include <windows.h>
#else
#include <unistd.h>
#include <cstdio>
#endif


/*
void setTextColor(Color color) {
#ifdef _WIN32
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    SetConsoleTextAttribute(hConsole, static_cast<int>(color));
#else
    std::cout << "\033[" << static_cast<int>(color) << "m";
#endif
}

void resetTextColor() {
#ifdef _WIN32
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    SetConsoleTextAttribute(hConsole, 7);
#else
    std::cout << "\033[0m";
#endif
}
*/

extern "C"{

std::vector<std::string> endThreadSignal;  // Lets threads know to end
//std::vector<std::string> curr_chat_tab = {};    // Tells which tabbed user is currently being talked to (option 3)
std::string curr_chat_tab = "";

std::vector<std::vector<std::string>> chat_histories = {};

std::vector<std::string> send_message = {};

// Class for representing a Subscriber
class sub_thread {
private:
    UserChatSubscriber* user_sub;
    std::string sub_topic;
    std::thread st;
    int history_index;
    //std::vector<std::string>* curr_history;
    //std::vector<std::string>* end_signal;
    //std::vector<std::string>* curr_tab;

public:
    sub_thread(std::string sub_topic, int index) {
        this->history_index = index;
        this->sub_topic = sub_topic;
        user_sub = new UserChatSubscriber(sub_topic, history_index);
        user_sub->init();
        user_sub->setTopicName(sub_topic);
        st = std::thread(&sub_thread::run, this, sub_topic);
        
        std::cout << "subthread constructor" << std::endl;
    }

    void run(std::string topic) {
        user_sub->run(topic);
    }

    UserChatSubscriber* getSub() {
        return user_sub;
    }

    std::thread* getThread() {
        return &st;
    }

    int getHistoryIndex() {
        return history_index;
    }
};

// Class for representing a Publisher
class pub_thread {
private:
    UserChatPublisher* user_pub;
    std::string pub_topic;
    std::thread pt;
    //std::vector<std::string>* curr_history;
    int history_index;

public:
    pub_thread(std::string pub_topic, std::string name, int index) { 
        history_index = index;
        this->pub_topic = pub_topic;
        user_pub = new UserChatPublisher(pub_topic, name, history_index);
        user_pub->init();
        pt = std::thread(&pub_thread::run, this);

        std::cout << "pubthread constructor" << std::endl;
    }


    void run() {
        user_pub->run();
    }

    void end() {
        endThreadSignal.push_back(pub_topic);
        pt.join();
        endThreadSignal.clear();
    }

    UserChatPublisher* getPub() {
        return user_pub;
    }

    std::thread* getThread() {
        return &pt;
    }

    int getHistoryIndex() {
        return history_index;
    }
};

std::vector<pub_thread> pubs = {};
std::vector<sub_thread> subs = {};
std::vector<std::string> threaded_usernames = {};
std::string username = "a";

void setUsername(char* name){
    std::string str(name);
    username = str;
    std::cout << "heyo" << std::endl;
}

// Find index of element in vector
int findIndex(std::vector<std::string> vector, std::string search) {
    auto f = std::find(vector.begin(), vector.end(), search);

    if (f != vector.end()) {
        return f - vector.begin();
    }
    else {
        return -1;
    }
}

bool getCurrentUserStatus(int index) {
    bool user_status;

    index -= 1; // Dart is one ahead
    user_status = pubs.at(index).getPub()->getStatus();

    return user_status;
}

// View users currently added
void viewUsers(std::vector<std::string>& threaded_usernames, std::vector<pub_thread>& pubs) {
    std::cout << std::endl << "These are the users you are currently connected to:" << std::endl;

    int i = 0;
    for (std::string& user : threaded_usernames) {
        bool curr_status = pubs.at(i).getPub()->getStatus();
        std::string str = "";

        if (curr_status) str = "online";
        else str = "offline";

        std::cout << "  " + user + " (" + str + ")" << std::endl;

        i++;
    }
}

//std::function<void(const char*)> dartCallback = nullptr;
CallbackFunction receiveCallback = nullptr;
//Dart_Port receivePort;

//callbackNative(const char* message, const char* username, int *pic)
void callbackNative(const char* message, const char* username, const long* pic) {
    if (receiveCallback) {
        //receiveCallback(message, username, pic);
        receiveCallback(message, username, pic);
    } else {
        std::cout << "No callback is currently set." << std::endl;
    }
}
StatusCallbackFunction statusReceiveCallback = nullptr;
//Dart_Port receivePort;

void statusCallbackNative(const bool* isActive, const int* userIndex) {
    if (statusReceiveCallback) {
        statusReceiveCallback(isActive, userIndex);
    } else {
        std::cout << "No callback is currently set." << std::endl;
    }
}

void receiveDart(const char* message) {
    if (receiveCallback) {
        //receiveCallback(message);
        /*Dart_CObject msg;
        msg.type = Dart_CObject_kString;
        msg.value.as_string = "HELLO WORK!!!";
        Dart_PostCObject_DL(receivePort, &msg);*/
        //Dart_PostCObject;
    } else {
        std::cout << "No callback is currently set." << std::endl;
    }
}

/*void setDartCallback(std::function<void(const char*)> callback) {
    dartCallback = callback;
}*/

/*void setDartReceivePort(Dart_Port port) {
    receivePort = port;

    std::cout << "Successfully set port!" << std::endl;
}*/

// Sets function to run in dart
void setDartReceiveCallback(CallbackFunction callback) {
    receiveCallback = callback;
}

void statusReceiveDart(const char* message) {
    if (receiveCallback) {
        //receiveCallback(message);
        /*Dart_CObject msg;
        msg.type = Dart_CObject_kString;
        msg.value.as_string = "HELLO WORK!!!";
        Dart_PostCObject_DL(receivePort, &msg);*/
        //Dart_PostCObject;
    } else {
        std::cout << "No callback is currently set." << std::endl;
    }
}

void setDartStatusReceiveCallback(StatusCallbackFunction callback) {
    statusReceiveCallback = callback;
}




void setSendMessage(char *user, char *msg) {
    //send_message = message;
    std::string sendUser(user);
    std::string message(msg);

    std::cout << "User is " + sendUser + ". Set Message to \"" + message + "\"" << std::endl;

    std::string send_topic = username + "_" + sendUser;

    send_message.push_back(send_topic);
    send_message.push_back(message);
}

void setCurrTab(char *user) {
    std::string tab(user);
    std::cout << "Tab String: " + tab << std::endl;

    curr_chat_tab = tab + "_" + username;
    std::cout << "Current tab: " + curr_chat_tab << std::endl;
}

void setPicture(int *pic){
    picture = (long)pic;
}

// Add new user
void addUser(std::vector<pub_thread>& pubs, std::vector<sub_thread>& subs, std::vector<std::string>& threaded_usernames, std::string username, std::string new_user) {
/*
    while (true) {
        std::cout << std::endl << "Enter new user: ";
        std::getline(std::cin, new_user);

        if (new_user.find(" ") != std::string::npos) {
            std::cout << "Enter a valid username." << std::endl;

            new_user = "";
        }
        else {
            if (new_user == username) {
                std::cout << "You can't add yourself. Try again." << std::endl;
            }
            else if (findIndex(threaded_usernames, new_user) != -1) {
                std::cout << "You can't add a user you already added." << std::endl;
            }
            else {
                break;
            }
        }
    }
*/

    std::vector<std::string> temp_history = {};
    chat_histories.push_back(temp_history);

    //pub_thread pub(username + "_" + new_user, username, chat_histories.at(chat_histories.size()-1), endThreadSignal);
    pub_thread pub(username + "_" + new_user, username, chat_histories.size()-1);
    sub_thread sub(new_user + "_" + username, chat_histories.size() - 1);

    pubs.push_back(std::move(pub)); 
    subs.push_back(std::move(sub));
    threaded_usernames.push_back(new_user);

    std::cout << "Successfully added " + new_user + "." << std::endl;

}

// Remove user
void removeUser(int index, std::vector<pub_thread>& pubs, std::vector<sub_thread>& subs, std::vector<std::string>& threaded_usernames, std::string username, std::vector<std::vector<std::string>>& chat_histories) {
    /*int index = findIndex(threaded_usernames, removed_user);

    if (index == -1) {
        std::cout << "Error: User was not found." << std::endl;
        return;
    }*/
    std::string removed_user = threaded_usernames.at(index);
    std::cout << "Currently removing user: " << removed_user << std::endl;

    threaded_usernames.erase(threaded_usernames.begin() + index);

    std::string temp_pub_topic = username + "_" + removed_user;
    std::string temp_sub_topic = removed_user + "_" + username;

    endThreadSignal.push_back(temp_pub_topic);
    endThreadSignal.push_back(temp_sub_topic);

    std::cout << "Topics to remove: " << temp_pub_topic << " and " << temp_sub_topic << std::endl;

    if (pubs.at(index).getThread()->joinable()) {
        pubs.at(index).getThread()->join();
    }

    std::cout << "erased pub" << std::endl;

    if (subs.at(index).getThread()->joinable()) {
        subs.at(index).getThread()->join();
    }

    std::cout << "erased sub" << std::endl;

    delete pubs.at(index).getPub();
    delete subs.at(index).getSub();

    pubs.erase(pubs.begin() + index);
    subs.erase(subs.begin() + index);

    chat_histories.erase(chat_histories.begin() + index);

    endThreadSignal.clear();

    std::cout << removed_user + " has been successfully removed." << std::endl;
}

void dartRemoveUser(int index) {
    removeUser(index-1, pubs, subs, threaded_usernames, username, chat_histories);
    std::cout << "Exiting dart user remove..." << std::endl;
}

void createPublisher(char *user) {
    std::string newUser(user);

    //std::cout << "before" << std::endl;
    addUser(pubs, subs, threaded_usernames, username, newUser);
    //std::cout << "after" << std::endl;
    
    //receiveDart("Hey dart!");
}

// Home Menu
void printHomeMenu() {
    std::cout << std::endl << "Choose an option from below:" << std::endl;
    std::cout << "  1. View list of currently connected users." << std::endl;
    std::cout << "  2. Add a new user." << std::endl;
    std::cout << "  3. Chat with a user." << std::endl;
    std::cout << "  4. Remove a user." << std::endl;
    std::cout << "  5. Change color of text." << std::endl;
    std::cout << "  6. Exit the program." << std::endl << std::endl;
}

// Get login info
void getCredentials(std::string& username, std::string& password) {
    std::cout << "Please enter your login info below:" << std::endl << std::endl;

    std::cout << "Username: ";
    std::cin >> username;
    std::cin.ignore();

    std::cout << "Password: ";
    std::cin >> password;
    std::cout << std::endl;
    std::cin.ignore();
}

void chatUser(std::string username, std::string other_user, std::vector<std::string> threaded_usernames, std::vector<pub_thread>& pubs, std::vector<sub_thread>& subs, std::vector<std::vector<std::string>>& chat_histories) {
    int index = findIndex(threaded_usernames, other_user);

    if (index == -1) {
        std::cout << "Invalid username." << std::endl;
        return;
    }

    std::cout << std::endl << "Here's your current history with " + other_user + ":" << std::endl;

    std::vector<std::string> temp_history = chat_histories.at(pubs.at(index).getHistoryIndex());

    if (!temp_history.empty()) {
        for (std::string& str : temp_history) {
            std::cout << str << std::endl;
        }
    }
    else {
        std::cout << "This is the start of your history with " + other_user + "." << std::endl;
    }

    std::cout << std::endl;

    //curr_chat_tab.at(0) = "in";
    //curr_chat_tab.at(1) = other_user + "_" + username;
    pubs.at(index).getPub()->setActive(true);   // Allows typing messages in Publisher
    while (pubs.at(index).getPub()->getActive() == true) {
    }

    //curr_chat_tab.at(0) = "";
    //curr_chat_tab.at(1) = "";

    std::cout << "Leaving chat with " + other_user + "." << std::endl;
}



void killThreads(){
  //  end_signal->push_back(pub_topic);
  //  pt.join();


for (int index = 0; index < pubs.size(); index++) {
    std::string removed_user = threaded_usernames.at(index);
    std::cout << "Currently removing user: " << removed_user << std::endl;


    std::string temp_pub_topic = username + "_" + removed_user;
    std::string temp_sub_topic = removed_user + "_" + username;

    endThreadSignal.push_back(temp_pub_topic);
    endThreadSignal.push_back(temp_sub_topic);

    std::cout << "Topics to remove: " << temp_pub_topic << " and " << temp_sub_topic << std::endl;

    if (pubs.at(index).getThread()->joinable()) {
        pubs.at(index).getThread()->join();
    }

    std::cout << "erased pub" << std::endl;

    if (subs.at(index).getThread()->joinable()) {
        subs.at(index).getThread()->join();
    }

    std::cout << "erased sub" << std::endl;

    delete pubs.at(index).getPub();
    delete subs.at(index).getSub();

    endThreadSignal.clear();

    std::cout << removed_user + " has been successfully removed." << std::endl;
    }

    std::cout << "End all removal" << std::endl;

   
}


/*
void changeColor() {
    std::cout << std::endl << "Which color would you like to choose?" << std::endl;

    setTextColor(Color::DEFAULT_WHITE);
    std::cout << "  1. Default White" << std::endl;
    //setTextColor(Color::BLACK);
    //std::cout << "  2. Black" << std::endl;
    setTextColor(Color::BLUE);
    std::cout << "  2. Blue" << std::endl;
    setTextColor(Color::GREEN);
    std::cout << "  3. Green" << std::endl;
    setTextColor(Color::CYAN);
    std::cout << "  4. Cyan" << std::endl;
    setTextColor(Color::RED);
    std::cout << "  5. Red" << std::endl;
    setTextColor(Color::MAGENTA);
    std::cout << "  6. Magenta" << std::endl;
    setTextColor(Color::YELLOW);
    std::cout << "  7. Yellow" << std::endl;
    setTextColor(Color::WHITE);
    std::cout << "  8. White" << std::endl;

    resetTextColor();

    int option = 0;
    std::cout << std::endl << "Select an option: ";
    std::cin >> option;
    std::cin.ignore();

    std::cout << std::endl;

    switch (option) {
    case 1:
        setTextColor(Color::DEFAULT_WHITE);
        std::cout << "You're display is now set to Default White" << std::endl;
        break;
    case 2:
        setTextColor(Color::BLUE);
        std::cout << "You're display is now set to Blue" << std::endl;
        break;
    case 3:
        setTextColor(Color::GREEN);
        std::cout << "You're display is now set to Green" << std::endl;
        break;
    case 4:
        setTextColor(Color::CYAN);
        std::cout << "You're display is now set to Cyan" << std::endl;
        break;
    case 5:
        setTextColor(Color::RED);
        std::cout << "You're display is now set to Red" << std::endl;
        break;
    case 6:
        setTextColor(Color::MAGENTA);
        std::cout << "You're display is now set to Magenta" << std::endl;
        break;
    case 7:
        setTextColor(Color::YELLOW);
        std::cout << "You're display is now set to Yellow" << std::endl;
        break;
    case 8:
        setTextColor(Color::WHITE);
        std::cout << "You're display is now set to White" << std::endl;
        break;
    default:
        std::cout << "That's not a color." << std::endl;
    }
}
*/

int main()
{

    /*
    curr_chat_tab.push_back("");
    curr_chat_tab.push_back("");

    std::vector<pub_thread> pubs = {};
    std::vector<sub_thread> subs = {};
    std::vector<std::vector<std::string>> chat_histories = {};

    std::vector<std::string> threaded_usernames = {};

    std::string username = "";
    std::string password = "";

    std::cout << "Fast-DDS Chat" << std::endl;
    std::cout << "----------------------------" << std::endl;

    getCredentials(username, password);

    std::cout << "----------------------------" << std::endl << std::endl;

    std::cout << "Welcome, " + username + ". Your password is " + password + "." << std::endl;

    while (true) {ric_limits<std::streamsize>::max(), '\n');
                std::cout << "Invalid input. Please try again: ";
            }
            else {
                break;
            }
        }

        if (option == 1) {
            if (!threaded_usernames.empty()) {
                viewUsers(threaded_usernames, pubs);
            }
            else {
                std::cout << std::endl << "You have no Users added yet." << std::endl;
            }
        }
        else if (option == 2) {
            addUser(pubs, subs, threaded_usernames, username, chat_histories);
        }
        else if (option == 3) {
            std::string to_chat = "";

            std::cout << std::endl << "What user would you like to chat to: ";
            std::cin >> to_chat;
            std::cin.ignore();

            if (to_chat == username) {
                std::cout << "Invalid username: can't talk to yourself." << std::endl;
            }
            else {
                chatUser(username, to_chat, threaded_usernames, pubs, subs, chat_histories);
            }
        }
        else if (option == 4) {
            std::string to_remove = "";

            std::cout << std::endl << "What user would you like to remove: ";
            std::cin >> to_remove;
            std::cin.ignore();

            removeUser(pubs, subs, threaded_usernames, to_remove, username, chat_histories);
        }
        else if (option == 5) break;//changeColor();
        else if (option == 6) break;
        else {
            std::cout << std::endl << "That's not an option. Try again. (1-5)" << std::endl;
        }
    }

    // Clean up threads
    for (int i = 0; i < pubs.size(); i++) {
        std::string removed_user = threaded_usernames.at(i);

        std::string temp_pub_topic = username + "_" + removed_user;
        std::string temp_sub_topic = removed_user + "_" + username;

        endThreadSignal.push_back(temp_pub_topic);
        endThreadSignal.push_back(temp_sub_topic);

        pubs.at(i).getThread()->join();
        subs.at(i).getThread()->join();
    }

    std::cout << std::endl << "Thanks for chatting." << std::endl;

    //resetTextColor();
}
*/
}
}