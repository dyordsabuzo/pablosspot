version: \"3.9\"
services:
    wordpress:
        image: wordpress:latest
        restart: always
        environment:
            WORDPRESS_DB_HOST: ${dbhost}
            WORDPRESS_DB_USER: ${dbuser}
            WORDPRESS_DB_PASSWORD: ${dbpassword}
            WORDPRESS_DB_NAME: ${dbname}

    nginx:
        depends_on: 
            - wordpress
        image: nginx:1.18-alpine
        restart: always
        command: \"/bin/sh -c 'nginx -s reload; nginx -g \\\"daemon off;\\\"'\"
        ports:
            - \"${external_port}:80\"
        volumes:
            - ./nginx:/etc/nginx/conf.d