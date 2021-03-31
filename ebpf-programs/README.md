# eBPF Programs

In this directory are stored the eBPF programs that can be managed with [CB-Manager](../platform/cb-manager/README.md).

## Instruction

1. Create a new directory for a new eBPF program.

2. To insert the eBPF program in the ASTRID Catalog please see the related [CB-Manager documentation](https://astrid-cb-manager.readthedocs.io/en/latest/ebpf-program-catalog.html).

3. To deploy a new instance of the eBPF program available in the ASTRID Catalog please see the related
   [CB-Manager documentation](https://astrid-cb-manager.readthedocs.io/en/latest/ebpf-program-instance.html).


## Docker images

To start the eBPF program in a Docker image using a [Polycube](https://github.com/polycube-network/polycube) installation, the steps are:

1. Get and run the docker image following the [Polycube documentation](https://polycube-network.readthedocs.io/en/latest/quickstart.html#docker).
2. Follow the documentation to configure the Polycube instance.
3. Deploy the eBPF program in the Polycube instance using the [Dynmon service](https://polycube-network.readthedocs.io/en/latest/services/pcn-dynmon/dynmon.html).
