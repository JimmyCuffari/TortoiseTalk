/**
 * @file UserChatPublisher.hpp
 */

#include "UserChatPubSubTypes.hpp";
#include "Globals.hpp"
#include <chrono>
#include <thread>
#include <string>
#include <atomic>
#include <ctime>
#include <fstream>

#include <fastdds/dds/domain/DomainParticipant.hpp>
#include <fastdds/dds/domain/DomainParticipantFactory.hpp>
#include <fastdds/dds/publisher/DataWriter.hpp>
#include <fastdds/dds/publisher/DataWriterListener.hpp>
#include <fastdds/dds/publisher/Publisher.hpp>
#include <fastdds/dds/topic/TypeSupport.hpp>

#include <fastdds/rtps/transport/TCPv4TransportDescriptor.hpp>

//std::vector<std::string> test = {};
//std::vector<std::string> endThreadSignal = {};

using namespace eprosima::fastdds::dds;

class UserChatPublisher {
private:
    UserChat user_message_;
    DomainParticipant* participant_;
    Publisher* publisher_;
    Topic* topic_;
    DataWriter* writer_;
    TypeSupport type_;

    std::atomic<bool> active;           // Whether Publisher is accepting input
    //std::atomic<bool> status;           // Whether Publisher is online or not (matched with subscriber)
    //std::vector<std::string>* history;  // Ongoing history of chat
    int history_index;

    std::string username;
    std::string topic_name;
    bool status;

    class PubListener : public DataWriterListener
    {
    private:
        UserChatPublisher* publisher_;
    public:
        PubListener(UserChatPublisher* publisher) : matched_(0), publisher_(publisher) {}
        ~PubListener() override {}

        void on_publication_matched(DataWriter*, const PublicationMatchedStatus& info) override {
            if (info.current_count_change == 1)
            {
                matched_ = info.total_count;
                std::cout << "Publisher matched." << std::endl;
                publisher_->setStatus(true);
//                statusCallbackNative(&publisher_->getStatus(), publisher_->getUsername().c_str());

            }
            else if (info.current_count_change == -1)
            {
                matched_ = info.total_count;
                std::cout << "Publisher unmatched." << std::endl;
                publisher_->setStatus(false);
 //               statusCallbackNative(&publisher_->getStatus(), publisher_->getUsername().c_str());
            }
            else {
                std::cout << info.current_count_change << " is not a valid value for PublicationMatchedStatus current count change." << std::endl;
            }
        }

        std::atomic_int matched_;
    } listener_;

public:
    UserChatPublisher(std::string topic_name, std::string name, int index)
        : participant_(nullptr)
        , publisher_(nullptr)
        , topic_(nullptr)
        , writer_(nullptr)
        , type_(new UserChatPubSubType())
        , listener_(this)
    {
        this->topic_name = topic_name;
        this->active.store(false);// = false;
        this->status = false;
        this->username = name;
        this->history_index = index;
    }

    virtual ~UserChatPublisher() {
        if (writer_ != nullptr)
        {
            publisher_->delete_datawriter(writer_);
        }
        if (publisher_ != nullptr)
        {
            participant_->delete_publisher(publisher_);
        }
        if (topic_ != nullptr)
        {
            participant_->delete_topic(topic_);
        }
        DomainParticipantFactory::get_instance()->delete_participant(participant_);
    }

    bool init()
    {
        user_message_.index(0);
        user_message_.username(username);

        DomainParticipantQos participantQos;
        participantQos.name("Participant_publisher");

        // Parse for IPs

        std::ifstream inputFile("./ip_list.txt");

        if (!inputFile) {
            std::cerr << "Could not open file!" << std::endl;
        }

        std::string line;

        // Skips first two lines
        std::getline(inputFile, line);
        std::getline(inputFile, line);

        while (std::getline(inputFile, line)) {
            eprosima::fastdds::rtps::Locator_t locator;
            eprosima::fastdds::rtps::IPLocator::setIPv4(locator, line);
            locator.port = 7412;
            participantQos.wire_protocol().builtin.initialPeersList.push_back(locator);
        }

        inputFile.close();

        // End IP stuff

        participant_ = DomainParticipantFactory::get_instance()->create_participant(0, participantQos);

        if (participant_ == nullptr)
        {
            return false;
        }

        type_.register_type(participant_);

        // Creates topic named after username to publish from
        topic_ = participant_->create_topic(topic_name, "UserChat", TOPIC_QOS_DEFAULT);

        if (topic_ == nullptr)
        {
            return false;
        }

        publisher_ = participant_->create_publisher(PUBLISHER_QOS_DEFAULT, nullptr);

        if (publisher_ == nullptr)
        {
            return false;
        }

        writer_ = publisher_->create_datawriter(topic_, DATAWRITER_QOS_DEFAULT, &listener_);

        if (writer_ == nullptr)
        {
            return false;
        }
        return true;
    }

    bool publish()
    {
        if (listener_.matched_ > 0)
        {
            user_message_.index(user_message_.index() + 1);
            writer_->write(&user_message_);
            return true;
        }
        return false;
    }

    // Whether to get input from user or not
    void setActive(bool set) {
        active.store(set);
    }

    bool getActive() {
        return active.load();
    }

    // Signals online or offline
    void setStatus(bool set) {
        //status.store(set);
        status = set;
    }

    bool& getStatus() {
        //return status.load();
        return status;
    }

    std::string& getUsername() {
        return user_message_.username();
    }

    void run()
    {
        uint32_t samples_sent = 0;
        setActive(false);
        while (true)
        {
            //std::cout << "RUNNIN=" << std::endl;
            //if (end_signal && std::find(end_signal->begin(), end_signal->end(), topic_name) != end_signal->end()) break;  // THIS IS BAD AINFI >:()
            if (std::find(endThreadSignal.begin(), endThreadSignal.end(), topic_name) != endThreadSignal.end()) break;
            //std::cout << "PUBLISHER TOPIC NAME: " << topic_name << std::endl;

            if(!send_message.empty())
            std::cout << "Topic Name: " << topic_name << " SendMessageat0: " <<  send_message.at(0) << std::endl;

            if (publish() && !send_message.empty() && send_message.at(0) == topic_name) {
                auto now = std::chrono::system_clock::now();
                std::time_t now_time = std::chrono::system_clock::to_time_t(now);
                std::tm local_time = *std::localtime(&now_time);
                std::string timestamp = std::asctime(&local_time);
                timestamp.pop_back();

                user_message_.picture(picture);
                user_message_.message(send_message.at(1));
                std::cout << "Message received from Publisher: \"" + send_message.at(1) + "\". Sent to " + send_message.at(0) + "." << std::endl;
                
            }
            
            send_message.clear();
            /*if (getActive()) {
                std::cout << "hello?" << std::endl;
                if (!getStatus()) {
                    std::cout << std::endl << "Other user is offline now. Last message discarded. Press any key to go back to main ui...";
                    getchar();

                    setActive(false);
                }
                else if (publish())
                {
                    std::string message = "";
                    std::string exit = "/exit";

                    std::getline(std::cin, message, '\n');

                    if (message == exit) {
                        setActive(false);

                        message = "";
                    }
                    else if (getStatus()){
                        user_message_.message(message);

                        std::string str = user_message_.username() + ": " + message;
                        chat_histories.at(history_index).push_back(str);
                    }
                }
            }*/

            std::this_thread::sleep_for(std::chrono::milliseconds(1000));
        }
    }
};