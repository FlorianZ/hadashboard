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
  ST_CLIENT_ID=from-step-3 \
  ST_CLIENT_SECRET=from-step-3
```

- **DASHING_AUTH_TOKEN**: Set this to a new, random uuid. You may be able to generate a new uuid using the `uuidgen` command line tool, if it is installed on your local machine. You can also use one of the many [online tools](https://www.uuidgenerator.net) to generate uuids. This is used as a machine-to-machine password of sorts, so you could even make up your own. Just make sure it's long, and random, and comlicated in order to ensure it is as secure as possible. This uuid/password is used for the SmartApp to communicate with the Heroku app.
- **DASHING_URI**: This is the URI to your heroku app. The `heroku create` command will return this value. It is usually **http://*your-app-name*.herokuapp.com**, but make sure to replace *your-app-name* with the actual app name. Also make sure there is no trailing */* character in this value.
- **HEROKU_OAUTH_EMAIL**: The email address you used to sign up to Heroku (step 1).
- **HEROKU_OAUTH_ID**: Set this to the **HEROKU_OAUTH_ID** uuid returned by the previous command (`heroku clients:create`).
- **HEROKU_OAUTH_SECRET**: Set this to the **HEROKU_OAUTH_SECRET** uuid returned by the previous command (`heroku clients:create`).
- **SESSION_SECRET**: Generate a new, random uuid for this, just like you did for **DASHING_AUTH_TOKEN**. This uuid/password is used to encrypt the session cookie in your browser.
- **ST_CLIENT_ID**: Set this to the SmartApp **'OAuth Client ID'** from step 3.
- **ST_CLIENT_SECRET**: Set this to the SmartApp **'OAuth Client Secret'** from step 3.

Lastly, we will add a PostgreSQL database. Heroku makes this trivial by simple configuring an add-on:

``` bash
$ heroku addons:add heroku-postgresql:hobby-dev
Adding heroku-postgresql:hobby-dev to your-app-name... done, v69 (free)
Attached as HEROKU_POSTGRESQL_GOLD
Database has been created and is available
```

Heroku may require up to 5 minutes to set up the database for you. You can run the following command to make sure the database is ready before you move on to the next step.

``` bash
$ heroku pg:wait
Waiting for database HEROKU_POSTGRESQL_GOLD... done
```

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

## 6. Authorize with SmartThings
To grant the hadashboard access to SmartThings, you must first authorize with the SmartApp created in step 3. To do so, navigate to **http://*your-app-name*.herokuapps.com/smartthings/authorize**. Log in with your SmartThings credentials and allows access to all the devices you would like to be able to control from the hadashboard.

After clicking **Authorize** you should be redirected back to the default dashboard, and you should now have access to your things.

Note, that currently authorization only persists for the lifetime of the execution context of the hadashboard app. So, **whenever you restart the Heroku dyno** (such as after deploying changes - step 5) you will have to **repeat this step**. You may also have to authorize **after making changes to the SmartApp**, for the changes to take effect.


# Changing Widgets
The hadashboard is a Dashing app, so make sure to read all the instructions on http://dashing.io to learn how to add widgets to your dashboard, as well as how to create new widgets. 

Essentially, you will have to modify the `dashboards/main.erb` file. After modifying this file, you must commit the changes to the git repository:

``` bash
$ git add .
$ git commit -m "Made some changes to the main.erb layout file."
$ git push heroku
```

This will re-deploy your application, so make sure to repeat installation step 6.

The basic anatomy of a widget is this:
``` html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
  <div data-id="sofalamp" data-view="Stswitch"
    data-icon="lightbulb" data-title="Sofa" data-device="Sofa Lamp"
    data-event-touchend="onClick"
    data-event-click="onClick">
  </div>
