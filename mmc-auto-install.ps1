# Script d'installation automatique de MultiMC et de ses dépendaces
# Based on WOLFforce Update Tool v2.2
# By enderman_95_


[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MultiMC install Tool" Height="450" Width="800">
        <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="67*"/>
            <ColumnDefinition Width="725*"/>
        </Grid.ColumnDefinitions>
        <Button Name="maj" Content="Installer" HorizontalAlignment="Left" Margin="526.827,350,0,0" VerticalAlignment="Top" Width="165" Height="45" FontWeight="Bold" FontSize="20" Grid.Column="1"/>
        <TextBlock HorizontalAlignment="Left" Margin="125.827,75,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="414" Height="160" FontSize="24" FontWeight="Bold" TextAlignment="Center" Grid.Column="1"><Run Text="Outil d'Installation de MultiMC"/><LineBreak/><Run FontWeight="Normal" Text="L'installation risque de prendre un moment ..."/><LineBreak/><Run FontWeight="Normal"/><LineBreak/><Run FontWeight="Normal" Text="Voulez-vous continuer ?"/></TextBlock>
        <Button Name="close1" Content="Annuler" HorizontalAlignment="Left" Margin="33,366,0,0" VerticalAlignment="Top" Width="128" Height="29" FontSize="20" Grid.ColumnSpan="2"/>

    </Grid>
</Window>  
'@
#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}

# Store Form Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | ForEach-Object{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}





[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML2 = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Installation de Java" Height="450" Width="800">
        <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="67*"/>
            <ColumnDefinition Width="725*"/>
        </Grid.ColumnDefinitions>
        <ProgressBar IsIndeterminate="True" Name="javabar" HorizontalAlignment="Left" Height="20" Margin="126,286,0,0" VerticalAlignment="Top" Width="414" Grid.Column="1"/>
        <Button Name="close2" Content="Annuler" HorizontalAlignment="Center" Margin="33,366,0,0" VerticalAlignment="Top" Width="128" Height="29" FontSize="20" Grid.ColumnSpan="2"/>
        <TextBlock Grid.Column="1" HorizontalAlignment="Left" Margin="125.8,94,0,0" TextWrapping="Wrap" Text="Telechargement et Installation de Java" VerticalAlignment="Top" Width="414" Height="86" FontSize="24"/>
        <TextBlock Grid.Column="1" HorizontalAlignment="Center" Margin="270.8,260,276.6,139" TextWrapping="Wrap" VerticalAlignment="Center" Width="179" FontSize="16"><Run Text=" Veuillez Patienter"/><Run Text=" ..."/></TextBlock>
    </Grid>
</Window> 
'@
#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml2) 
try{$instjava=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host -ForegroundColor Red "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; Start-Sleep 5 ; exit}

# Store instjava Objects In PowerShell
$xaml2.SelectNodes("//*[@Name]") | ForEach-Object{Set-Variable -Name ($_.Name) -Value $instjava.FindName($_.Name)}


# desactivated elements
# $javabar = $instjava.FindName("javabar")
# $javabar.value = 0


function DLadditionals($task)
{
    if ($task -eq "java") {
        $instjava.UpdateLayout()
        $javabar = $instjava.FindName("javabar")
        $javabar.value = ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
    }
    else {
        Write-Host -ForegroundColor Red "Erreur : impossible de résoudre la tache en cours"
    }

}


function DownloadFile($url, $targetFile)
{
   $uri = New-Object "System.Uri" "$url"
   $request = [System.Net.HttpWebRequest]::Create($uri)
   $request.set_Timeout(15000) #15 second timeout
   $response = $request.GetResponse()
   $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
   $responseStream = $response.GetResponseStream()
   $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
   $buffer = new-object byte[] 10KB
   $count = $responseStream.Read($buffer,0,$buffer.length)
   $downloadedBytes = $count

   while ($count -gt 0)
   {
       $targetStream.Write($buffer, 0, $count)
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $downloadedBytes + $count
       Write-Progress -activity "Downloading file '$($url.split('/') | Select-Object -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
       DLadditionals($ctask)
   }

   Write-Progress -activity "Finished downloading file '$($url.split('/') | Select-Object -Last 1)'"
   $targetStream.Flush()
   $targetStream.Close()
   $targetStream.Dispose()
   $responseStream.Dispose()
}


function Install-Java {
    Clear-Host
    Write-Host "Installation de Java JDK 8..."
    $ctask = "java"
    $tmppath = "C:\Users\$env:USERNAME\AppData\Local\Temp\mmc-install\"
    $tmpjf = "C:\Users\$env:USERNAME\AppData\Local\Temp\mmc-install\jdk.exe"
    Get-ChildItem "$tmppath" | Out-Null
    if ($? -eq 0) {
        New-Item -ItemType Directory -Path "$tmppath"
        if ($? -eq 0)
            {Clear-Host
            Write-Host -ForegroundColor Red "Erreur lors de la creation du repertoire temporaire"
            $instjava.Hide() | Out-Null
            Start-Sleep 5
            Exit
        }
    }

    Set-Location "$tmppath" | Out-Null
    Get-ChildItem $tmpjf | Out-Null
    if ($? -eq 1) {
        Remove-Item jdk.exe
    }
    #Invoke-WebRequest https://www.dropbox.com/s/dzz5alps2mofn14/jdk-8u301-windows-x64.exe?dl=1 -OutFile "jdk.exe"
    DownloadFile "https://www.dropbox.com/s/dzz5alps2mofn14/jdk-8u301-windows-x64.exe?dl=1" "jdk.exe"
    if ($? -eq 0)
        {Clear-Host
        Write-Host -ForegroundColor Red "Erreur lors du telechargement de Java"
        $instjava.Hide() | Out-Null
        Start-Sleep 5
        Exit
        }
    $jdklength = (Get-ChildItem $tmpjf | Measure-Object -Property Length -Sum).Sum
    if ($jdklength -ge 177687800  -and  $jdklength -gt 177687900) {
        Clear-Host
        Write-Host -ForegroundColor Red "Erreur : le fichier téléchargé n'est pas celui attendu"
        $instjava.Hide() | Out-Null
        Start-Sleep 5
        Exit
    }
    & $tmpjf /s
    if ($? -eq 0)
        {#Clear-Host
        Write-Host -ForegroundColor Red "Erreur lors de l'installation de Java"
        $instjava.Hide() | Out-Null
        Start-Sleep 5
        Exit
      }
      $instjava.Hide()
      $instmmc.Show()
}




$maj.add_Click({
    $Form.Hide() | Out-Null
        $instjava.Show() | Out-Null
        Install-Java
       
    
})

$close1.add_Click({
    $Form.Hide() | Out-Null
    exit
})
$close2.add_Click({
    $instjava.Hide() | Out-Null
    exit
})

Clear-Host
Write-Host "Bienvenue dans l'outil d'installation automatisee de MultiMC, par enderman_95_"
Start-Sleep 1
Write-Host "Vous pouvez reduire cette fenetre MAIS SANS LA FERMER. Celle-ci se fermera d'elle meme lorsque ce sera necessaire."
Start-Sleep 1
Write-Host "Si Aucune fenetre vous indiquant d'installer MultiMC n'apparait veuillez le signaler a enderman_95_ ou bien utiliser l'outil par CLI"
Start-Sleep 1

$Form.ShowDialog() | Out-null



