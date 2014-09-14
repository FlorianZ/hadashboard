# Installation

## 1. Sign up for Heroku
Navigate to https://www.heroku.com and sign up for a free account. No need to enter your credit card information: We will be using a free dyno.


## 2. Clone Repository
Clone the **hadashboard** repository to the current local directory on your machine.

`git clone https://github.com/FlorianZ/hadashboard.git` 


## 3. Install SmartApp
Navigate to https://graph.api.smartthings.com and log in to your SmartThings IDE account. Select the **'My SmartApps'** tab, and click the **'+ New SmartApp'** button to create a new SmartApp.

Fill in the required information. The **'Name'** and **'Description'** are both required fields, but their values are not important.

Make sure to click the **'Enable OAuth in Smart App'** button to grant REST API access to the new SmartApp. Note the **'OAuth Client ID'** and **'OAuth Client Secret'**. Both will later be required by the Dashing backend to authenticate with the new SmartApp and talk to SmartThings.

Hit the **'Create'** button to get to the code editor. Replace the content of the code editor with the content of the file at: `hadashboard/smartapps/DashingAccess.groovy`

Click the **'Save'** button and then **'Publish -> For Me'**.
