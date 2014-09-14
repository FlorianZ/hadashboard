# Installation

## 1. Sign up for Heroku
Navigate to https://www.heroku.com and sign up for a free account. No need to enter your credit card information: We will be using a free dyno.

Download and install the [Heroku Toolbelt](https://toolbelt.heroku.com) on your local machine. The toolbelt includes the Heroku CLI (Command Line Interface), which we will be using to configure the web app on the Heroku dyno. Note, that you can complete the configuration without the CLI, by using the Heroku web interface. However, the process becomes a lot more streamlined with the toolbelt.


## 2. Clone the Repository
Clone the **hadashboard** repository to the current local directory on your machine.

``` bash
$ git clone https://github.com/FlorianZ/hadashboard.git
```

Change your working directory to the repository root. Moving forward, we will be working from this directory.

``` bash
$ cd hadashboard
```


## 3. Install the SmartApp
Navigate to https://graph.api.smartthings.com and log in to your SmartThings IDE account. Select the **'My SmartApps'** tab, and click the **'+ New SmartApp'** button to create a new SmartApp.

Fill in the required information. The **'Name'** and **'Description'** are both required fields, but their values are not important.

Make sure to click the **'Enable OAuth in Smart App'** button to grant REST API access to the new SmartApp. Note the **'OAuth Client ID'** and **'OAuth Client Secret'**. Both will later be required by the Dashing backend to authenticate with the new SmartApp and talk to SmartThings.

Hit the **'Create'** button to get to the code editor. Replace the content of the code editor with the content of the file at: `smartapps/DashingAccess.groovy`

Click the **'Save'** button and then **'Publish -> For Me'**.

## 4. Configure the Web App
Using the Heroku CLI, log in to your Heroku account with the email address and password used to create your Heroku account in step 1. You may be required to **generate a new public key** in the process. The Heroku CLI will take care of this and upload the key in the process.

``` bash
$ heroku login
Enter your Heroku credentials.
Email: your@email.com
Password: 
Could not find an existing public key.
Would you like to generate one? [Yn] 
Generating new SSH public key.
Uploading ssh public key /Users/user/.ssh/id_rsa.pub
```

Now, we will create a new Heroku app. Make sure you are still in the repository root directory (*hadashboard*) from step 2.

``` bash
$ heroku create
Creating your-app-name... done, stack is cedar
http://your-app-name.herokuapp.com/ | git@heroku.com:your-app-name.git
Git remote heroku added
```

This will create a new web app with a random name. The name will be output to the terminal. Take note of it. If you don't like the name, don't worry: You can [rename your app](https://devcenter.heroku.com/articles/renaming-apps) at any time using the Heroku CLI or web interface.

Your new app will later be reachable at **http://*your-app-name*.herokuapp.com**. We have not deployed your app yet, and before we do we will need to make sure that only you have access to your dashboard, and set up a few **Config Variables**:

To make sure that your dashboard is not publicly viewable, and that only you have access to it, the hadashboard code is set up to use your Heroku credentials (from step 1) for authentication. It uses OAuth to verify your identity, so we must grant the hadashboard client OAuth access. To do so, install the heroku-oauth CLI plugin:

``` bash
$ heroku plugins:install https://github.com/heroku/heroku-oauth
Installing heroku-oauth... done
```

Then, create a client for hadashboard. Make sure to replace *your-app-name* with the name of your app, as returned by `heroku create` earlier.

``` bash
$ heroku clients:create -s "hadashboard" https://your-app-name.herokuapp.com/auth/heroku/callback
HEROKU_OAUTH_ID=some-random-uuid
HEROKU_OAUTH_SECRET=some-random-uuid
```

The command will return two random uuids. The app id and secret. Note the two uuids, as we will set them in the app environment as **Config Variables** along with some other variables required by the hadashboard app. Before running this command, make sure to first **replace** with real values as described below.

``` bash
$ heroku config:set \
  DASHING_AUTH_TOKEN=some-random-uuid \
  DASHING_URI=http://your-app-name.herokuapp.com \
  HEROKU_OAUTH_EMAIL=your@email.com \
  HEROKU_OAUTH_ID=uuid-from-above \
  HEROKU_OAUTH_SECRET=uuid-from-above\
  SESSION_SECRET=some-random-uuid \
  ST_API_KEY=from-step-3 \
  ST_CLIENT_ID=from-step-3
```

- **DASHING_AUTH_TOKEN**: Set this to a new, random uuid. You may be able to generate a new uuid using the `uuidgen` command line tool, if it is installed on your local machine. You can also use one of the many [online tools](https://www.uuidgenerator.net) to generate uuids. This is used as a machine-to-machine password of sorts, so you could even make up your own. Just make sure it's long, and random, and comlicated in order to ensure it is as secure as possible. This uuid/password is used for the SmartApp to communicate with the Heroku app.
- **DASHING_URI**: This is the URI to your heroku app. The `heroku create` command will return this value. It is usually **http://*your-app-name*.herokuapp.com**, but make sure to replace *your-app-name* with the actual app name. Also make sure there is no trailing */* character in this value.
- **HEROKU_OAUTH_EMAIL**: The email address you used to sign up to Heroku (step 1).
- **HEROKU_OAUTH_ID**: Set this to the **HEROKU_OAUTH_ID** uuid returned by the previous command (`heroku clients:create`).
- **HEROKU_OAUTH_SECRET**: Set this to the **HEROKU_OAUTH_SECRET** uuid returned by the previous command (`heroku clients:create`).
- **SESSION_SECRET**: Generate a new, random uuid for this, just like you did for **DASHING_AUTH_TOKEN**. This uuid/password is used to encrypt the session cookie in your browser.
- **ST_API_KEY**: Set this to the SmartApp **'OAuth Client Secret'** from step 3.
- **ST_CLIENT_ID**: Set this to the SmartApp **'OAuth Client ID'** from step 3.

## 5. Deploy to Heroku
To deploy the hadashboard app, all we need to do is push the git repository to Heroku. This will automatically install all the dependencies on the server, and restart the app.

``` bash
$ git push heroku
Initializing repository, done.
Counting objects: 301, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (171/171), done.
Writing objects: 100% (301/301), 447.67 KiB | 537.00 KiB/s, done.
Total 301 (delta 120), reused 301 (delta 120)

-----> Ruby app detected
-----> Compiling Ruby/Rack
-----> Using Ruby version: ruby-2.0.0
-----> Installing dependencies using 1.6.3
       ...
       
-----> Discovering process types
       Procfile declares types -> (none)
       Default types for Ruby  -> console, rake, web

-----> Compressing... done, 18.5MB
-----> Launching... done, v6
       http://your-app-name.herokuapp.com/ deployed to Heroku

To git@heroku.com:your-app-name.git
 * [new branch]      master -> master
```

To access the hadashboard app, navigate to **http://*your-app-name*.herokuapps.com**. You will be asked to grant the hadashboard app access to your Heroku account. Make sure to **Allow Access**. The hadashboard app needs access to your Heroku account in order to verify your identity. You may be asked to log in to your Heroku account, as well. Use the email address and password from step 1.

You will see the default dashboard, but it will not yet have access to your SmartThings.

## 6. Authorize SmartThings Access
