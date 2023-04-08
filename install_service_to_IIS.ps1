Import-Module WebAdministration  
  
$iisAppPoolName = "BCCloudScopeOnPrem"  
$iisAppPoolDotNetVersion = "v7.0"  
  
$iisWebsiteFolderPath = Get-Location
$iisWebsiteName = "BCCloudScopeOnPrem"  
  
$iisWebsiteBindings = @(  
   @{protocol="http";bindingInformation="127.0.0.1:49352"} 
)  
  
if (!(Test-Path IIS:\AppPools\$iisAppPoolName -pathType container))  
{  
New-Item IIS:\AppPools\$iisAppPoolName  
Set-ItemProperty IIS:\AppPools\$iisAppPoolName -name "managedRuntimeVersion" -value ""  
}  
  
if (!(Test-Path IIS:\Sites\$iisWebsiteName -pathType container))  
{  
New-Item IIS:\Sites\$iisWebsiteName -bindings $iisWebsiteBindings -physicalPath $iisWebsiteFolderPath  
Set-ItemProperty IIS:\Sites\$iisWebsiteName -name applicationPool -value $iisAppPoolName  
}  

 
$User = "IIS AppPool\BCCloudScopeOnPrem"  
$Acl = Get-Acl $iisWebsiteFolderPath  
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule($User,"FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")  
$Acl.SetAccessRule($Ar)  
set-acl -aclobject:$Acl -path:$iisWebsiteFolderPath