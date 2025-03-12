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

# Assignment - 03

# GitHub Actions for Webapp

This repository leverages GitHub Actions to run continuous integration (CI) tests for a web application that relies on Node.js and MySQL. The workflow is automatically triggered for every pull request targeting the `main` branch.

## Workflow Overview

The GitHub Actions workflow is defined in a YAML file and includes the following configuration:

- **Trigger:**  
  The workflow runs on pull requests to the `main` branch.

- **Job Environment:**  
  The CI job runs on an `ubuntu-latest` runner and sets up a MySQL service using the official MySQL 8.0 Docker image. Health checks ensure that the MySQL service is ready before tests are executed.

- **Health Check Options:**  
  The MySQL container uses health options to ensure it's ready:
  - `--health-cmd="mysqladmin ping --silent"`
  - `--health-interval=10s`
  - `--health-timeout=5s`
  - `--health-retries=3`

## Workflow Steps

1. **Checkout Code:**  
   Uses `actions/checkout@v3` to retrieve the repository code.

2. **Setup Node.js:**  
   Uses `actions/setup-node@v3` to install Node.js version 16.

3. **Install Dependencies:**  
   Runs `npm install` to install required packages.

4. **Wait for MySQL Service:**  
   Executes a script to wait until the MySQL service is ready by checking if port `3306` is open.

5. **Run Tests:**  
   Executes `npm test` to run the application's test suite.

# Assignment - 04

# Packer & CI/CD Configuration

This configuration is designed to build custom machine images for a web application on both AWS and GCP using Packer. It also integrates GitHub Actions workflows to validate and test the build process.

## Key Features

- **Dual Cloud Support:**  
  Creates custom images using the Amazon EBS and Google Compute builders.

- **Automated Provisioning:**  
  Copies the web application package and setup script into the image, then executes the script to install dependencies, set up a local database, and configure services.

- **Continuous Integration:**  
  GitHub Actions workflows automatically check the Packer template formatting and validation on pull requests, and run integration tests using a MySQL container and Node.js.

- **Parameterization:**  
  Uses variables to customize settings such as regions, credentials, instance types, and database credentials, ensuring flexibility and security.

## Usage

1. Set the required variables and secrets in your repository (e.g., AWS and GCP credentials, database details).
2. Push your changes to trigger the GitHub Actions workflows for validation and testing.
3. Upon merging a pull request, the custom images will be built concurrently on AWS and GCP.