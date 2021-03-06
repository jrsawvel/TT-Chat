# TT-Chat

Created on Feb 26-27, 2014.

On Feb 28, 2014, this code was incorporated into the ToledoTalk.com  (TT) message board at:
[http://toledotalk.com/chat](http://toledotalk.com/chat).

This barebones app could be used for simple chatting or live-blogging by TT users.

## Features (limitations)

A logged-in user sees a text-input field at the top of the page, which is used to post a message.

A post is limited to 300 characters with no formatting. It uses client-side JavaScript to post and display messages. The most recent 150 posts are displayed in reverse order, youngest to oldest.

JavaScript refreshes the page every 20 seconds. A logged-in user can refresh sooner by hitting the return key or tapping the post button. A user who is not logged-in can refresh sooner by tapping the refresh button.

The client-side JavaScript sends a POST request to the server. The server-side code sends only JSON data to the client-side JavaScript. This applies for the list of messages and for errors. 

## Testing as of Feb 28, 2014

* Chrome - works
* Firefox - works
* Opera - works
* It works in Opera Mini on an old flip phone, but the JavaScript code for the interval/auto refresh does not work. Have to click the post button to refresh page.
* IE v8 - works when posting by tapping the post button, but nothing is posted when hitting the return key.
* HP tablet with WebOS - works fine when tapping the post button, but when hitting the return key on the tablet screen, it double-posts.
* iphone ?
* Samsung S4 ?


## Dependencies 

* [http://minifiedjs.com](http://minifiedjs.com) framework.   
* [Error.pm](https://github.com/jrsawvel/Kinglet/blob/master/lib/API/Error.pm) module from Kinglet
* [StrNumUtils.pm](https://github.com/jrsawvel/StrNumUtils)
* [DateTimeUtils.pm](https://github.com/jrsawvel/DateTimeUtils)
* Toledo Talk's Parula modules.

