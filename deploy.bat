#!/bin/sh

# rename to deploy, edit connect data and make executable (chmod +x deploy)
hugo --cleanDestinationDir && rsync -avz --delete public/ sftp@ogobrecht.com@ssh.strato.de:~

exit 0