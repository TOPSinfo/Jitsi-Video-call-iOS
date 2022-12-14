# Swift- Chat and Video Call app
This repository is the demonstration of Chat and Video call functionality using firebase and Jitsi Meet. It includes screens like Login, Registration, User and Group list, Create Group, Chat.

![video](/Media/Swift-Sample-App.gif)

# Description

In the login screen, You can use the valid mobile number. Once the otp verification done if you are registered you will be redirect to the user and group list screen else you will be redirected to registration screen

In the registration screen, You need to enter the user data (First Name, Last Name, Email, Profile Image) and then it will redirect to the user and group list screen.

In User and Group List Screen, User can see list of user and group. Also user can create group by clicking plus, Initiate group call by clicking group icon and selecting user. Also by selecting user or group from list you will be redirect to chat screen.

In Create Group Screen, You need to enter group detail (Group Name and Group Icon) and then it redirect to User and Group list screen.

In Chat screen, User can chat with selected group or individule by sending Text, images, video also you can initiate video call(one-to-one and group) from here. 

# User Credential

- Phone Number    ==>    +1 201-331-6679
- OTP             ==>    123456

# Table of Contents

- Login UI: It will validate phone number and verify otp and redirect to User and Group List
- Registration UI: It will collect user data and redirect User and Group list 
- User and Group list UI: It will display list of group and users, create group, initiate group video call, logout
- Create Group UI: It will ceollect gruop detail and redirect to User and Group List.
- Chat UI: It will display conversation(one-to-one and group), also button to initiate video call(one-to-one and group)

# UI controls 

-  Firebase Authentication
-  Firebase Firestore Database
-  Jitsi Meet
-  TableView
-  Activity Indicator
-  ImageView
-  Toast
-  TextField
-  TextView
-  Buttons 

# Technical detail:

- Project Architecture: MVVM
- Project language: Swift 4+
- Database: Firebase Firestore
- Video Call Tool: Jitsi Meet
- Minimum iOS Version: 12.1


# Documentation:

Jitsi:- https://github.com/jitsi/jitsi-meet-ios-sdk-releases

