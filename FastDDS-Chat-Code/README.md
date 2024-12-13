# FastDDS_Chat

Things to install for cool DDS Tricks
- Visual Studio (With Desktop Development for C++)
- CMake
- Chocolatey
- OpenSSL
- FastDDS v3.0.1

How to have cool time :)
- In ./build/Debug/ip_lists.txt, it is required to input each ip of the users to have communication with. Deleting the comments at the top of the project will lead to the program to not work correctly.
- If FastDDSUser.exe does not run properly, follow the steps listed below to create a new build of the project
- If you have openssl installed, and it isn't rude, you can go into CMakeLists.txt and change the directories at the top to your install. Then delete CMakeCache and CMakeFiles, "cmake ..", "cmake --build ." inside of build folder.

If not :/
- In the build folder delete CMakeCache and CMakeFiles.
- While still in the build folder and in CMD, run "cmake ..". (it should yell at you about openssl)
- Go into the newly created CMakeCache and change the path of OPENSSL_INCLUDE_DIR:PATH= to the folder of your OpenSSL.
- Now run "cmake .." and "cmake --build ." If everything is cool, the exe for FastDDSUser will be in the build/debug folder. (elsewise I made an oversight :>)
