$imageNameTag = "navdocker.azurecr.io/dynamics-nav:devpreview-finus"
docker rm myserver -f
docker pull $imageNameTag
docker run --name myserver `
           --hostname myserver `
           --volume c:\myfolder2:c:\run\my `
           --env accept_eula=Y `
           --env usessl=N `
           --env auth=Windows `
           --env username="vmadmin" `
           --env password="NavDevPre@2017" `
            --env ClickOnce=Y `
           --env ExitOnerror=N `
           $imageNameTag
