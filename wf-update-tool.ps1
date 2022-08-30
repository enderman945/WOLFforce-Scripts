# Script de mise à jour de la version 1.0 vers 1.1 du WOLFforce Horizon
# by enderman_95_


$wfuversion = "v2.2"
Clear-Host
Write-Host -ForegroundColor Cyan "
__        _____  _     _____ __                    
\ \      / / _ \| |   |  ___/ _| ___  _ __ ___ ___ 
 \ \ /\ / / | | | |   | |_ | |_ / _ \| '__/ __/ _ \
  \ V  V /| |_| | |___|  _||  _| (_) | | | (_|  __/
   \_/\_/  \___/|_____|_|  |_|  \___/|_|  \___\___|
                                                   
"
Write-Host -ForegroundColor Green "Update Tool $wfuversion"
Start-Sleep 1


# Initialization

# var def
$archvurl = "https://discord.gg"
$archvnm = "majwfr16v1-0to1-1.zip"
$expndarchvnm = "update-horizon-1011"
$date = Get-Date

# Functions definition
function install-maj {
    param ($cpos)
# get update file
Set-Location $templocation
addlog cd-tmp
Clear-Host
Write-Host -ForegroundColor Green "Téléchargement de la mise à jour ..."
Invoke-WebRequest $archvurl
addlog download
Start-sleep 1
# extract archive
clear-host
Write-Host -ForegroundColor Green "Préparation à l'installation de la mise à jour ..."
Expand-Archive -Path $archvnm -DestinationPath $expndarchvnm
addlog extract
# preparing to copy files
   # just for log
Set-Location $instancepath
addlog cd-instancepath
Set-Location $instancepath
# if incorrect path
if ($? -match "False") {
    Write-Host -ForegroundColor Red "Erreur : chemin de l'instance WOLFforce Horizon sur MultiMC introuvable"
    Write-Host "Entrez le chemin absolu correct :"
    $instancepath = Read-Host
    Set-Location $instancepath
    if ($? -match "False") {
        Write-Host -ForegroundColor Red "Erreur : le chemin entré est à nouveau incorrect"
        Start-Sleep 4
        Write-Host "- Le programme va donc installer la mise à jour dans $recuppath"
        Start-Sleep 4  
        Write-Host "Veuillez ensuite fusionner (par écrasement) ce dossier avec celui de l'instance manuellement"
        Start-Sleep 4
        # recup phase
        Clear-Host
        Write-Host -ForegroundColor Green "Nouvelle tentative d'installation de la MàJ en manuel ..."
        New-Item -ItemType "directory" -Path $recuppath
        Set-Location $recuppath
        # copy files
        Add-Content -Value "-- 3rd try" -Path $logpath
        copy-mos $cpos
    }
    else {
        # copy files
        Add-Content -Value "-- Files copied at 2nd try" -Path $logpath
        copy-mos $cpos
    }
}
else {
    # copy files
    Add-Content -Value "-- Files copied at 1st try" -Path $logpath
    copy-mos $cpos
}
install-tweaks $cpos
}
function addlog {
    param ($domain)
    Add-Content -Value "$domain : $?" -Path $logpath
}
function init-win {
    param ()
       # variables definition
       $wver = [System.Environment]::OSVersion.Version.Major
       if ($wver -eq "10") {
           $wverplus = "  (or newer)"
       }
       $script:templocation = "C:\Users\$env:USERNAME\AppData\Local\Temp\"
       $script:instancepath = "C:\Users\$env:USERNAME\AppData\Roaming\MultiMC\instances\WOLFforce Horizon\"
       $script:logpath = "C:\Users\$env:USERNAME\Desktop\WFupdate.log"
       $script:recuppath = "C:\$env:USERNAME\Desktop\maj-wolfforce\"
       # Preparing logs file
       Add-Content -Value "$date
       WOLFforce Update Tool Version : $wfuversion
       OS : Windows $wver $wverplus
       archvurl : $archvurl
       archvnm : $archvnm
       expndarchvnm : $expndarchvnm" -Path $logpath
}
function init-linux {
    param ()
    # variables definition
    $script:templocation = "/tmp/"
    $script:instancepath = "/home/$env:USERNAME/.local/share/multimc/instances/WOLFforce Horizon/"
    $script:logpath = "/home/$env:USERNAME/WFupdate.log"
    $script:recuppath = "/home/$env:USERNAME/maj-wolfforce"
    # Environment infos for logs
    Add-Content -Value "$date
    WOLFforce Update Tool Version : $wfuversion
    OS : Linux
    archvurl : $archvurl
    archvnm : $archvnm
    expndarchvnm : $expndarchvnm" -Path $logpath
}
function copy-mos {
    param ($cpmos)
    if ($cpmos -match "W") {
        Clear-Host
        Write-Host -ForegroundColor Green "Installation de la mise à jour ..." 
        Copy-Item $templocation$expndarchvnm\mods\* .\mods\
        addlog cp-mods
        Copy-Item $templocation$expndarchvnm\config\* .\config\
        addlog cp-cfg
        Copy-Item $templocation$expndarchvnm\rcpacks\* ./resourcepacks\
        addlog cp-rcpacks
        Copy-Item $templocation$expndarchvnm\shaders\* .\shaderspacks\
        addlog cp-shaders
    }

    elseif ($cpmos -match "L") {
        Clear-Host
        Write-Host -ForegroundColor Green "Installation de la mise à jour ..." 
        Copy-Item $templocation$expndarchvnm/mods/* ./mods/
        addlog cp-mods
        Copy-Item $templocation$expndarchvnm/config/* ./config/
        addlog cp-cfg
        Copy-Item $templocation$expndarchvnm/rcpacks/* ./resourcepacks/
        addlog cp-rcpacks
        Copy-Item $templocation$expndarchvnm/shaders/* ./shaderspacks/
        addlog cp-shaders
    }
    else {
        Write-Host -ForegroundColor Red "Error : Failed to determine OS while copying files"
        Add-Content -Value "Error : cpmos (L or W) = $cpmos" -Path $logpath
        Start-Sleep 4
        exit
    }
}
function install-tweaks {
    param ($tmos)
    Write-Host "No additionnal content to install"
}


# check os
  # if it's linux
if ($IsLinux -match "True") {
    init-linux
    install-maj L
    # separating for eventuals future logs
    Add-Content -Value "------------------------------------------------------------------------
 " -Path $logpath
}

  # if it's windows
elseif ($env:OS -match "Windows_NT") {
    init-win
    install-maj W
       # separating for eventuals future logs
    Add-Content -Value "------------------------------------------------------------------------
 " -Path $logpath
}



elseif ($IsMacOS -match "True" ) {
    Write-Host -ForegroundColor Red "Erreur : Désolé mais les Mises à Jour automatiques ne sont pas disponibles pour MacOS"
    Start-Sleep 2
    Write-Host "Aussi quelle idée d'être sur macOS :) "
}

else {
    Write-Host -ForegroundColor Red "Erreur : Impossible de déterminer le système d'exploitation hôte"
    os= Read-Host "
    Précisez votre système d'exploitation :
            W: Windows     L: Linux       : "
    if ($os -match "W") {
        init-win
        Add-Content -Value "Failed to determine OS on 1st try" -Path $logpath
        install-maj W
       # separating for eventuals future logs
       Add-Content -Value "------------------------------------------------------------------------
" -Path $logpath
    }
    elseif ($os -match "L") {
        init-linux
        Add-Content -Value "Failed to determine OS on 1st try" -Path $logpath
        install-maj L
       # separating for eventuals future logs
       Add-Content -Value "------------------------------------------------------------------------
 " -Path $logpath
    }
    else {
        Write-Host -ForegroundColor Red "Erreur l'entrée [ $os ] n'est pas valide. Fin du programme."
        Start-Sleep 4
        exit
    }
}