</li>
```
- **data-row**, **data-col**: The position of the widget in the grid.
- **data-sizex**, **data-sizey**: The size of the widget in terms of grid tile.
- **data-id**: The unique id of the widget.
- **data-view**: The type of widget to be used (Stswitch, Sttemp, etc.)
- **data-icon**: For Stswitch, the icon displayed on the tile. See http://fontawesome.io for an icon cheatsheet.
- **data-title**: The title to be displayed on the tile.
- **data-device**: This is the name of the device to be controlled by this Stswitch tile. Use the displayLabel as set in SmartThings. Also make sure that access has been granted to this device during authorization with SmartThings (installation step 6). You can always repeat step 6 to change access rights.
- **data-changemode**: The mode to be "watched" by the Stmodechange widget. The widget will indicate if this mode has been set, as well as change to this mode if interacted with (touched, clicked).
- **data-phrase**: (optional) The "Hello Home" phrase to execute when this Stmodechange widget is interacted with (touched, clicked). If this property is set, the phrase will be executed, instead of changing the mode set by **data-changemode**.
- **data-countdown**: A delay in seconds used by the Stmodechange widget to delay the mode change / phrase execution.
- **data-event-touchend**: Adds interactivity to this widget. Set this to **onClick** if you want the widget to react to interactions. Removing this property makes the widget static. Refers to interactivity on mobile devices.
- **data-event-click**: Same as **data-event-touchend**, but for desktop browsers.

Please, refer to the Dashing website for instructions on how to change the grid and tile size, as well as more general instructions about widgets, their properties, and how to create new widgets.


# Changing Dashboards
You can also have multiple dashboards, by simply adding a new .erb file to the dashboards directory and navigating to the dashboards via **http://*your-app-name*.herokuapps.com/*dashboard-file-name-without-extension***

For example, if you want to deploy multiple devices, you could have one dashboard per room and still only use one hadashboard app installation.

Please refer to the Dashing website with regards to instructions on multiple dashboards, the default dashboard and cycling through dashboards.


# Changing Theme
In order to change the theme for your dashboard, you will need to update 1 line in assets/stylesheets/themes/current.scss

Specifically, update the following to include the filename of your theme that exists in the same directory.

``` bash
@import "grey-grey.scss"
```

# Troubleshooting
### My Dashboard is not updating or devices do not respond to interaction.
If your dashboard is not updating or devices have stopped responding to interaction, first try to refresh your browser. If this did not help, navigate to **http://*your-app-name*.herokuapps.com/smartthings/authorize** and re-authorize with the SmartApp (installation step 6) 
You will have to re-authorize with the SmartApp whenever you make changes to backend files (usually .rb or .erb) or the SmartApp Groovy code.
If your dashboard stops updating or devices have stopped responding without making any changes, make sure to file a bug using the issue tracker.

### I made changes to my dashboard/widgets but they don't show up in the browser.
After making changes to any files (except the SmartApp Groovy code), you will have to commit your changes to the local git repository and then push these changes to Heroku. These commands from the local repository root should do the trick:

``` bash
$ git add .
$ git commit -m "Replace this text with a meaningful description of your changes."
$ git push heroku
```

### Can I test my changes locally?
Yes! See the **Getting Started** section at http://dashing.io for more details.

Essentially, you want to make sure that you have Ruby installed on your local machine. Then, install the Dashing gem:

``` bash
$ gem install dashing
```

From your repository root, make sure that all dependencies are available. Note, that you will need to re-run the bundler whenever you modify the Gemfile.

``` bash
$ bundle
```

You can start a local webserver like this:

``` bash
$ dashing start
```

Point your browser to **http://localhost:3030** to access the hadashboard on your local machine.

Note, that the SmartApp will not be able to communicate with the hadashboard running on your local machine, and that in order for the hadashboar to communicate with the SmartApp, the **ST_CLIENT_ID** and **ST_CLIENT_SECRET** variables must be set in your local environment. You can also hardcode these values at the top of the `jobs/smartthings.rb` file.
