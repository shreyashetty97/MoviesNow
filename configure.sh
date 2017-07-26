#!/bin/bash
echo "Assigning execute permission..."
chmod +x MoviesNow.sh
echo "Building Directory..."
DIRECTORY="/bin"
if [ ! -d "$DIRECTORY" ]
then
	mkdir $DIRECTORY
fi
sudo cp MoviesNow.sh $DIRECTORY/MoviesNow
echo "Done installing. type MoviesNow -h to get started."
