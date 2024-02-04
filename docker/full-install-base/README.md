# SmartCGMS full build

This Dockerfile contains a set of commands to make SmartCGMS full build working inside a Docker container.

## Usage

To build the image, simply enter the following command:

```
docker build -t scgms .
```

The Docker image will be built. Then, you may attach into the container using e.g., the following command:

```
docker run -it --rm --privileged --pid=host scgms
```

## Notes

This image merely serves as a base for future development; no configurations, environments, experimental setups are included.
