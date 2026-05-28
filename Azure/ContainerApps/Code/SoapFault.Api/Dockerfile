FROM mcr.microsoft.com/dotnet/sdk:10.0 as BUILD

WORKDIR /app

COPY *.csproj .
RUN dotnet restore

COPY . .
RUN dotnet publish -c release --no-restore -o publish


FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=BUILD /app/publish .
ENTRYPOINT ["dotnet","SoapFault.Api.dll"]