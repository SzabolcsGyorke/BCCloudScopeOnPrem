# BCCloudScopeOnPrem
Access to local file system with cloud scope extensions on prem - Business Central

The main idea is to mimic the FileManagement codeunit's local file functions without having to use the onPrem scope in our extension.

For this we can use a simple .net web api application which by default listens on http://localhost:49352/BCCouldScopeOnPrem and waits for commands from the BC middle tier. The defult server adderss and port can be changed on the **Company Information** page.

**It is important that it should only be accessible on localhost due to it is only uses http.**

Prerequisites:
* .net 7 - web api
* ASP.NET Core Runtime - https://dotnet.microsoft.com/en-us/download/dotnet/7.0
* Business Central 21

Version 0.2.0.0
* IIS installation script
* BC Functions: CopyServerFile, MoveServerFile

Version 0.1.0.0

You can connect to the .net web api service on localhost and ask the following:
* Files in a folder
* Upload file content to a TempBlob
* Download to server from TempBlob
* Get file info (size, date)
* Create Folder on server
* Delete File from server

## Installation
1. Download the release or clone the repo and compile your own
2. Create a directory for the web component 
3. Run the install_service_to_IIS.ps1 in the web components folder
4. Install the BC Extensions

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

## Usage
All the functions are in the codeunit 51000 "BC OnPrem File Functions":

### procedure GetServerDirectoryFilesList(var NameValueBuffer: Record "Name/Value Buffer"; DirectoryPath: Text)
Returns the files from the server folder.
| Parameter | Description |
| --- | --- |
| NameValueBuffer | Return value with the found files |
| DirectoryPath | Server directory |

### procedure GetServerDirectoryFilesListInclSubDirs(var TempNameValueBuffer: Record "Name/Value Buffer" temporary; DirectoryPath: Text)
Returns the files from the server folder and subfolders.
| Parameter | Description |
| --- | --- |
| NameValueBuffer | Return value with the found files |
| DirectoryPath | Server directory |

### procedure BLOBImportFromServerFile(var TempBlob: Codeunit "Temp Blob"; FilePath: Text)
Uploads a file form the server to a tempblob.
| Parameter | Description |
| --- | --- |
| TempBlob | Return value with the file content |
| FilePath | Full file path on the server |

### procedure BLOBExportToServerFile(var TempBlob: Codeunit "Temp Blob"; FilePath: Text): Boolean
Downloads the contents of the tempblob to a server file.
Returns true if the operation was sucsessful.

| Parameter | Description |
| --- | --- |
| TempBlob | File content |
| FilePath | Full file path on the server |

### procedure CreateServerFolder(FolderPath: Text): Boolean
Creates a folder on the server
Returns true if the operation was sucsessful.

| Parameter | Description |
| --- | --- |
| FolderPath | Full file path on the server where the last directory is the one to create |

### procedure DeleteServerFile(FilePath: Text): Boolean
Deletes a file on the server.
Returns true if the operation was sucsessful.

| Parameter | Description |
| --- | --- |
| FilePath | Full file path and name |

###  procedure GetServerFileProperties(FullFileName: Text; var ModifyDate: Date; var ModifyTime: Time; var Size: BigInteger): Boolean;
Returns file information: last changed date, time and size.
Returns true if the operation was sucsessful.

| Parameter | Description |
| --- | --- |
| FullFileName | Full file path and name |
| ModifyDate | Return: Last modified date |
| ModifyTime | Return: Last modified time |
| Size | Return: file size |

### procedure CopyServerFile(FromFileNamePath: Text; ToFileNamePath: Text): Boolean
Copies a file from one folder to another.
Returns true if the operation was sucsessful.

| Parameter | Description |
| --- | --- |
| FromFileNamePath | Full file path and name copied from |
| ToFileNamePath | Full file path and name copied to |

### procedure MoveServerFile(FromFileNamePath: Text; ToFileNamePath: Text): Boolean
Moves a file between folders on the server.
Returns true if the operation was sucsessful.

| Parameter | Description |
| --- | --- |
| FromFileNamePath | Full file path and name moved from |
| ToFileNamePath | Full file path and name moved to |
