# Description:
This PowerShell DSC resource will download or remove PowerShell modules to or from a machine.

It uses WMF 5 functionality (Find-Module, Install-Module, Uninstall-Module) to handle modules uploaded to the Microsoft PowerShell Gallery. (http://www.powershellgallery.com)

# Usage:

In DSC document:
````powershell

Configuration MyConfig
{
   Import-Dscresource -ModuleName PowerShellModule    

   PSModuleResource AzureExt
    {
        Ensure = 'present'
        Module_Name = 'AzureExt'        
    }

}
````
Via Invoke-DscResource:
````powershell
Invoke-DscResource -Name PSModuleResource -Method Set -ModuleName PowerShellModule -Property @{Ensure='absent';Module_Name='AzureExt'} -Verbose
````
Using RequiredVersion
````powershell
PSModuleResource AzureExt
{
    Ensure = 'present'
    Module_Name = 'AzureExt'
    RequiredVersion = '1.0.0.0'        
}
````
Using MinimumVersion and MaximumVersion (mutually exclusive to RequiredVersion)
````powershell
PSModuleResource AzureExt
{
    Ensure = 'present'
    Module_Name = 'AzureExt'
    MinimumVersion = '1.0.0.0'
    MaximumVersion = '2.0.0.0'        
}
````
Installing modules into different scopes ('allusers'  or 'currentuser'). Default is 'allusers'
````powershell
PSModuleResource AzureExt
{
    Ensure = 'present'
    Module_Name = 'AzureExt'
    MinimumVersion = '1.0.0.0'
    MaximumVersion = '2.0.0.0'
    InstallScope = 'allusers'        
}
````

## More Info:
Read http://www.david-obrien.net/?p=3108
