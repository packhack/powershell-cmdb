# piCMDB Script

A small Powershell Module which creates an SQLite Database and hold commands for History Reasons

## Requirements

SQLite .NET DLL Bundle is required: https://system.data.sqlite.org/index.html/doc/trunk/www/downloads.wiki

After pulling the Script, change the Path for the DLL and the Database. After this you can import the Module via 

~~~
import-module sqlite-cmdb.psm1
~~~

# Commands

*piInitDB* - Initial Creating of the Database

*piGetHistory* - get command History for Servers (you can also enter a fqdn to see just the server results)

*piEnterCommand $server $command* - logs a command for the specific server (The Command is !NOT! executed, just for logging)

# ToDo
- Establish connection profiles for servers to enter commands via powershell/ssh
- better Overview of Results
- Integration of CMDB / Ticket Systems
