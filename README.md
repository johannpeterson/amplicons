# Files for analysis of amplicons

## Usage
Build the Docker image, if not already built:
```
docker build --pull -t nijhawanlab/amplicons .
```
Then, start a Docker container using the `start.sh` script, or like this:
```
docker run -it \
       --mount type=bind,source="$(pwd)",target=/home/bio/data \
       --mount type=bind,source="$LOCAL_SOURCE_DIR",target=/home/bio/extsource \
       nijhawanlab/amplicons
```
