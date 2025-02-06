# webapp
# Health Check API

## Description
This API provides a health check mechanism for web services, built with Node.js and Express. It uses a MySQL database to log health check entries and ensures the service's availability.

## Prerequisites
- Node.js : 20.17.0
- npm: 10.8.2
- MySQL Server: 9.2.0
- Visual Studio Code

1.⁠ ⁠*Clone the repository:*
   ⁠    `git clone [repository-url] `⁠

2.⁠ ⁠*Navigate to the project directory:*
   ⁠ `cd [project-directory]`

3.⁠ ⁠*Install dependencies:*
   ⁠ `npm install` ⁠

4.⁠ ⁠*Set up the environment variables:*
   `Create a ⁠ .env ⁠ file in the root directory of the project and add the following environment variables`

5.⁠ ⁠*Start the application:*
⁠ `npm start` ⁠

## API Endpoints

### `GET /healthz`
- **Description:** Performs a health check and logs the check in the database.
- **Response Status Codes:**
- `200 OK`: Health check was successful, and the system is operating normally.
- `503 Service Unavailable`: Health check failed due to a server or database error.

### `POST, PUT, DELETE /healthz`
- **Description:** These methods are not allowed for this endpoint.
- **Response Status Codes:**
- `405 Method Not Allowed`: Indicates that the request method is not supported by the endpoint.

### `All other routes`
- **Description:** Handles all other undefined routes.
- **Response Status Codes:**
- `404 Not Found`: The requested route does not exist.

## Additional Information
- The application uses headers to prevent caching and improve security by specifying:
- `Cache-Control: no-cache, no-store, must-revalidate` to ensure responses are not cached.
- `Pragma: no-cache` to avoid caching on older HTTP/1.0 proxies.
- `X-Content-Type-Options: nosniff` to block browsers from MIME-sniffing a response away from the declared content-type.


# Assignment - 02 

A comprehensive Bash script for setting up a cloud-based web application infrastructure with MySQL database and Node.js application deployment.

## Features
- Automated system updates and package installations
- Swap space configuration (1GB)
- MySQL installation and security configuration
- Node.js and npm setup
- Application user and group management
- Systemd service configuration

## Overview
This test suite validates the functionality of the /healthz endpoint, ensuring proper health check responses and error handling according to REST API best practices.

## Features Tested

- Health Check Endpoint
- Basic health check functionality
- Database connection verification
- Security headers validation
- Query parameter handling
- Content-length header validation
- HTTP Method Validation
- GET requests (valid)
- POST requests (invalid)
- PUT requests (invalid)
- DELETE requests (invalid)

## Health Check Validation
Verifies 200 response for successful database connection
Validates required security headers:
Cache-Control
Pragma
X-Content-Type-Options

## Error Handling
- 400 response for requests with query parameters
- 400 response for requests with Content-Length header
- 405 response for invalid HTTP methods
- 404 response for non-existent routes


## Error Status Code	Description
- 200	Successful health check
- 400	Invalid request parameters
- 404	Route not found
- 405	Method not allowed
