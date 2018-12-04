# CI/CD CASE STUDY

This repository contains the files used in building the packer image for creating a Continuous Integration/Continuous Deployment (CI/CD) pipeline for the Random Phone Number Generator (RPG) project located at https://github.com/baasbank/rpg.


## TECHNOLOGIES

The following technologies/platforms were used in building the CI/CD Pipeline:
  * [Packer](https://packer.io/): Packer was used to build the Machine Image on which the RPG application is deployed.
  * [Github](https://github.com): Github is used for source control.
  * [CircleCI](https://circleci.com/): CircleCI is the CI tool of choice. It was chosen because of its speed and extensibility.
  * [Docker Hub](https://hub.docker.com): Docker Hub is used to hold the Docker Images that are built during the deployment      process.
  * [Google Cloud](https://cloud.google.com): The application runs on a managed instance group provisioned on Google Cloud.

## SETUP

### GOOGLE CLOUD SETUP

1. Create an account on [Google Cloud](https://cloud.google.com). Skip this step if you already have an account
2. Go to https://console.cloud.google.com
3. Click on the drop down shown in the image below


![image](https://user-images.githubusercontent.com/26189554/49220833-8afaa380-f3d7-11e8-8d3e-9db09f49d57c.png)


4. From the modal that pops up, copy the project ID of the project you want to create the Managed Instance Group in and paste it somewhere.
For a new Google Cloud account, a default project is automatically created for you. 
You can also create a new project by clicking on the NEW PROJECT button in the top right corner of the screen.


![image](https://user-images.githubusercontent.com/26189554/49221450-77e8d300-f3d9-11e8-86fe-065acf6ab651.png)

#### 5. CREATE A SERVICE ACCOUNT KEY
a. Click on the menu icon > APIs and Services > Credentials

![image](https://user-images.githubusercontent.com/26189554/49341115-5130d380-f649-11e8-8ece-6e5d10b86d38.png)

b. Click on Create credentials > Service account key

![image](https://user-images.githubusercontent.com/26189554/49341187-390d8400-f64a-11e8-9485-725f57dbb85d.png)

c. Click the Service account dropdown, then select New service account

![image](https://user-images.githubusercontent.com/26189554/49341240-e7b1c480-f64a-11e8-8a44-3a849a2ce798.png)


d. Give the service account a name. Select Project > Owner for role; this would give that service account full access.
Leave the JSON key type selected then click on the Create button to download the service key.

![image](https://user-images.githubusercontent.com/26189554/49341305-ad94f280-f64b-11e8-9e64-a7ef0eeb59b2.png)

#### 6. ADD SOME PROJECT METADATA
The instance template startup script at https://github.com/baasbank/rpg/blob/master/instance_template_startup_script.sh (which is a template for the creation of the instances in the Managed Instance Group) fetches the IMAGE_TAG from project metadata on Google Cloud. The IMAGE_TAG metadata is set during the Docker Image build process on CircleCI and represents the tag for the latest image on Docker Hub.
To ensure a successful build when the instance group is created, we need to set the IMAGE_TAG manually. This wouldn't be necessary subsequently as it would be automatically set from CircleCI.

Follow the steps below to add the `image_tag` metadata:

a. Click on the menu icon > Compute Engine > Metadata

![image](https://user-images.githubusercontent.com/26189554/49341434-8dfec980-f64d-11e8-9c31-0ca5bc81ce1c.png)


b. Add metadata with the key `image_tag` and the value `baasbank/rpg-docker:0.1.57`
That value represents the latest image tag found at https://hub.docker.com/r/baasbank/rpg-docker/tags/ as at the time this documentation is being written.

c. Click on Save to save your changes.


### PACKER SETUP

1. Clone this repository by running 
  ```GIT CLONE
  git clone https://github.com/baasbank/output3.git
  ```
2. Change into the packer directory
  ```CHANGE DIRECTORY
  cd output3/packer
  ```
3. Make the following changes in the `rpg_image.json` file
  * Change the value for `account_file` to the path where your gcloud service account key downloaded in the GCLOUD SETUP Section is located.
  * Change the value for `project_id` to your project id generated in the GCLOUD SETUP Section above.
  * Under provisioners, change the value for `source` to the path to your SSH private key file.
  
  ![image](https://user-images.githubusercontent.com/26189554/49428459-6c652580-f7a6-11e8-92d2-c46a23b2430d.png)


4. Follow the instructions at https://www.packer.io/intro/getting-started/install.html to install packer.
5. Make sure you're in `output3/packer` directory, then run 
  ```PACKER
  packer build rpg_image.json
  ```
  
6. When packer is done building, you can go to the console at https://console.cloud.google.com to confirm the image is there.
Simply click on the menu icon > Compute Engine > Images

![image](https://user-images.githubusercontent.com/26189554/49372619-91e92500-f6fb-11e8-9bb6-d70efe08dc20.png)

You should see the new image you built with the name `packer-image-rpg` in the Images list.


### CREATE MANAGED INSTANCE GROUP ON GOOGLE CLOUD

1. Go to https://console.google.cloud.com
2. Click on the menu icon > Compute Engine > Instance groups

![image](https://user-images.githubusercontent.com/26189554/49431264-632b8700-f7ad-11e8-9a3b-791986915a99.png)

3. Click on CREATE INSTANCE GROUP

![image](https://user-images.githubusercontent.com/26189554/49431413-ba315c00-f7ad-11e8-9f6f-ea6a7419cafe.png)


4. 
a. Give the instance group a name.
b. Under location select Multi-zone.
c. Select a region
d. Click the dropdown under Instance template and select `Create instance template`
e. On the `Create an instance template` modal that pops up:
 * Give your instance template a name
 * Click on the Change button under Boot disk
 
 ![image](https://user-images.githubusercontent.com/26189554/49432237-83f4dc00-f7af-11e8-9492-41e52bb1415a.png)
 
 
 * Click on `Custom images`. You should see the packer-image-rpg that was built using packer in the previous section. Select it.
 
 ![image](https://user-images.githubusercontent.com/26189554/49433036-55780080-f7b1-11e8-8dc8-1aa011f38583.png)


 * Under `Firewall` select `Allow HTTP traffic`
 * Click on ` Management, security, disks, networking, sole tenancy `

 ![image](https://user-images.githubusercontent.com/26189554/49433314-02eb1400-f7b2-11e8-8c07-152de92e19d3.png)

 * Copy the content of the instance template startup script at https://github.com/baasbank/rpg/blob/master/instance_template_startup_script.sh and paste it in the field for Startup script

 ![image](https://user-images.githubusercontent.com/26189554/49433631-c370f780-f7b2-11e8-99f5-82588cd0b4cb.png)


 * Click on Save and continue

 ![image](https://user-images.githubusercontent.com/26189554/49433891-4eea8880-f7b3-11e8-99e1-5249a30e745a.png)

f. Type in 2 for Minimum number of instances and 3 for Maximum number of instances, then click on Create.


![image](https://user-images.githubusercontent.com/26189554/49434147-cf10ee00-f7b3-11e8-9b52-aa1eaf4c405c.png)

g. Wait for the instances to be created. You'll see a green checkmark before the instance group once it's ready.

![image](https://user-images.githubusercontent.com/26189554/49434677-ffa55780-f7b4-11e8-8105-96018dff702b.png)

h. Click on the instance group names, and you'll see the instances in the group as shown below. Click on the external ip of any instance, and you should see the Phone Number Generator app.

![image](https://user-images.githubusercontent.com/26189554/49435024-ec46bc00-f7b5-11e8-95aa-9727263be305.png)

