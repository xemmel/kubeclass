
```yaml

  spec:
      containers:
        - name: failingapi-container
          image: failingwebapi:0.3
          livenessProbe:
            httpGet:
              path: /health
              port: 8080

```

docker build -t failingwebapi:0.3 .


```

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source

COPY *.csproj .
RUN dotnet restore

COPY . .
RUN dotnet publish -c release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "webapifailing.dll"]

```

kind load docker-image failingwebapi:0.3 --name ingress


### UptimeService.cs

```csharp

public class UptimeService
{
   private readonly DateTime _startTime;

   public UptimeService()
          {
                _startTime = DateTime.UtcNow;
          }


   public bool ShouldReturnOk()
           {
              var uptime = DateTime.UtcNow - _startTime;
              return uptime.TotalMinutes < 1;

           }
}

```


### Controllers/HealthController.cs

```csharp

using Microsoft.AspNetCore.Mvc;

namespace webapifailing.Controllers;

[ApiController]
[Route("[controller]")]
public class HealthController : ControllerBase
{
    private readonly ILogger<HealthController> _logger;
    private readonly UptimeService _uptimeService;

    public HealthController(ILogger<HealthController> logger, UptimeService uptimeService)
    {
        _logger = logger;
        _uptimeService = uptimeService;
    }

    [HttpGet(Name = "Check")]
    public IActionResult Check()
    {
            if (_uptimeService.ShouldReturnOk())
            {
                 return Ok("Service is healthy.");
            }
            else
            {
                return StatusCode(500,"Service is unhealthy.");
            }
    }


}

```

### Program.cs

```csharp

builder.Services.AddSingleton<UptimeService>();

```