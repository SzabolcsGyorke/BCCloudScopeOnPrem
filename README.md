# BCCloudScopeOnPrem
Access to local file system with cloud scope extensions on prem - Business Central

The main idea is to mimic the FileManagement codeunit's local file functions without having to use the onPrem scope in our extension.

For this we can use a simple .net web api application which by default listens on http://localhost:49352/BCCouldScopeOnPrem and waits for commands from the BC middle tier.

**It is important that it should only be accessible on localhost due to it is only uses http.**

Prerequisites:
* .net 7 - web api
* Business Central 21

Missing parts
- File copy, move function
- IIS installer PS script

Version 0.1.0.0

You can connect to the .net web api service on localhost and ask the following:
* Files in a folder
* Upload file content to a TempBlob
* Download to server from TempBlob
* Get file info (size, date)
* Create Folder on server
* Delete File from server

## Testing
Deploy the BC app and search for "BC OnPrem File Tester"
<img width="1207" alt="image" src="https://user-images.githubusercontent.com/64136814/230488146-310aa523-01fc-425a-b656-4bc186a5b2ef.png">

**Important to note that paths can be separated by \\\ or \ backslashes but can't mix them!**

You can find Directory and File actions:
+ Get Directory list - get the all the files from the Server Directory From field
+ Get Directory and Subdirectory List - adds all the files from the subdirectories 
+ Create Directory - creates a directory named as the "Server Directory To" to the "Server Directory From" folder
- Open and Display file content - uploads and display the file content in a message box (text files preferred)
- Delete File - deletes the selected file (no multiselecting)
- Save File To Server - gets the company info image and saves it as "cronus.jpg" to the "Server Directory To" folder
- Get File Info - displays basic file information (date, size, name)

On the list - just uses the name/value buffer table:
* ID - PK
* Name - file name
* Value - folder
* Value Long - path and filename combined

Before run any BC query first start the web api service with the "BCCloudScopeOnPrem.exe" executable.
If everything is right you should see this:
![image](https://user-images.githubusercontent.com/64136814/230490059-ec909298-9bc5-4212-9556-f2b062c2be61.png)


The plan is to have an install script for IIS so it could work independently of the logged in user.
