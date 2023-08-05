# Save the working path, which should be directly in the root folder of the project
$workingPath = (Get-Item $MyInvocation.MyCommand.Path).DirectoryName

# Build the web app
flutter build web

# Compress the updated web folder
Compress-Archive -Path ($workingPath + '\build\web') -DestinationPath ($workingPath + '\build\web.zip') -Force

# Copy the compressed folder to the server. This will ask for the password of the vampulv user.
scp ($workingPath + '\build\web.zip') vampulv@10.43.34.8:~

# Remove the compressed folder from the local machine
Remove-Item ($workingPath + '\build\web.zip')

# All of this is done in one command so that the password for the vampulv user is only asked for once. It will still need to be provided twice, but to prevent that, we would have to save the password, and I am not sure how secure that is.
ssh vampulv@10.43.34.8 ('{
    # Replace the old web folder with the new one
    rm -r web
    unzip -q web.zip
    rm web.zip

    # For some reason the vampulv user does not have permission to open these folders when they are unziped
    chmod u+x web/assets
    chmod u+x web/assets/assets

    # Python http.server that serves the web folder to clients get confused when we replace the folder. To solve this, we kill the screen where it is run. The service is set up so that it is then automatically started again.
    screen -X -S "$(screen -ls | grep -o [0-9]*\.vampulv-web)" kill
}' -replace '\r', '')
