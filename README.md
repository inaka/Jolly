#Jolly
[![Build Status](https://api.travis-ci.org/inaka/Jolly.svg)](https://travis-ci.org/inaka/Jolly) [![Codecov](https://codecov.io/gh/inaka/Jolly/branch/master/graph/badge.svg)](https://codecov.io/gh/inaka/jolly) [![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://swift.org/) [![Twitter](https://img.shields.io/badge/twitter-@inaka-blue.svg?style=flat)](http://twitter.com/inaka)

[Jolly Chimp monkey](http://pixar.wikia.com/wiki/Monkey) that allows you to monitor Github repos straight from [HipChat](https://www.hipchat.com/).

![Jolly Monkey](https://raw.githubusercontent.com/inaka/Jolly/master/Assets/V1/jolly-monkey.gif)

##Overview
Jolly is a HipChat bot that provides quick reports of Github repos in your rooms.

![Jolly Overview](https://raw.githubusercontent.com/inaka/Jolly/master/Assets/V1/jolly-in-action.gif)

## How It Works

This repository contains the server-side code. You run this code somewhere to have a server running. Then, you set up a HipChat extension in your room, such that it forwards any `/jolly` message to the server. The server parses your requests, do its work, and sends a message with the results back to the room from which the request was sent.

You can set up as many integrations as you want, the server keeps track of each one individually.

##Setup

#### 1. Run your server instance

You need a server instance running, which will respond to requests coming from HipChat rooms and be in charge of sending the proper responses back to HipChat.

1. Clone this repository:

   `git clone git@github.com:inaka/Jolly`

2. Create an environment variable named `HIPCHAT_TOKEN`. Set its value with any token that allows you to send messages to your rooms. 

   - If you want to use Jolly in only one room, you can use the `auth_token` you will obtain when setting up the integration for that room.
   - If you want to use Jolly in multiple rooms, you need to [generate a token](https://bobswift.atlassian.net/wiki/display/HCLI/How+to+Generate+a+HipChat+Access+Token) with the `room_notification` grant.

   `export HIPCHAT_TOKEN={PASTE_TOKEN_HERE}`

3. Compile the current source code. At the root level: `swift build`

4. Run the generated executable: `./.build/debug/Jolly`

5. Make sure your server is running in a public, reachable URL, you'll need it later.

#### 2. Configure your HipChat integration

In order to have your Jolly chimp listening to commands in a HipChat room:

1. Go to your HipChat room and select "Integrations" from the Room menu

2. Click on "+ Install new integrations" (you have to be room admin)

3. Click on "Build your own integration"

4. Give it a name (for instance, `Jolly`) and hit "Create"

5. The token from "Send messages to this room by posting to this URL" allows you to sends messages to that room:

   `https://xxxxx.hipchat.com/v2/room/xxxxx/notification?auth_token={COPY_THIS_VALUE}`

6. Check the "Add a command" box and enter `/jolly` as your slash command

7. In the "We will post to this URL" field, paste your server instance's URL, which you obtained before.

8. Test that the integration works: Send a `/jolly ping` message in your room and check if he answers.

> Notice that you can set up a new integration for a different room. Jolly will work independently for each room; he is intended to give reports only for the repos that are relevant to the room.`

## Usage

Once your integration is working, you can talk to Jolly by sending him commands through your HipChat room. These commands will allow you to fetch a report, set what repos you want to be included in the report, and more.

Send a `/jolly` message in your room to see a list of all the available commands and their usage.


##Contact Us
For **questions** or **general comments** regarding the use of this library, please use our public [hipchat room](http://inaka.net/hipchat).

If you find any **bug**, a **problem** while using this library, or have **suggestions** that can make it better, please [open an issue](https://github.com/inaka/Jolly/issues/new) in this repo (or a pull request).

You can also check all of our open-source projects at [inaka.github.io](inaka.github.io).
