enum ensure {
    absent
    present
}

[DscResource()]
class PSModuleResource {

    [DscProperty(Key)]
    [string] $Module_Name

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [PSModuleResource] Get () {
        
        $state = [hashtable]::new()
        $state.Module_Name = $this.Module_Name

        $Module = Get-Module -Name $this.Module_Name -ListAvailable -ErrorAction Ignore
        if ($Module) {
            $state.Ensure = [ensure]::present
        }
        else {
            $state.Ensure = [ensure]::absent
        }

        return [PSModuleResource] $state

    }


    [void] Set () {

        if ($this.Ensure -eq 'present') {
            try {
                Find-Module -Name $this.Module_Name -ErrorAction Stop
            }
            catch {
                Write-Error -ErrorRecord $_
                throw $_
            }

            try {
                Install-Module -Name $this.Module_Name -Force
            }
            catch {
                Write-Error -ErrorRecord $_
            }
        }
        elseif ($this.Ensure -eq 'absent') {
            Uninstall-Module -Name $this.Module_Name -Force
        }
        else {
            Write-Verbose -Message 'This should never be reached'
        }

    }

    [bool] Test () {
        
        $Module = Get-Module -Name $this.Module_Name -ListAvailable -ErrorAction Ignore

        if ($Module -and ($this.Ensure -eq 'present')) {
            return [bool] $true
        }
        elseif ((-not $Module) -and ($this.Ensure -eq 'absent')) {
            return [bool] $true
        }
        elseif (($Module) -and ($this.Ensure -eq 'absent')) {
            return [bool] $false
        }
        elseif ((-not $Module) -and ($this.Ensure -eq 'present')) {
            return [bool] $false
        }
        else {
            Write-Verbose -Message 'THis should never be reached'
            return [bool] $false
        }
    }

}