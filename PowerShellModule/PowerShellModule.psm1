enum ensure {
    absent
    present
}

[DscResource()]
class PSModuleResource {

    [DscProperty(Key)]
    [string]$Module_Name

    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [DscProperty(Mandatory=$false)]
    [string]$RequiredVersion

    [DscProperty(Mandatory=$false)]
    [string]$MinimumVersion

    [DscProperty(Mandatory=$false)]
    [string]$MaximumVersion

    [PSModuleResource] Get() {
        
        $state = [hashtable]::new()
        $state.Module_Name = $this.Module_Name
        $Module = Get-Module -Name $this.Module_Name -ListAvailable -ErrorAction Ignore
        if ($Module) {
            $state.Ensure = [ensure]::present
        }
        else {
            $state.Ensure = [ensure]::absent
        }

        return [PSModuleResource]$state

    }


    [void] Set() {

        if ($this.Ensure -eq 'present') {
            try {
                $arguments = $this.GetVersionArguments()
                $arguments.Add("-Name", $this.Module_Name)
                $arguments.Add("-ErrorAction", "Stop")
                Find-Module @arguments
            }
            catch {
                Write-Error -ErrorRecord $_
                throw $_
            }

            try {
                $arguments = $this.GetVersionArguments()
                $arguments.Add("-Name", $this.Module_Name)
                $arguments.Add("-Force", $true)
                Install-Module @arguments
            }
            catch {
                Write-Error -ErrorRecord $_
            }
        }
        elseif ($this.Ensure -eq 'absent') {
            $arguments = $this.GetVersionArguments()
            $arguments.Add("-Name", $this.Module_Name)
            $arguments.Add("-Force", $true)
            Uninstall-Module @arguments
        }
        else {
            Write-Verbose -Message 'This should never be reached'
        }
    }

    [bool] Test() {

        $modules = @()
        $modules += Get-Module -Name $this.Module_Name -ListAvailable -ErrorAction Ignore
        
        # When no modules with that name were found
        if ($modules.Count -eq 0)
        {
            return [bool]($this.Ensure -eq 'absent')
        }

        # We've found one or more matching modules, if neither RequiredVersion, MinimumVersion nor MaximumVersion is specified
        if ((-not $this.RequiredVersion) -and (-not $this.MinimumVersion) -and (-not $this.MaximumVersion))
        {
            return [bool]($this.Ensure -eq 'present')
        }

        # We've found one or more modules, check RequiredVersion
        if ($this.RequiredVersion)
        {
            $modules | Where-Object { [System.Version]$_.Version -eq [System.Version]$this.RequiredVersion } | % {
                return [bool]($this.Ensure -eq 'present')
            }        
        }

        # We've found one or more modules but RequiredVersion is not specified, eval MinimumVersion and MaximumVersion
        if ($this.MinimumVersion -and $this.MaximumVersion)
        {
            $modules | Where-Object { ([System.Version]$_.Version -ge [System.Version]$this.MinimumVersion) -and ([System.Version]$_.Version -le [System.Version]$this.MaximumVersion) } | % {
                return [bool]($this.Ensure -eq 'present')
            }
        }
        elseif ($this.MinimumVersion) {
            $modules | Where-Object { [System.Version]$_.Version -ge [System.Version]$this.MinimumVersion } | % {
                return [bool]($this.Ensure -eq 'present')
            }
        }
        elseif ($this.MaximumVersion) {
            $modules | Where-Object { [System.Version]$_.Version -le [System.Version]$this.MaximumVersion } | % {
                return [bool]($this.Ensure -eq 'present')
            }
        }

        # When a condition above is not matched we're not up to date
        return [bool]$false
    }

    [hashtable] GetVersionArguments() {

        if ($this.RequiredVersion -and ($this.MaximumVersion -or $this.MinimumVersion))
        {
            throw [System.ArgumentException] "The RequiredVersion argument is mutually exclusive to the MaximumVersion and MinimumVersion"
        }        

        $versionArgs = [hashtable]::new()

        if ($this.RequiredVersion)
        { 
            $versionArgs.Add("-RequiredVersion", $this.RequiredVersion)
        }
        else {
            if ($this.MinimumVersion)
            {
                $versionArgs.Add("-MinimumVersion", $this.MinimumVersion)
            }
            if ($this.MaximumVersion)
            {
                $versionArgs.Add("-MaximumVersion", $this.MaximumVersion)
            }            
        }
        return $versionArgs            
    }
}