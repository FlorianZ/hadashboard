# Touch-based Dashboard for OpenHAB

![Image of openHAB Dashboard](https://github.com/smar000/openhab-dashboard/blob/master/tmp/image.jpg)

This is a dashing (http://dashing.io/) based dashboard interface for OpenHAB (http://www.openhab.org), a superb open source home automation system.  It is a fork from FlorianZ's SmartThings dashboard (https://github.com/FlorianZ/hadashboard), basically replacing the SmartThings related calls to OpenHAB equivalents/work-arounds. For those interested, there is a great discussion on the SmartThings forum (link available in FlorianZ's github repo).

I have it running on wall-mounted Nexus 7's, providing a much easier UI for users in my home with quick access to the most commonly used items.

As I have never coded in Ruby and had never heard of *Batman.js* before this, the work here is for the most part a 'hatchet' job, but is at a point that it works for me. There is most certainly room for it to be tidied up and made more efficient!

When going through the installation details below, you may notice that I am not using server side push using the REST API on openHAB, but instead am using a rule within openHAB to trigger on changes in the underlying item states which then uses dashing's REST api to post data to the relevant dashing widget. The reason for this is because I could only get server side push to work for site-maps, and not for individual items or groups of items. This wasn't ideal for me, as I didn't want to have to keep adding items to site-maps just so they update to the dashing dashboard (plus it seems as if openHAB 2 will be moving to SSE's - thus there isn't enough incentive to spend the time on this further as it is working reliably for now). 

You may also note that there is a CCTV related dashboard/widgets in the repository. This has nothing to do with openHAB and is a seperate system we use in our home. I have left it in as an example in case anyone is interested.

# Installation
I'm assuming you know the basics of linux and are comfortable with simple installations etc. Everything here has been installed and is in daily use on an Ubuntu 14.10 server.

1. Install dashing (http://dashing.io) along with any related components it needs (it should do these automatically if you follow the instructions on their website, although some manual configuration may be necessary depending on what system you are running on and what you already have installed)

2. Clone or download this dashboard repository into a local folder, e.g. */opt/dashboard*

3. In the service folder of this repository, there is a start-up script you can use if you want to run dashing as a service. Modify the paths in this service file with anything that is different on your installation. On Ubuntu, this file can be placed in the */etc/init.d* folder with persmissions set at 755. You will also need to run *update-rc.d* if you want the service to start automatically at boot.

4. Edit the *lib/ohapp.rb* file, and make sure that your **openhab server name** and **port** are correctly specified

5. Edit the file *config.ru* in the top level folder and change the **auth_token** value to whatever you want to use to authenticate communications between dashing and openHAB (or leave as is if you prefer!). You can also change the default dashboard here if you have multiple dashboards defined.

6. Copy the rule file from the *dashboard/openhab_rule* folder into your openhab's rule folder (e.g. */opt/openhab/configurations/rules*). Edit the rule file and change the the **auth_token** here to whatever you set it in the previous step (or leave as is if you didn't make any changes in the previous step).


# Configuring the Dashboard(s) 

1. First, on the OpenHAB side, in your items file, create a group called *gDashboard*

2. Next, add all items that you want to use in your dashboard(s) to this new *gDashboard* group EXCEPT for the weather items (weather is updated through a 5 minute scheduler event as defined in the *jobs/openhab.rb* file)

3. If you want to use the dashboard's weather widget and have this updating from openHAB using the code as is, you will need to ensure that your weather items in openHAB are named as follows:
    * Weather_Temperature
    * Weather_Conditions
    * Weather_Code
    * Weather_Temp_Max_0
    * Weather_Temp_Min_0
    * Weather_Humidity
    * Weather_Pressure
    * Weather_Temp_Max_1
    * Weather_Temp_Min_1
    * Sunrise_Time
    * Sunset_Time
    * Weather_ObsTime
    * Weather_Code_1
    * Weather_Precipitation
    * Weather_Precipitation_1
    * Weather_Wind_Speed
    * Weather_Wind_Direction
    * Weather_Wind_Gust

These are defined as in the Weather binding wiki for openHAB (*note that all the weather items MUST be in an item group "Weather"*). If you do want to use different names, then edit the *lib/ohapp.rb* file accordingly.

General instructions on creating widgets and dashboards are given on the dashing website. In addition, and specifically for this openHAB setup, the main points to note are:

1. Each widget is defined in the dashboard file (e.g. the *dashboards/default.erb* file) using html list items (`<li>...</li>`). 

2. The widget is linked to a corresponding openHAB item via the **data-device** list item parameter. This must match exactly the item name in openHAB. (In the included dashboards, the **data-id** parameter mostly has the same value as the **data-device** paramater - this is not a requrement and has just been used this way for simplicity; the **data-id** is basically a unique ID for that specific widget on the dashboard).

3. The **data-view** parameter of the list item specifies the type of widget. All the widget types available are in the widgets folder, and the openHAB specific ones are prefixed with 'Oh' - e.g. Ohdimmer, Ohswitch etc. **NOTE that not all of the widgets have been tested**. These have been taken from FlorianZ's original repo for SmartThings and kept here in case I have a future need. The only ones tested are those in the included dashboards.

4. Each page on the dashboard is put into an html DIV container with class="gridster".

# Android Tablet Specific Notes
I have the android tablets switching off after a defined timeout period but automatically switching on as soon as it detects motion in front of the device (via its front-facing camera). This is done using two apps:
* Tasker https://play.google.com/store/apps/details?id=net.dinglisch.android.taskerm
* Motion Detector https://play.google.com/store/apps/details?id=org.motion.detector

Both of these are paid apps. There may be other ways to achieve the same effect, but I have not explored them. A backup of the Tasker profile for this is included in the folder */opt/dashboard/tasker* (assuming you installed the dashboard in the */opt/dashboard* folder).

In order to hide the top and bottom status bars on android, you can use the app GMD Fullscreen, https://play.google.com/store/apps/details?id=com.gmd.immersive. This is currently free.

Finally, on an Android device, you can get rid of the browser's tabs etc, by opening the dashboard in Chrome, and then saving it as a desktop app from Chrome's menu. 
