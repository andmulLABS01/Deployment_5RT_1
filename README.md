<h1 align="center">Deploy a retail banking application to an EC2 instance<h1> 


# Deployment 5 RT1
November 15, 2023

By: Andrew Mullen

## Purpose:

Practicing my ability to deploy a retail banking application to an EC2 instance and creating infrastructure, using TerraForm, for our Jenkins pipeline
and Flask application with a Guincorn webserver and SQLite database. 

## Steps:

### 1. Create a VPC with Terraform, and the VPC must have only the components listed: 1 VPC, 2 AZs, 2 Public Subnets, 2 EC2s, 1 Route Table, Security Group Ports: 8080, 8000, 22
   - This process is to give us practice using Terraform to create our AWS infrastructure using resource blocks.  Here is the link to the main.tf file: Click [HERE](https://github.com/andmulLABS01/Deployment_5RT_1/blob/main/DPRT1_main.tf)
   - We must update several files and merge them into the main branch.

### 2. For the first instance follow the below instructions: Jenkins Server
   - The below instructions create public and private keys that will allow us to SSH into the second instance
    - This step acts as a Jenkins agent which allows us to connect to the second instance when when we run the pipeline on the Jenkins server.
   - Create the Jenkins user that we need for our Jenkinsfiles
   - Install required packages

```
- Install Jenkins
- Create a Jenkins user password and log into the Jenkins user (Review Deployment 3 on how to do this)
- Create a public and private key on this instance with ssh-keygen
- Copy the public key contents and paste it into the second instance authorized_keys
- IMPORTANT: Test the ssh connection
- Exit the jenkins user
- Now, in the ubuntu user, install the following: {sudo apt install -y software-properties-common, sudo add-apt-repository -y ppa:deadsnakes/ppa, sudo apt install -y python3.7, sudo apt install -y python3.7-venv}
```

###	3. On the second instance, install the following: Webserver
   - Install required packages

```
- Install the following: {sudo apt install -y software-properties-common, sudo add-apt-repository -y ppa:deadsnakes/ppa, sudo apt install -y python3.7, sudo apt install -y python3.7-venv}
```

### 4. In the Jenkinsfilev1 and Jenkinsfilev2, create a command that will ssh into the second instance and download and run the required script for that step in the Jenkinsfile
- This is the step where we will make changes to the files mentioned above. 
  - Update Jenkinsfilev1 Deploy stage with ssh and curl command
  - Update Jenkinsfilev2 Deploy stage with ssh and curl command
    - This acts as a Jenkins agent since we did not deploy an instance to be an agent
  - Update setup.sh with the correct git clone url and cd command
  - Update setup2.sh with the correct git clone url and cd command

- After modifing the Jenkinsfilev1, Jenkinsfilev2, setup.sh, and setup2.sh commit the changes to git repository
		
### 5. Create a Jenkins multibranch pipeline and run the Jenkinsfilev1
- Jenkins is the main tool used in this deployment for pulling the program from the GitHub repository, and then building and testing the files to be deployed to the second EC2 instance.
- Creating a multibranch pipeline gives the ability to implement different Jenkinsfiles for different branches of the same project.
- A Jenkinsfile is used by Jenkins to list out the steps to be taken in the deployment pipeline.

- Steps in the Jenkinsfilev1 are as follows:
  - Build
    - The environment is built to see if the application can run.
  - Test
    - Unit test is performed to test specific functions in the application
  - Deploy
    - SSH into the second instance and runs the setup.sh script to deploy the retail banking site using gunicorn, flask/python, and SQLite 	


### 6. Check the application on the second instance!!
- Here is the screenshot of the application. Click [HERE](https://github.com/andmulLABS01/Deployment_5RT_1/blob/main/Deployment_5RT1a.PNG)
	
### 7. Now make a change to the HTML and then run the Jenkinsfilev2	
	- Steps in the Jenkinsfilev2 are as follows:
	  - Clean
		- SSH into the second instance and runs the pkill.sh script which stops gunicorn and 
	  - Deploy
		- SSH into the second instance and run the setup2.sh script 
		
#### 7a. Make the change to the home.HTML
	- I changed the font color from black to darkblue in the Welcome paragraph.
#### 7b. View the application after the change
- Click [HERE](https://github.com/andmulLABS01/Deployment_5RT_1/blob/main/Deployment_5RT1b.PNG)

### 8. How did you decide to run the Jenkinsfilev2? 

- I changed the file path in Jenkins configuration section from Jenkinsfilev1 to Jenkinsfilev2.
- You could also have created a second branch put the Jenkinsfilev2 in that branch and run it from there.

### 9. Should you place both instances in the public subnet? Or should you place them in a private subnet? Explain why?

- Well it depends.  Since both instances need to be accessed via the internet it is best to put them on the public subnet with the correct security group settings to secure them. 
However, we could place parts of the second instance, application and database tiers, into the private subnet to enhance security and limit access.


## System Diagram:

To view the diagram of the system design/deployment pipeline, click [HERE](https://github.com/andmulLABS01/Deployment_5RT_1/blob/main/DPRT1_main.tf)

## Issues/Troubleshooting:

Trouble running .tf files and was getting duplicate names and rules.

Resolution Steps:
- Using a different main.tf file to create the infrasturue.
- Used the original main.tf file to create the infrasttrue. 
- Needed to break out resource blocks to accommodate for the infrastructure requirements.  Will make the changes in my next practice deployment.


Created a second route table but didn't need to create it.

Resolution Steps:
- Learned that there is a resource block 'resource "aws_default_route_table" ' that modifies the default route table.
- I will use this next time instead of going through the AWS console to delete and reassociate the subnets to the route table and to the internet gateway.

Issues deploying banking applications, files not getting installed. Created a second route table but didn't need to create it.

Resolution Steps:
- Reviewed the Jenkinsfile pipeline and discovered the URL to get the files from GitHub was not correct. 
- I corrected the link but I was still not able to push the payload.
- Then discovered that I had commented out the Deploy stage in the Jenkinsfile.  Corrected the issue by removing the commented-out section and fixed the issue. 

## Conclusion:

This was a difficult process to redo the deployment, especially without proper documentation. For the next retries of this deployment, I will use the existing VPC infrastructure in my main.tf file to create the environment.
