#TortoiseTalk

All of these projects will not run unless OpenSSL is installed

FastDDS-Chat-Code is the folder for the command line version of the program, home it its code and executable

FastDDSFlutterRelease is the folder for the release executable of the GUI version of the program, the exe will allow the program to run. It is also necessary to input the ips of each of the computers to communicate to inside of the ip_lists file, keeping the comments at the top of the txt file so it can still run properly.

FlutterFastDDS is the flutter code. To run it in debug, the dynamic linking library (dll) file needs to be referenced correctly to run the c++ backend properly.
Its also required to build the c++ code in this version as well,
navigating ./lib/build and running 
cmake ..
then
cmake --build .
will generate the required files to open the project.