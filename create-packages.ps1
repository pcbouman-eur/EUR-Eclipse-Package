$exam_target = "package-exam"
$regular_target = "package-regular"
$eclipse_url = "http://ftp.snt.utwente.nl/pub/software/eclipse//technology/epp/downloads/release/2018-12/R/eclipse-java-2018-12-R-win32-x86_64.zip"
$jdk_url = "https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_windows-x64_bin.zip"
$temp_dir = "downloads"

Write-Host "Performing pre-package creation cleanup"
Remove-Item $exam_target -Recurse -ErrorAction Ignore
Remove-Item $regular_target -Recurse -ErrorAction Ignore
Remove-Item $temp_dir -Recurse -ErrorAction Ignore
Write-Host "Done with the cleanup"

Write-Host "Creating relevant directories"
New-Item -ItemType directory -Path $temp_dir | Out-Null
New-Item -ItemType directory -Force -Path $exam_target | Out-Null
New-Item -ItemType directory -Force -Path $regular_target | Out-Null
Write-Host "Done creating directories"

Write-Host "Starting download of the Eclipse distribution"
Invoke-WebRequest -Uri $eclipse_url -OutFile $temp_dir'\eclipse.zip'
Write-Host "Done downloading Eclipse"
Write-Host "Starting download of OpenJDK"
Invoke-WebRequest -Uri $jdk_url -OutFile $temp_dir'\jdk.zip'
Write-Host "Done downloading OpenJDK"

# The exam package makes use of the system's default jre rather than a bundled jdk
Write-Host "Extracting Eclipse to target folder of the exam package"
Expand-Archive -Path $temp_dir'\eclipse.zip' -DestinationPath $exam_target
Write-Host "Copying custom files into the exam package"
Copy-Item src\exam\* -Recurse -Force -Destination $exam_target'\eclipse'
Write-Host "Done creating the exam package"

# The regular package makes use of a bundled jdk rather than the system's default jre
Write-Host "Extracting Eclipse to the target folder of the regular package"
Expand-Archive -Path $temp_dir'\eclipse.zip' -DestinationPath $regular_target
Write-Host "Extracting OpenJDK to the target folder of the regular package"
Expand-Archive -Path $temp_dir'\jdk.zip' -DestinationPath $regular_target'\eclipse' 
Write-Host "Copying custom files into the regular package"
Copy-Item src\regular\* -Recurse -Force -Destination $regular_target'\eclipse'
Write-Host "Done creating the regular package"