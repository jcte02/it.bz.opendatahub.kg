  We will be using `https://kg.opendatahub.bz.it/` as the base URI below. Replace it if necessary.

# Installation

1. Add a host mapping if you are running on localhost:

     ```hosts
     127.0.0.1 kg.opendatahub.bz.it
     ```

     to `/etc/hosts` (on Linux) or `C:\Windows\System32\Drivers\etc\hosts` (on Windows).

2. Clone this repository with submodules:

     ```bash
     git clone --recursive git@github.com:AtomGraph/OpenDataHub.git
     ```

     or if you have cloned it already

     ```bash
     git submodule update --remote
     ```

     This should add a `linkeddatahub` folder with the submodule.

# Usage

1. Copy the `.env_sample` file to `.env` using the following command: `cp .env_sample .env`.
2. With your editor of choice, edit the `.env` file, setting a `OWNER_CERT_PASSWORD` and a `SECRETARY_CERT_PASSWORD`. They can be the same password, and must be at least 6 characters long.
3. If needed, you can customize the default values of the other variables, like for example the SparQL `ENDPOINT`, or the application's `HOST`.
4. You can now run the services using the following command:

   ```bash
   docker-compose up --build
   ```

5. The first time you run the services, the `Linked Data Hub` will automatically install itself, generating all the required certificates. This may require a bit of time, depending on the resources available on your machine.
6. Open <https://kg.opendatahub.bz.it>

_:warning: The very first page load can take a while (or even result in `504 Bad Gateway`) while RDF ontologies and XSLT stylesheets are being loaded into memory._

# Configuration

- Base URI is configured in the `.env` file
- OpenDataHub SPARQL endpoint is:
  - configured as the `ENDPOINT` environment variable for the `processor` service
- The server's TLS certificate (e.g. LetsEncrypt) can be mounted into the `nginx` container and specified in its `/etc/nginx/nginx.conf` config file

# Reset datasets

1. Kill the services and remove volumes:

   ```bash
   docker-compose down -v
   ```
