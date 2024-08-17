# Use the official .NET 8.0 runtime image as a base
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
# Expose the port your app is listening on

# Use the .NET 8.0 SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY MyDotNetApp.csproj .
RUN dotnet restore "MyDotNetApp.csproj"
COPY . .
RUN dotnet build "MyDotNetApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MyDotNetApp.csproj" -c Release -o /app/publish

# Copy the build artifacts into the runtime container
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Set environment variable to listen on port 8080
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "MyDotNetApp.dll"]
