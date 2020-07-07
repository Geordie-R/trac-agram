# Trac-agram

This is a log parser i wrote to monitor the origin trail node logs.  Its the very first draft but hopefully some of you find it useful.

## Step 1: Create Telegram Bot Using Botfather

#### The following steps describe how to create a new bot:

* Contact [**@BotFather**](https://telegram.me/BotFather) in your Telegram messenger.
* To get a token, send BotFather a message that says **`/newbot`**.
* When asked for a name for your new bot choose something that ends with the word bot, so for example my_test_bot.
* If your chosen name is available, BotFather will then send you a token.
* Save this token as you will be asked for it once you execute the script.

Once your bot is created, you can set a custom name, profile photo and description for it. The description is basically a message that explains what the bot can do.

#### To set the Bot name in BotFather do the following:

* Send **`/setname`** to BotFather.
* Select the bot which you want to change.
* Send the new name to BotFather.

#### To set a Profile photo for your bot in BotFather do the following:

* Send **`/setuserpic`** to BotFather.
* Select the bot that you want the profile photo changed on.
* Send the photo to BotFather.

#### To set Description for your bot in BotFather do the following:

* Send **`/setdescription`** to BotFather.
* Select the bot for which you are writing a description.
* Change the description and send it to BotFather.

There are some other useful methods in BotFather which we won't cover in this tutorial like **`/setcommands`**.

<br>

***

<br>

## Step 2: Obtain Your Chat Idenification Number

<br>

Theres two ways to retrieve your Chat ID, the first is by opening the following URL in your web-browser: 

[**https://api.telegram.org/botTOKEN/getUpdates**](https://api.telegram.org/botTOKEN/getUpdates) then replace the **`TOKEN`** with your actual bot token. For example it might end up looking like https://api.telegram.org/bot1328765421:AVKEOPOGIDJJKGLLSKFK8GGLS-13Jh456kS/getUpdates  . Pay special attention that the word bot sits before the token.

Your Chat ID will be shown in this format **`"id":7041782343`**, based on this example your Chat ID would of been **`7041782343`**. The second way that this can be done is through a third party telegram bot called [**@get_id_bot**](https://telegram.me/get_id_bot).

<br>

***

##Installation
Make sure you are logged in as the root user.  Switch to root user using su - root if you are not logged in as root.

mkdir -p /root/trac-agram
cd /root/trac-agram
wget https://raw.githubusercontent.com/Geordie-R/trac-agram/master/nodemonitor.sh && chmod +x nodemonitor.sh


Now we can add this to crontab manually for now and choose to run it on a schedule of our choosing. TYpe the following into the terminal
```
crontab -e
```

Now add the following line to the bottom of the script to make it run every 15 minutes.  I will give a few examples for you to choose from.
#Option 1
##Running every 15 minutes
```
*/15 * * * * /root/trac-agram/nodemonitor.sh
```



#Option 2
##Running every day at 8am. Note: For 2pm change 8 to 14.
```
0 8 * * * /root/trac-agram/nodemonitor.sh
```
#Option 3
##Running every 2 hours.
```
0 */2 * * * /root/trac-agram/nodemonitor.sh
```



