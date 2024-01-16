// See https://aka.ms/new-console-template for more information

int sleep = 3000;

string? sleepString = Environment.GetEnvironmentVariable("x_delay");
string? url = Environment.GetEnvironmentVariable("x_url");

if (!string.IsNullOrEmpty(sleepString))
{
    sleep = int.Parse(sleepString);
}

Console.WriteLine("Hello, World!");

await Task.Delay(sleep);
if (!string.IsNullOrWhiteSpace(url))
{
    var client = new HttpClient();
    var response = await client.GetAsync(requestUri: url);
    response.EnsureSuccessStatusCode();
    System.Console.WriteLine($"Url: {url} was callled");
}

Console.WriteLine("Finished...Hello, World");
