# `yuruna` ingress issues in a localhost

Special not about localhost ingress issues.

## No connectivity

- Before deploying workloads, make sure that ports to be used are not held by other processes. It is also common that, in the `localhost`, the Docker Desktop process itself holds on to the ports, preventing the local load balancer from binding (see example of [issue](https://github.com/docker/for-mac/issues/4903) repeatedly reported).
- Solving that may require quitting and starting Docker again (suprisingly, the Restart item in the menu doesn't have the same effect).

Back to main [readme](../README.md)
