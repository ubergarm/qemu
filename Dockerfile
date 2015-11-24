FROM debian:sid

RUN apt-get update && apt-get install -y --no-install-recommends \
		qemu-system \
		qemu-utils \
		qemu-user-static \
		binfmt-support \
		debootstrap \
	&& rm -rf /var/lib/apt/lists/*

COPY qemu-arm /usr/share/binfmts/
CMD ["/bin/bash"]
