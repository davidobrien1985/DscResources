# Description:
This PowerShell DSC resource will download or remove PowerShell modules to or from a machine.

It uses WMF 5 functionality (Find-Module, Install-Module, Uninstall-Module) to handle modules uploaded to the Microsoft PowerShell Gallery. (http://www.powershellgallery.com)

## The module contains the following resources:

### PSModuleResource
- **`[String]` Module_Name** (_Key_): The name of the module
- **`[String]` Ensure** (_Write_): Ensure that the module is present or absent { *Present* | Absent }. Defaults to Present.
- **`[String]` RequiredVersion** (_Write_) : The RequiredVersion of the module. RequiredVersion is mutually exclusive to the MinimumVersion and MaximumVersion
- **`[String]` MinimumVersion** (_Write_) : The MinimumVersion of the module
- **`[String]` MaximumVersion** (_Write_) : The MaximumVersion of the module
- **`[String]` InstallScope** (_Write_) : The scope in which to install the module { *allusers* | currentuser }. Defaults to allusers
- **`[String]` Repository** (_Write_) : The name of a registered repository from which to download the module. Defaults to PSGallery. To register a new repository use the PSModuleRepositoryResource


### PSModuleRepositoryResource
- **`[String]` RepositoryName** (_Key_): The name of the repository
- **`[String]` Ensure** (_Write_): Ensure that the module is present or absent { *Present* | Absent }. Defaults to Present.
- **`[String]` RepositoryInstallationPolicy** (_Write_): Whether the repository should be trusted or untrusted { Trusted | *Untrusted* }. Defaults to untrusted.
- **`[String]` RepositorySourceLocation** (_Required_): The location from where modules should be downloaded
- **`[String]` RepositoryPublishLocation** (_Write_): The location to where modules should be published

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
Using a custom repository by depending on the repository resource
````powershell
PSModuleRepositoryResource CustomRepository
{
    Ensure = 'present'
    RepositoryName = 'MyCustomRepositoryName'
    RepositoryPublishLocation = 'http://www.somelocation/publish'
    RepositorySourceLocation = 'http://www.somelocation/src'
}
PSModuleResource AzureExt
{
    Ensure = 'present'
    Module_Name = 'AzureExt'
    Repository = 'MyCustomRepositoryName'
    DependsOn = @('[PSModuleRepositoryResource]CustomRepository')    
}
````

## More Info:
Read https://david-obrien.net/2015/09/powershell-dsc-to-manage-powershell-modules/
