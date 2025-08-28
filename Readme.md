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

4. Build and start the containers:
    ```bash
    docker-compose up -d
    ```

4. Access UNIT3D at `http://localhost:8000`

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
