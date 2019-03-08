Chatbots, infobots, socialbots, salesbots, superbots! Bots are a great way to help serve your customers, build your business, and cut down costs.

But how do you get started?

 -Skip to step 4 if you have an Ansible tower already setup.

    1. Deploy a VM with ansible tower.

<a href="https://azuredeploy.net/?repository=https://github.com/AashiqJ/tower" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

    2. Connect to the Ansible tower using the IP. Default username and password is admin and password resp.

    3. Get a free license for ansible tower and login.

    4. Add an inventory.

<p align="center">
  <img src="https://i.imgur.com/TmE5Deh.jpg" width="450" title="hover text">
</p>

    5. Add a new host in that inventory which will be localhost

<p align="center">
  <img src="https://i.imgur.com/JWEy2l0.jpg" width="450" title="hover text">
</p>

    6. Open the linux machine terminal and install Azure Command Line Interface.
        Follow the steps in this link to install az cli in your machine.

<a>https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest</a>

    7. Now run the following command to Create a service principal and configure its access to Azure resources.
        az ad sp create-for-rbac --name "ansible" --password "password"

<p align="center">
  <img src="https://i.imgur.com/p6VpnTp.jpg" width="450" title="hover text">
</p>
        Follow this to link to understand more about az ad sp.

<a>https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest</a>

    8. Copy the Client_ID, Tenant_ID, Client Secret and rest of the information required as shown in the image into a new Credential in ansible tower.(Note: Set the Credential type to Microsoft Azure Resource Manager).

<p align="center">
  <img src="https://i.imgur.com/EgRwfZa.jpg" width="450" title="hover text">
</p>

    9. Add a project linking to the playbooks. Here I have used git to store all my playbooks.

<p align="center">
  <img src="https://i.imgur.com/nRlSNqF.jpg" width="450" title="hover text">
</p>

    10. Now create a app_id for the bot you are going to build.
        Go to link: 
  <a>https://apps.dev.microsoft.com/#/appList</a>
  
        And click on Add app and give in the name of the bot you are going to create.

<p align="center">
  <img src="https://i.imgur.com/IRGUT8o.jpg" width="450" title="hover text">
</p>

    11. In the next screen click on generate new password and copy the password and app id into the extra variables in ansible tower app_secret and app_id resp.

<p align="center">
  <img src="https://i.imgur.com/H97IAt3.jpg" width="450" title="hover text">
</p>

    12. Create a job template filling in all the details and fill in these extra variables:
        resource_group: 
        qna_maker_name: 
        qna_maker_app_name: 
        qna_name: 
        file_name: 
        file_location: 
        bot_id: 
        site_name: 
        bot_app_plan_name:
        app_id:
        app_secret:

<p align="center">
  <img src="https://i.imgur.com/rvICHzs.jpg" width="450" title="hover text">
</p>

    13. Run the Job template.

    14. In the end you will get a iframe tag which u can add in your website src code to integrate the bot to your website.

<p align="center">
  <img src="https://i.imgur.com/JjUz0lN.jpg" width="450" title="hover text">
</p>