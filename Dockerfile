FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY WorkshopApp.slnx ./
COPY src/WorkshopWebApp/WorkshopWebApp.csproj src/WorkshopWebApp/
RUN dotnet restore src/WorkshopWebApp/WorkshopWebApp.csproj

COPY src/WorkshopWebApp/ src/WorkshopWebApp/
RUN dotnet publish src/WorkshopWebApp/WorkshopWebApp.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "WorkshopWebApp.dll"]