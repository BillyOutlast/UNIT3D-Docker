# UNIT3D-Docker

A Dockerized setup for UNIT3D, an open-source private torrent tracker.

## Features

- Easy deployment with Docker and Docker Compose
- Pre-configured environment for UNIT3D
- Customizable settings

## Prerequisites

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)

## Getting Started

1. Clone this repository:
    ```bash
    git clone https://github.com/BillyOutlast/UNIT3D-Docker.git
    cd UNIT3D-Docker
    ```

2. Clone the UNIT3D source code and set up environment variables:
    ```bash
    git clone https://github.com/HDInnovations/UNIT3D.git
    cd UNIT3D
    cp .env.example .env
    ```

3. Edit the `.env` file to set a secure database username and password:
    ```env
    DB_USERNAME=your_secure_username
    DB_PASSWORD=your_strong_password
    ```
    Replace `your_secure_username` and `your_strong_password` with your own secure values.

4. Create a directory for MySQL and cache data persistence:
    ```bash
    mkdir mysql
    mkdir home
    ```
    This ensures your database and cache data is stored outside the container and persists across restarts.

5. Start the `unit3d-setup` service using Docker Compose:
    ```bash
    docker-compose up unit3d-setup
    ```
    This will initialize the UNIT3D application and perform setup tasks.


6. Run the UNIT3D service:
    ```bash
    docker-compose up unit3d
    ```
    This command will start the UNIT3D web application and its dependencies.

7. Access the UNIT3D web interface:

    Open your browser and navigate to [http://localhost:80](http://localhost:80).

    Use the default login credentials:
    - **Username:** UNIT3D
    - **Password:** UNIT3D

## Configuration

- Edit `.env` to customize database, ports, and other settings.
- See `docker-compose.yml` for service definitions.

## Troubleshooting

- Check container logs:
  ```bash
  docker-compose logs
  ```
- Ensure all required ports are available.

## License

This project is licensed under the MIT License.

## Credits

- [UNIT3D](https://github.com/UNIT3D/UNIT3D)
- Docker Community
