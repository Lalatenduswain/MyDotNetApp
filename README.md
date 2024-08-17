# Simple .NetApp Project : **Host .NET Core Application on Docker**

#### Project Structure:
```plaintext
MyDotNetApp/
├── Dockerfile
├── MyDotNetApp.csproj
├── Program.cs
├── Properties/
│   └── launchSettings.json
├── appsettings.json
└── README.md
```



## Overview

This project demonstrates how to host a simple `.NET Core` Web API application inside a Docker container. The application provides a weather forecast service that can be accessed via `http://mydotnetapp.local/`. This project includes instructions on how to set up a Docker container, configure Nginx as a reverse proxy, and push the Docker image to Docker Hub.

## Prerequisites

- **.NET Core SDK**: Installed via Snap.
- **Docker**: Installed and configured.
- **Nginx**: Installed and configured on the host machine.

## Steps to Run the Project

### 1. Clone the Repository

```bash
git clone https://github.com/Lalatenduswain/MyDotNetApp.git
cd MyDotNetApp
```

### 2. Install .NET Core SDK

```bash
sudo snap install dotnet-sdk --classic
sudo snap alias dotnet-sdk.dotnet dotnet
dotnet --version
```

### 3. Build and Run the .NET Core Application Locally

```bash
dotnet restore
dotnet build
dotnet run
```

Access the application locally:

```bash
http://localhost:5283/weatherforecast
```

### 4. Create a Docker Image

```bash
docker build -t mydotnetapp .
```

### 5. Run the Docker Container

```bash
docker run -d -p 8080:8080 --name myapp mydotnetapp
```

### 6. Configure Nginx as a Reverse Proxy

Create a new configuration file for Nginx:

```bash
sudo nano /etc/nginx/sites-available/mydotnetapp
```

Paste the following configuration:

```nginx
server {
    listen 80;
    server_name mydotnetapp.local;

    # Redirect root requests to /weatherforecast
    location = / {
        return 301 /weatherforecast;
    }

    # Proxy requests to the Docker container
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the configuration and reload Nginx:

```bash
sudo ln -s /etc/nginx/sites-available/mydotnetapp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

Update your `/etc/hosts` file to point `mydotnetapp.local` to `localhost`:

```bash
echo '127.0.0.1 mydotnetapp.local' | sudo tee -a /etc/hosts
```

### 7. Access the Application

Now you can access the application at:

```bash
http://mydotnetapp.local/
```

### 8. Push Docker Image to Docker Hub

```bash
docker login
docker tag mydotnetapp lalatenduswain/mydotnetapp:latest
docker push lalatenduswain/mydotnetapp:latest
```

### 9. Search for Docker Image on Docker Hub

```bash
docker search mydotnetapp
```

## Best Practices

1. **Dockerfile Optimization**:
   - Use multi-stage builds to minimize the final image size.
   - Keep the Dockerfile and `.dockerignore` file up to date to reduce build context size.
   
2. **Environment Variables**:
   - Use environment variables for configuration instead of hardcoding values in your application.
   - Store sensitive information like connection strings in a secure way.

3. **CI/CD Integration**:
   - Integrate Docker with your CI/CD pipeline to automate the build, test, and deployment processes.

4. **Monitoring and Logging**:
   - Implement logging within your application and ensure that logs can be easily accessed from within the Docker container.
   - Use monitoring tools like Prometheus or Grafana to keep an eye on container performance.

5. **Security**:
   - Regularly update your base images to mitigate vulnerabilities.
   - Use Docker Bench Security to check for common security issues in your Docker environment.

6. **Testing**:
   - Write unit and integration tests for your application and run them as part of your Docker build process.

## Conclusion

By following this guide, you have successfully containerized a `.NET Core` Web API application and hosted it using Docker and Nginx. This setup can be extended and scaled to host more complex applications with advanced configurations.

---

### Program.cs (Final Version)

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

// Map root URL to WeatherForecast
app.MapGet("/", () =>
{
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecastRoot")
.WithOpenApi();

// Map the original /weatherforecast URL
app.MapGet("/weatherforecast", () =>
{
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast")
.WithOpenApi();

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
```

This guide should help you get started with hosting a `.NET Core` application on Docker with best practices in place.
