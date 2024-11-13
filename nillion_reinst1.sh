SLPRND=$(echo $(( RANDOM % 3600 )))
SLPT=$(( 0 + $SLPRND ))
echo "Sleeping " $SLPT "seconds"
sleep $SLPT


echo "Stopping container..."
docker stop $(docker ps -a | grep nillion)
echo "Removing container..."
docker rm $(docker ps -a | grep nillion)

echo "Starting new container..."
docker run --name nillion_verifier -d --restart=always -v ./nillion/accuser:/var/tmp nillion/verifier:v1.0.1 verify --rpc-endpoint "http://65.108.96.92:45657"
