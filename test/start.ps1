$imageNameTag = "navdocker.azurecr.io/dynamics-nav:devpreview-finus"
docker rm navserver -f
docker pull $imageNameTag
docker run --name navserver `
           --hostname navserver `
           --volume c:\myfolder:c:\run\my `
           --env accept_eula=Y `
           --env usessl=N `
           --env username="vmadmin" `
           --env password="P@ssword1" `
           --env ExitOnerror=N `
           --env ClickOnce=Y `           
           $imageNameTag
