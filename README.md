# EMOTION TRACKER WEB APP
An interactive Node-based Web App using client-side (HTML, CSS, JavaScript) and server-side (Node JS, Express JS, MySQL) web development technologies.
The app has been created to allow users to record and review their emotional state at different points in time, by recording a score (ranging from 1-10) for each of the [seven universal emotions](https://www.paulekman.com/universal-emotions/): enjoyment, sadness, anger, contempt, disgust, fear, surprise.
Users are also able to record any triggers associated with their emotional state snapshots (triggers can be entered as new text values, or selected from a list of previously-entered values for the logged-in user).


### User Accounts
The app allows multiple users, and has 2 user roles (user and administrator). One 'administrator' account is creating during setup, as well as one 'user' account (for demonstration purposes).
New users are able to register, login and logout. Upon registration through the 'Create Account' link, the 'user' role is assigned by default. After logging in, the 'Account Admin' link allows user account details (name, username, password, etc.) to be changed by individual users, as well as by any user whose role is 'administrator'. Administrators may change account details for any other user, and can also assign a new role to other users (giving them administrator privileges and/or removing those privileges).


### Emotion Snapshots
When logged in, users will be able to view radar charts showing any previously-recorded emotion snapshots.

#### New Snapshot
_x_ Emotion levels
Users can record a new snapshot by clicking the 'Add' link, choosing a score from 1-10 for each of the aforementioned 7 universal emotions.
_x_ Triggers
They can also enter trigger details linked to the emotion snapshot via a dropdown trigger selection menu. The dropdown contains a list of triggers that have previously been entered by the user in question. If the user wishes to enter a new trigger, they can type the new value into the dropdown box and hit "Enter", "Tab" or "," to record the new value.
_x_ Date
A date must be entered for each new snapshot.
_x_ Notes
An optional comment can be added in "Notes" for each snapshot
The 'Add' button will be disabled until mandatory values (emotion levels and a date) have been entered for the new snapshot. Other inputs are optional.

#### Edit Existing Snapshot
Users can select one of their existing snapshots by clicking on one from the 'Snapshots' overview (which they see by default after logging in).
Administrators can select a specific user from a dropdown list on this overview, and are then able to select a snapshot from the given user's history.
Clicking on the snapshot opens a new page displaying further detail for the selected snapshot. Normal users can edit the triggers and notes associated with the snapshot on this page, but do not have permission to edit the emotion values or the snapshot date. Administrators can edit all values related to the snapshot. Both users and administrators can choose to delete the selected snapshot.



## Setup
This project has been created in a development environment using [Laragon](https://laragon.org), and the setup instructions given will apply to this environment.
It may be possible to achieve the same result using alternative dev environment tools, however Laragon was chosen after encountering some problems while using XAMPP:
- The version of XAMPP which was used has MariaDB version 10.4.27, and some MySQL functionality needed for this project (for example the JSON_TABLE function) is not available in this version.
- The creation of MySQL Stored Procedures via XAMPP is more complicated. Many of the Stored Procedures used in this project could not be set up as required via the PHPMyAdmin interface that comes with XAMPP. They have instead been created through executing the relevant SQL scripts in Laragon's HeidiSQL interface, which offers greater control with respect to delimiters and multi-statement queries.

### Download and install Laragon
https://laragon.org/download/

### Download the emotiontracker project folders
https://github.com/ctneeson/emotiontracker2
Click on 'Code' > 'Download ZIP', and extract the downloaded files to a suitable location (suggestion: inside of C:/laragon/www)

### Start Laragon
![alt text](https://github.com/ctneeson/emotiontracker2/blob/main/Start%20Laragon.jpg?raw=true)

### Open HeidiSQL
![alt text](https://github.com/ctneeson/emotiontracker2/blob/main/HeidiSQL.gif)

### Create Database
![alt text](https://github.com/ctneeson/emotiontracker2/blob/main/CreateDatabase.gif)
In HeidiSQL, create a new database for the project.

### Create & populate SQL tables
After creating the database, run the following SQL script to create and populate the Database tables.
https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker/sql/emotiontracker_setup_tables.sql

#### Database diagram
The following diagram represents the database structure and shows the relationship between database tables.
![alt text](https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker_ERD.png)

### Create Stored Procedures
Run the following scripts against your new database to create the necessary SQL stored procedures.
https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker/sql/sp_deleteEmotionHistByID.sql
https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker/sql/sp_deleteUser.sql
https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker/sql/sp_getEmotionHist.sql
https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker/sql/sp_getEmotionHistByID.sql
https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker/sql/sp_getTriggers.sql
https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker/sql/sp_getUserPostLogin.sql
https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker/sql/sp_getUsers.sql
https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker/sql/sp_postNewEmotionHist.sql
https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker/sql/sp_postNewUser.sql
https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker/sql/sp_updateEmotionHistByID.sql
https://github.com/ctneeson/emotiontracker2/blob/main/emotiontracker/sql/sp_updateUser.sql

### Remove 'node_modules' and 'package-lock.json'
Delete the 'node_modules' folder and 'package-lock.json' files from both the 'emotiontracker' and 'emotiontrackerapi' folders within the zip file that you have downloaded.
![alt text](https://github.com/ctneeson/emotiontracker2/blob/main/DeleteFolders.jpg)

### Open project folders in VS Code
Open 2 windows in VS Code:
##### Within one window, open the client-side folder (emotiontracker) that is contained within the files that have been extracted from the downloaded ZIP - e.g. C:/laragon/www/emotiontracker2-main/emotiontracker)
1. Open a new Terminal and initialise the Node project by running the following command:
```console
npm init -y
```
2. Run the following command in the terminal to install dependencies:
```console
npm install nodemon axios cors dotenv ejs express express-session method-override morgan mysql2
```
3. Then start the project by running this command:
```console
npm init -y
```
##### Within the other window, open the server-side folder (emotiontrackerapi)
1. Open a new Terminal and initialise the Node project by running the following command:
```console
npm init -y
```
2. Run the following command in the terminal to install dependencies:
```console
npm install nodemon cors dotenv express method-override morgan mysql2
```
3. Then start the project by running this command:
```console
npm init -y
```

### Open the Web App
Navigate to http://localhost:3000 on your machine in order to use the web app.
You may create a new account, or use the following accounts which have been created after running the above-mentioned SQL scripts
Username: admin / Password: admin123
or
Username: user / Password: user123
